import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/repositories/settings_repository.dart';

class ExchangeRateException implements Exception {
  final String message;

  const ExchangeRateException(this.message);

  @override
  String toString() => message;
}

class ExchangeRateService {
  final SettingsRepository _settings;
  final http.Client _client;
  final List<String> _apiUrls;

  ExchangeRateService(
    this._settings, {
    http.Client? client,
    List<String>? apiUrls,
  }) : _client = client ?? http.Client(),
       _apiUrls = apiUrls ?? _defaultApiUrls;

  static const _cacheKey = 'cached_currency_exchange';
  static const _cacheDatePrefix = 'cached_currency_exchange_date_';
  static const _customKey = 'custom_currency_amounts';
  static const _defaultApiUrls = [
    'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json',
    'https://latest.currency-api.pages.dev/v1/currencies/usd.min.json',
  ];

  Future<Map<String, double>> fetchRates() async {
    try {
      final fetched = await _fetchRemoteRates();
      final rates = fetched.rates;
      await _saveCachedRates(rates);
      await _saveRatesForDate(fetched.date ?? DateTime.now(), rates);
      return rates;
    } catch (error) {
      final cached = await _getCachedRates();
      if (cached.isNotEmpty) return cached;
      if (error is ExchangeRateException) rethrow;
      throw const ExchangeRateException('Unable to load exchange rates.');
    }
  }

  Future<_FetchedExchangeRates> _fetchRemoteRates() async {
    Object? lastError;
    for (final url in _apiUrls) {
      try {
        final response = await _client
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          return _decodeUsdRates(response.body);
        }
        lastError = 'HTTP ${response.statusCode}';
      } catch (error) {
        lastError = error;
      }
    }

    throw ExchangeRateException(
      lastError == null
          ? 'Unable to load exchange rates.'
          : 'Unable to load exchange rates. Last error: $lastError',
    );
  }

  _FetchedExchangeRates _decodeUsdRates(String body) {
    final decoded = json.decode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Exchange rate response was not an object.');
    }

    final usd = decoded['usd'];
    if (usd is! Map<String, dynamic>) {
      throw const FormatException(
        'Exchange rate response did not include USD.',
      );
    }

    final rates = _normalizeRates(usd);
    if (rates.length <= 1) {
      throw const FormatException(
        'Exchange rate response did not include currency rates.',
      );
    }
    final rawDate = decoded['date'];
    final date = rawDate is String ? DateTime.tryParse(rawDate) : null;
    return _FetchedExchangeRates(rates: rates, date: date);
  }

  Map<String, double> _normalizeRates(Map<dynamic, dynamic> source) {
    final rates = <String, double>{};
    for (final entry in source.entries) {
      final value = entry.value;
      if (value is num && value > 0) {
        rates[entry.key.toString().toLowerCase()] = value.toDouble();
      }
    }
    if (rates.isNotEmpty) rates.putIfAbsent('usd', () => 1.0);
    return rates;
  }

  Future<void> _saveCachedRates(Map<String, double> rates) async {
    await _settings.set(_cacheKey, json.encode(rates));
  }

  Future<void> _saveRatesForDate(
    DateTime date,
    Map<String, double> rates,
  ) async {
    await _settings.set(
      '$_cacheDatePrefix${_dateKey(date)}',
      json.encode(rates),
    );
  }

  Future<Map<String, double>> _getRatesForDate(DateTime date) async {
    final raw = await _settings.get('$_cacheDatePrefix${_dateKey(date)}');
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return _normalizeRates(decoded);
    } catch (_) {
      return {};
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<Map<String, double>> _getCachedRates() async {
    final raw = await _settings.get(_cacheKey);
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return _normalizeRates(decoded);
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, double>> getCustomRates() async {
    final raw = await _settings.get(_customKey);
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return _normalizeRates(decoded);
    } catch (_) {
      return {};
    }
  }

  Future<void> setCustomRate(String currency, double rate) async {
    final custom = await getCustomRates();
    custom[currency.toLowerCase()] = rate;
    await _settings.set(_customKey, json.encode(custom));
  }

  Future<void> removeCustomRate(String currency) async {
    final custom = await getCustomRates();
    custom.remove(currency.toLowerCase());
    await _settings.set(_customKey, json.encode(custom));
  }

  Future<void> clearCustomRates() async {
    await _settings.remove(_customKey);
  }

  Future<double> getRate(String currencyCode, {DateTime? onDate}) async {
    final key = currencyCode.toLowerCase();
    if (key == 'usd') return 1.0;

    final custom = await getCustomRates();
    if (custom.containsKey(key)) return custom[key]!;

    var cached = onDate == null
        ? await _getCachedRates()
        : await _getRatesForDate(onDate);
    if (!cached.containsKey(key)) {
      try {
        cached = await fetchRates();
      } catch (_) {}
    }

    return cached[key] ?? 1.0;
  }

  Future<double> ratio(String from, String to, {DateTime? onDate}) async {
    if (from.toLowerCase() == to.toLowerCase()) return 1.0;
    final toRate = await getRate(to, onDate: onDate);
    final fromRate = await getRate(from, onDate: onDate);
    if (fromRate == 0) return 1.0;
    return toRate * (1 / fromRate);
  }

  Future<int> convert(
    int amountMinor,
    String from,
    String to, {
    DateTime? onDate,
  }) async {
    if (from.toLowerCase() == to.toLowerCase()) return amountMinor;
    final r = await ratio(from, to, onDate: onDate);
    return (amountMinor * r).round();
  }

  Future<Map<String, double>> getAllRates({bool refresh = false}) async {
    final custom = await getCustomRates();
    Map<String, double> rates;

    try {
      rates = refresh ? await fetchRates() : await _getRatesForDisplay();
    } on ExchangeRateException {
      if (custom.isEmpty) rethrow;
      rates = {'usd': 1.0};
    }

    return Map<String, double>.from(rates)..addAll(custom);
  }

  Future<Map<String, double>> _getRatesForDisplay() async {
    final cached = await _getCachedRates();
    if (cached.isNotEmpty) return cached;
    return fetchRates();
  }
}

class _FetchedExchangeRates {
  const _FetchedExchangeRates({required this.rates, required this.date});

  final Map<String, double> rates;
  final DateTime? date;
}

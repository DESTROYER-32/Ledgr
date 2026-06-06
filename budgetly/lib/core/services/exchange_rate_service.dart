import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/repositories/settings_repository.dart';

class ExchangeRateService {
  final SettingsRepository _settings;

  ExchangeRateService(this._settings);

  static const _cacheKey = 'cached_currency_exchange';
  static const _customKey = 'custom_currency_amounts';
  static const _apiUrls = [
    'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json',
    'https://latest.currency-api.pages.dev/v1/currencies/usd.min.json',
  ];

  Future<Map<String, double>> fetchRates() async {
    for (final url in _apiUrls) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          final usd = decoded['usd'] as Map<String, dynamic>;
          final rates = usd.map((k, v) => MapEntry(k, (v as num).toDouble()));
          try {
            await _saveCachedRates(rates);
          } catch (_) {}
          return rates;
        }
      } catch (_) {
        continue;
      }
    }
    final cached = await _getCachedRates();
    if (cached.isNotEmpty) return cached;
    return {'usd': 1.0};
  }

  Future<void> _saveCachedRates(Map<String, double> rates) async {
    await _settings.set(_cacheKey, json.encode(rates));
  }

  Future<Map<String, double>> _getCachedRates() async {
    final raw = await _settings.get(_cacheKey);
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, double>> getCustomRates() async {
    final raw = await _settings.get(_customKey);
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
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

  Future<double> getRate(String currencyCode) async {
    final key = currencyCode.toLowerCase();
    final custom = await getCustomRates();
    if (custom.containsKey(key)) return custom[key]!;
    final cached = await _getCachedRates();
    if (cached.containsKey(key)) return cached[key]!;
    return 1.0;
  }

  Future<double> ratio(String from, String to) async {
    if (from == to) return 1.0;
    final toRate = await getRate(to);
    final fromRate = await getRate(from);
    if (fromRate == 0) return 1.0;
    return toRate * (1 / fromRate);
  }

  Future<int> convert(int amountMinor, String from, String to) async {
    if (from == to) return amountMinor;
    final r = await ratio(from, to);
    return (amountMinor * r).round();
  }

  Future<Map<String, double>> getAllRates() async {
    final custom = await getCustomRates();
    final cached = await _getCachedRates();
    final merged = Map<String, double>.from(cached);
    merged.addAll(custom);
    return merged;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../database/repositories/exchange_rate_repository.dart';

class ExchangeRateService {
  final ExchangeRateRepository _repo;
  static const _cacheDuration = Duration(hours: 24);

  ExchangeRateService(this._repo);

  Future<double?> getConversionRate(String from, String to) async {
    if (from == to) return 1.0;

    final now = DateTime.now();
    final cached = await _repo.getRate(from, to);

    if (cached != null &&
        cached.updatedAt.isAfter(now.subtract(_cacheDuration))) {
      return cached.rate;
    }

    try {
      await _fetchAndStoreRates(from);
      final fresh = await _repo.getRate(from, to);
      if (fresh != null) return fresh.rate;
      final inverse = await _repo.getRate(to, from);
      if (inverse != null && inverse.rate != 0) return 1 / inverse.rate;
    } catch (_) {}

    if (cached != null) return cached.rate;
    final inverse = await _repo.getRate(to, from);
    if (inverse != null && inverse.rate != 0) return 1 / inverse.rate;
    return null;
  }

  Future<void> _fetchAndStoreRates(String base) async {
    final uri = Uri.parse('https://open.er-api.com/v6/latest/$base');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch rates: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = body['rates'] as Map<String, dynamic>;

    for (final entry in rates.entries) {
      await _repo.setRate(base, entry.key, (entry.value as num).toDouble());
    }
  }
}

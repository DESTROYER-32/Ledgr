import 'package:drift/drift.dart';

import '../app_database.dart';

class ExchangeRateRepository {
  final AppDatabase _db;
  ExchangeRateRepository(this._db);

  Future<List<ExchangeRate>> getAll() => _db.exchangeRates.select().get();

  Future<ExchangeRate?> getRate(String from, String to) =>
      (_db.exchangeRates.select()
            ..where((r) =>
                r.fromCurrency.equals(from) & r.toCurrency.equals(to)))
          .getSingleOrNull();

  Future<double?> getConversionRate(String from, String to) async {
    if (from == to) return 1.0;
    final direct = await getRate(from, to);
    if (direct != null) return direct.rate;

    final inverse = await getRate(to, from);
    if (inverse == null || inverse.rate == 0) return null;
    return 1 / inverse.rate;
  }

  Future<void> setRate(String from, String to, double rate) async {
    final existing = await getRate(from, to);
    if (existing != null) {
      await (_db.exchangeRates.update()
            ..where((r) => r.id.equals(existing.id)))
          .write(ExchangeRatesCompanion(
            rate: Value(rate),
            updatedAt: Value(DateTime.now()),
          ));
    } else {
      await _db.into(_db.exchangeRates).insert(ExchangeRatesCompanion.insert(
        fromCurrency: from,
        toCurrency: to,
        rate: rate,
      ));
    }
  }

  Future<void> removeRate(int id) =>
      (_db.exchangeRates.delete()..where((r) => r.id.equals(id))).go();

  int convert(int amountMinor, double rate) =>
      (amountMinor * rate).round();
}

import 'package:drift/drift.dart';

import '../app_database.dart';

class WalletRepository {
  final AppDatabase _db;
  WalletRepository(this._db);

  Future<double?> _getRate(String from, String to) async {
    if (from == to) return 1.0;
    final rate = await (_db.exchangeRates.select()
          ..where((r) =>
              r.fromCurrency.equals(from) & r.toCurrency.equals(to)))
        .getSingleOrNull();
    if (rate != null) return rate.rate;

    final inverse = await (_db.exchangeRates.select()
          ..where((r) =>
              r.fromCurrency.equals(to) & r.toCurrency.equals(from)))
        .getSingleOrNull();
    if (inverse == null || inverse.rate == 0) return null;
    return 1 / inverse.rate;
  }

  int _convert(int amountMinor, double rate) =>
      (amountMinor * rate).round();

  Stream<List<Wallet>> watchAll() => _db.wallets.select().watch();

  Future<List<Wallet>> getAll() => _db.wallets.select().get();

  Stream<List<Wallet>> watchActive() => (_db.wallets.select()
        ..where((w) => w.archived.equals(false))
        ..orderBy([(w) => OrderingTerm(expression: w.sortOrder)]))
      .watch();

  Future<Wallet?> getById(int id) => (_db.wallets.select()
        ..where((w) => w.id.equals(id)))
      .getSingleOrNull();

  Future<int> insert(WalletsCompanion entry) =>
      _db.into(_db.wallets).insert(entry);

  Future<void> update(int id, WalletsCompanion entry) =>
      (_db.wallets.update()..where((w) => w.id.equals(id))).write(entry);

  Future<void> archive(int id) =>
      (_db.wallets.update()..where((w) => w.id.equals(id))).write(
        const WalletsCompanion(archived: Value(true)),
      );

  Future<void> delete(int id) =>
      (_db.wallets.delete()..where((w) => w.id.equals(id))).go();

  Future<int> totalBalance({String? targetCurrency}) async {
    final wallets = await _db.wallets.select().get();
    var total = 0;
    for (final w in wallets) {
      if (w.archived) continue;
      var balance = await balanceForWallet(w.id);
      if (targetCurrency != null && w.currencyCode != targetCurrency) {
        final rate = await _getRate(w.currencyCode, targetCurrency);
        if (rate != null) balance = _convert(balance, rate);
      }
      total += balance;
    }
    return total;
  }

  Future<int> balanceForWallet(int walletId) async {
    final wallet = await (_db.wallets.select()
          ..where((w) => w.id.equals(walletId)))
        .getSingle();

    final txns = await (_db.transactions.select()
          ..where((t) =>
              t.walletId.equals(walletId) |
              t.transferWalletId.equals(walletId)))
        .get();

    int balance = wallet.initialBalanceMinor;
    for (final t in txns) {
      int amount = t.amountMinor;
      if (t.currencyCode != wallet.currencyCode) {
        final rate = await _getRate(t.currencyCode, wallet.currencyCode);
        if (rate == null) {
          amount = t.amountMinor;
        } else {
          amount = _convert(t.amountMinor, rate);
        }
      }
      if (t.type == 'expense' && t.walletId == walletId) {
        balance -= amount;
      } else if (t.type == 'income' && t.walletId == walletId) {
        balance += amount;
      } else if (t.type == 'transfer') {
        if (t.walletId == walletId) balance -= amount;
        if (t.transferWalletId == walletId) balance += amount;
      }
    }
    return balance;
  }
}

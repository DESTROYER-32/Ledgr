import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../services/exchange_rate_service.dart';

class WalletRepository {
  final AppDatabase _db;
  final ExchangeRateService _exchangeRates;
  WalletRepository(this._db, this._exchangeRates);

  Stream<List<Wallet>> watchAll() =>
      (_db.wallets.select()
            ..orderBy([(w) => OrderingTerm(expression: w.sortOrder)]))
          .watch();

  Future<List<Wallet>> getAll() => _db.wallets.select().get();

  Stream<List<Wallet>> watchActive() =>
      (_db.wallets.select()
            ..where((w) => w.archived.equals(false))
            ..orderBy([(w) => OrderingTerm(expression: w.sortOrder)]))
          .watch();

  Future<Wallet?> getById(int id) =>
      (_db.wallets.select()..where((w) => w.id.equals(id))).getSingleOrNull();

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

  Future<int> totalBalance() async {
    final wallets = await _db.wallets.select().get();
    var total = 0;
    for (final w in wallets) {
      if (w.archived) continue;
      total += await balanceForWallet(w.id);
    }
    return total;
  }

  Future<int> balanceForWallet(int walletId) async {
    final wallet =
        await (_db.wallets.select()..where((w) => w.id.equals(walletId)))
            .getSingle();

    final now = DateTime.now();
    final txns =
        await (_db.transactions.select()..where(
              (t) =>
                  (t.walletId.equals(walletId) |
                      t.transferWalletId.equals(walletId)) &
                  t.date.isSmallerOrEqualValue(now),
            ))
            .get();

    int balance = wallet.initialBalanceMinor;
    for (final t in txns) {
      final int amount = t.amountMinor;
      if (t.type == 'expense' && t.walletId == walletId) {
        final converted = await _exchangeRates.convert(
          amount,
          t.currencyCode,
          wallet.currencyCode,
          onDate: t.date,
        );
        balance -= converted;
      } else if (t.type == 'income' && t.walletId == walletId) {
        final converted = await _exchangeRates.convert(
          amount,
          t.currencyCode,
          wallet.currencyCode,
          onDate: t.date,
        );
        balance += converted;
      } else if (t.type == 'transfer') {
        if (t.walletId == walletId) {
          final converted = await _exchangeRates.convert(
            amount,
            t.currencyCode,
            wallet.currencyCode,
            onDate: t.date,
          );
          balance -= converted;
        }
        if (t.transferWalletId == walletId) {
          final converted = await _exchangeRates.convert(
            amount,
            t.currencyCode,
            wallet.currencyCode,
            onDate: t.date,
          );
          balance += converted;
        }
      }
    }
    return balance;
  }
}

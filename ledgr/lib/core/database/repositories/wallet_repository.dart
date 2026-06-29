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
    final balances = await balancesForWallets(
      wallets.where((w) => !w.archived),
    );
    return balances.values.fold<int>(0, (sum, balance) => sum + balance);
  }

  Future<Map<int, int>> balancesForWallets(Iterable<Wallet> wallets) async {
    final walletList = wallets.toList();
    if (walletList.isEmpty) return {};
    final walletById = {for (final wallet in walletList) wallet.id: wallet};
    final ids = walletById.keys.toList();
    final now = DateTime.now();
    final txns =
        await (_db.transactions.select()..where(
              (t) =>
                  (t.walletId.isIn(ids) | t.transferWalletId.isIn(ids)) &
                  t.date.isSmallerOrEqualValue(now),
            ))
            .get();

    final balances = {
      for (final wallet in walletList) wallet.id: wallet.initialBalanceMinor,
    };

    for (final t in txns) {
      final amount = t.amountMinor;
      final sourceWallet = walletById[t.walletId];
      if ((t.type == 'expense' || t.type == 'transfer') &&
          sourceWallet != null) {
        balances[t.walletId] =
            balances[t.walletId]! -
            await _exchangeRates.convert(
              amount,
              t.currencyCode,
              sourceWallet.currencyCode,
              onDate: t.date,
            );
      } else if (t.type == 'income' && sourceWallet != null) {
        balances[t.walletId] =
            balances[t.walletId]! +
            await _exchangeRates.convert(
              amount,
              t.currencyCode,
              sourceWallet.currencyCode,
              onDate: t.date,
            );
      }

      final destinationWalletId = t.transferWalletId;
      final destinationWallet = destinationWalletId == null
          ? null
          : walletById[destinationWalletId];
      if (t.type == 'transfer' &&
          destinationWalletId != null &&
          destinationWallet != null) {
        balances[destinationWalletId] =
            balances[destinationWalletId]! +
            await _exchangeRates.convert(
              amount,
              t.currencyCode,
              destinationWallet.currencyCode,
              onDate: t.date,
            );
      }
    }

    return balances;
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

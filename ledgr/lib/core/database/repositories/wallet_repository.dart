import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../services/exchange_rate_service.dart';

class WalletRepository {
  final AppDatabase _db;
  final ExchangeRateService _exchangeRates;
  WalletRepository(this._db, this._exchangeRates);

  Stream<List<Wallet>> watchAll() => (_db.wallets.select()
        ..orderBy([(w) => OrderingTerm(expression: w.sortOrder)]))
      .watch();

  Future<List<Wallet>> getAll() => _db.wallets.select().get();

  Stream<List<Wallet>> watchActive() => (_db.wallets.select()
        ..where((w) => w.archived.equals(false))
        ..orderBy([(w) => OrderingTerm(expression: w.sortOrder)]))
      .watch();

  Future<List<Wallet>> getActive() => (_db.wallets.select()
        ..where((w) => w.archived.equals(false))
        ..orderBy([(w) => OrderingTerm(expression: w.sortOrder)]))
      .get();

  Future<Wallet?> getById(int id) =>
      (_db.wallets.select()..where((w) => w.id.equals(id))).getSingleOrNull();

  Future<int> insert(WalletsCompanion entry) =>
      _db.into(_db.wallets).insert(entry);

  Future<void> update(int id, WalletsCompanion entry) =>
      (_db.wallets.update()..where((w) => w.id.equals(id))).write(
        entry.copyWith(updatedAt: Value(DateTime.now())),
      );

  Future<void> updateSortOrders(List<int> walletIds) async {
    await _db.batch((batch) {
      for (var i = 0; i < walletIds.length; i++) {
        batch.update(
          _db.wallets,
          WalletsCompanion(
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now()),
          ),
          where: (w) => w.id.equals(walletIds[i]),
        );
      }
    });
  }

  Future<void> archive(int id) =>
      (_db.wallets.update()..where((w) => w.id.equals(id))).write(
        WalletsCompanion(
          archived: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> delete(int id) async {
    if (await _hasReferences(id)) {
      await archive(id);
      return;
    }
    await (_db.wallets.delete()..where((w) => w.id.equals(id))).go();
  }

  Future<bool> _hasReferences(int id) async {
    final transaction = await (_db.transactions.select()
          ..where(
            (t) => t.walletId.equals(id) | t.transferWalletId.equals(id),
          )
          ..limit(1))
        .getSingleOrNull();
    if (transaction != null) return true;
    final recurring = await (_db.recurringTransactions.select()
          ..where(
            (r) => r.walletId.equals(id) | r.transferWalletId.equals(id),
          )
          ..limit(1))
        .getSingleOrNull();
    if (recurring != null) return true;
    final budgetWallet = await (_db.budgetWallets.select()
          ..where((w) => w.walletId.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (budgetWallet != null) return true;
    final budgetLimit = await (_db.budgetCategoryLimits.select()
          ..where((l) => l.walletId.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (budgetLimit != null) return true;
    final objective = await (_db.objectives.select()
          ..where((o) => o.walletId.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return objective != null;
  }

  Future<int> totalBalance({required String currencyCode}) async {
    final wallets =
        (await _db.wallets.select().get()).where((w) => !w.archived).toList();
    final balances = await balancesForWallets(wallets);
    var total = 0;
    for (final wallet in wallets) {
      total += await _exchangeRates.convert(
        balances[wallet.id] ?? wallet.initialBalanceMinor,
        wallet.currencyCode,
        currencyCode,
      );
    }
    return total;
  }

  Future<Map<int, int>> balancesForWallets(Iterable<Wallet> wallets) async {
    final walletList = wallets.toList();
    if (walletList.isEmpty) return {};
    final walletById = {for (final wallet in walletList) wallet.id: wallet};
    final ids = walletById.keys.toList();
    final now = DateTime.now();
    final txns = await (_db.transactions.select()
          ..where(
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
        balances[t.walletId] = balances[t.walletId]! -
            await _exchangeRates.convert(
              amount,
              t.currencyCode,
              sourceWallet.currencyCode,
              onDate: t.date,
            );
      } else if (t.type == 'income' && sourceWallet != null) {
        balances[t.walletId] = balances[t.walletId]! +
            await _exchangeRates.convert(
              amount,
              t.currencyCode,
              sourceWallet.currencyCode,
              onDate: t.date,
            );
      }

      final destinationWalletId = t.transferWalletId;
      final destinationWallet =
          destinationWalletId == null ? null : walletById[destinationWalletId];
      if (t.type == 'transfer' &&
          destinationWalletId != null &&
          destinationWallet != null) {
        balances[destinationWalletId] = balances[destinationWalletId]! +
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
    final wallet = await (_db.wallets.select()
          ..where((w) => w.id.equals(walletId)))
        .getSingle();

    final now = DateTime.now();
    final txns = await (_db.transactions.select()
          ..where(
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

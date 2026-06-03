import 'package:drift/drift.dart';

import '../app_database.dart';

class WalletRepository {
  final AppDatabase _db;
  WalletRepository(this._db);

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
    final wallet = await (_db.wallets.select()
          ..where((w) => w.id.equals(walletId)))
        .getSingle();
    var balance = wallet.initialBalanceMinor;

    final expenses = await (_db.transactions.select()
          ..where((t) => t.walletId.equals(walletId) & t.type.equals('expense')))
        .map((t) => t.amountMinor)
        .get();
    for (final amt in expenses) {
      balance -= amt;
    }

    final income = await (_db.transactions.select()
          ..where((t) => t.walletId.equals(walletId) & t.type.equals('income')))
        .map((t) => t.amountMinor)
        .get();
    for (final amt in income) {
      balance += amt;
    }

    final transfersIn = await (_db.transactions.select()
          ..where((t) =>
              t.transferWalletId.equals(walletId) & t.type.equals('transfer')))
        .map((t) => t.amountMinor)
        .get();
    for (final amt in transfersIn) {
      balance += amt;
    }

    final transfersOut = await (_db.transactions.select()
          ..where((t) =>
              t.walletId.equals(walletId) & t.type.equals('transfer')))
        .map((t) => t.amountMinor)
        .get();
    for (final amt in transfersOut) {
      balance -= amt;
    }

    return balance;
  }
}

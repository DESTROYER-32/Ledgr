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

    final result = await _db.customSelect(
      'SELECT '
      "COALESCE(SUM(CASE WHEN type='expense' AND wallet_id=?1 THEN amount_minor END),0) AS expense_sum, "
      "COALESCE(SUM(CASE WHEN type='income' AND wallet_id=?1 THEN amount_minor END),0) AS income_sum, "
      "COALESCE(SUM(CASE WHEN type='transfer' AND transfer_wallet_id=?1 THEN amount_minor END),0) AS transfer_in_sum, "
      "COALESCE(SUM(CASE WHEN type='transfer' AND wallet_id=?1 THEN amount_minor END),0) AS transfer_out_sum "
      'FROM transactions WHERE wallet_id=?1 OR transfer_wallet_id=?1',
      variables: [Variable(walletId)],
    ).getSingle();

    return wallet.initialBalanceMinor
        - (result.data['expense_sum'] as int)
        + (result.data['income_sum'] as int)
        + (result.data['transfer_in_sum'] as int)
        - (result.data['transfer_out_sum'] as int);
  }
}

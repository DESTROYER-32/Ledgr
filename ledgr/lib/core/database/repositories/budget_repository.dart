import 'package:drift/drift.dart';

import '../app_database.dart';

class BudgetRepository {
  final AppDatabase _db;
  BudgetRepository(this._db);

  Stream<List<Budget>> watchAll() => (_db.budgets.select()
        ..where((b) => b.archived.equals(false)))
      .watch();

  Future<Budget?> getById(int id) => (_db.budgets.select()
        ..where((b) => b.id.equals(id)))
      .getSingleOrNull();

  Future<Budget?> getForPeriod(DateTime start, DateTime end) async {
    final results = await (_db.budgets.select()
          ..where((b) =>
              b.periodStart.equals(start) & b.periodEnd.equals(end)))
        .get();
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insert(BudgetsCompanion entry) =>
      _db.into(_db.budgets).insert(entry);

  Future<void> update(int id, BudgetsCompanion entry) =>
      (_db.budgets.update()..where((b) => b.id.equals(id))).write(entry);

  Future<void> delete(int id) async {
    await (_db.budgetCategoryLimits.delete()
          ..where((l) => l.budgetId.equals(id)))
        .go();
    await (_db.budgetWallets.delete()
          ..where((w) => w.budgetId.equals(id)))
        .go();
    await (_db.budgets.delete()..where((b) => b.id.equals(id))).go();
  }

  Stream<List<BudgetCategoryLimit>> watchLimits(int budgetId) =>
      (_db.budgetCategoryLimits.select()
            ..where((l) => l.budgetId.equals(budgetId)))
          .watch();

  Future<void> setLimit(int budgetId, int categoryId,
      {int? walletId, required int amount}) async {
    final existing = await (_db.budgetCategoryLimits.select()
          ..where((l) =>
              l.budgetId.equals(budgetId) & l.categoryId.equals(categoryId)))
        .get();
    if (existing.isNotEmpty) {
      await (_db.budgetCategoryLimits.update()
            ..where((l) => l.id.equals(existing.first.id)))
          .write(BudgetCategoryLimitsCompanion(
              plannedAmountMinor: Value(amount),
              walletId: walletId != null ? Value(walletId) : const Value(null)));
    } else {
      await _db.into(_db.budgetCategoryLimits).insert(
            BudgetCategoryLimitsCompanion.insert(
              budgetId: budgetId,
              categoryId: categoryId,
              plannedAmountMinor: amount,
              walletId: walletId != null ? Value(walletId) : const Value(null),
            ),
          );
    }
  }

  Future<void> removeLimit(int budgetId, int categoryId) async {
    final existing = await (_db.budgetCategoryLimits.select()
          ..where((l) =>
              l.budgetId.equals(budgetId) & l.categoryId.equals(categoryId)))
        .get();
    if (existing.isNotEmpty) {
      await (_db.budgetCategoryLimits.delete()
            ..where((l) => l.id.equals(existing.first.id)))
          .go();
    }
  }

  // Multi-wallet support
  Stream<List<BudgetWallet>> watchBudgetWallets(int budgetId) =>
      (_db.budgetWallets.select()
            ..where((w) => w.budgetId.equals(budgetId)))
          .watch();

  Future<void> addWalletToBudget(int budgetId, int walletId) async {
    await _db.into(_db.budgetWallets).insert(
          BudgetWalletsCompanion.insert(
            budgetId: budgetId,
            walletId: walletId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removeWalletFromBudget(int budgetId, int walletId) async {
    await (_db.budgetWallets.delete()
          ..where((w) =>
              w.budgetId.equals(budgetId) & w.walletId.equals(walletId)))
        .go();
  }

  Future<Map<int, int>> spentForBudget(int budgetId,
      DateTime start, DateTime end) async {
    final budget = await getById(budgetId);
    if (budget == null) return {};

    final wallets = await (_db.budgetWallets.select()
          ..where((w) => w.budgetId.equals(budgetId)))
        .get();

    final q = _db.transactions.select();
    q.where((t) => t.type.equals('expense'));
    q.where((t) => t.specialType.equals('none'));
    q.where((t) => t.date.isBiggerOrEqualValue(start));
    q.where((t) => t.date.isSmallerOrEqualValue(end));

    if (wallets.isNotEmpty) {
      final walletIds = wallets.map((w) => w.walletId).toList();
      q.where((t) => t.walletId.isIn(walletIds));
    }

    if (!budget.includeIncome) {
      q.where((t) => t.type.equals('expense'));
    }
    if (!budget.includeDebtCredit) {
      q.where((t) =>
          t.specialType.equals('none') | t.specialType.isNull());
    }

    final rows = await q.get();
    final map = <int, int>{};
    for (final t in rows) {
      if (t.categoryId != null) {
        map.update(t.categoryId!, (v) => v + t.amountMinor,
            ifAbsent: () => t.amountMinor);
      }
    }
    return map;
  }
}

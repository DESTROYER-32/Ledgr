import 'package:drift/drift.dart';

import '../app_database.dart';

class BudgetRepository {
  final AppDatabase _db;
  BudgetRepository(this._db);

  Stream<List<Budget>> watchAll() => _db.budgets.select().watch();

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

  Future<void> delete(int id) =>
      (_db.budgets.delete()..where((b) => b.id.equals(id))).go();

  Stream<List<BudgetCategoryLimit>> watchLimits(int budgetId) =>
      (_db.budgetCategoryLimits.select()
            ..where((l) => l.budgetId.equals(budgetId)))
          .watch();

  Future<void> setLimit(int budgetId, int categoryId, int amount) async {
    final existing = await (_db.budgetCategoryLimits.select()
          ..where((l) =>
              l.budgetId.equals(budgetId) & l.categoryId.equals(categoryId)))
        .get();
    if (existing.isNotEmpty) {
      await (_db.budgetCategoryLimits.update()
            ..where((l) => l.id.equals(existing.first.id)))
          .write(BudgetCategoryLimitsCompanion(
              plannedAmountMinor: Value(amount)));
    } else {
      await _db.into(_db.budgetCategoryLimits).insert(
            BudgetCategoryLimitsCompanion.insert(
              budgetId: budgetId,
              categoryId: categoryId,
              plannedAmountMinor: amount,
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
}

import 'package:drift/drift.dart';

import '../app_database.dart';

class BudgetRepository {
  final AppDatabase _db;
  BudgetRepository(this._db);

  Stream<List<Budget>> watchAll() =>
      (_db.budgets.select()..where((b) => b.archived.equals(false))).watch();

  Future<Budget?> getById(int id) =>
      (_db.budgets.select()..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<Budget?> getForPeriod(DateTime start, DateTime end) async {
    final results =
        await (_db.budgets.select()..where(
              (b) => b.periodStart.equals(start) & b.periodEnd.equals(end),
            ))
            .get();
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insert(BudgetsCompanion entry) =>
      _db.into(_db.budgets).insert(entry);

  Future<void> update(int id, BudgetsCompanion entry) =>
      (_db.budgets.update()..where((b) => b.id.equals(id))).write(entry);

  Future<void> delete(int id) async {
    await (_db.transactionBudgets.delete()
          ..where((tb) => tb.budgetId.equals(id)))
        .go();
    await (_db.budgetCategoryLimits.delete()
          ..where((l) => l.budgetId.equals(id)))
        .go();
    await (_db.budgetWallets.delete()..where((w) => w.budgetId.equals(id)))
        .go();
    await (_db.budgets.delete()..where((b) => b.id.equals(id))).go();
  }

  Stream<List<BudgetCategoryLimit>> watchLimits(int budgetId) =>
      (_db.budgetCategoryLimits.select()
            ..where((l) => l.budgetId.equals(budgetId)))
          .watch();

  Future<void> setLimit(
    int budgetId,
    int categoryId, {
    int? walletId,
    required int amount,
  }) async {
    final existing =
        await (_db.budgetCategoryLimits.select()..where(
              (l) =>
                  l.budgetId.equals(budgetId) &
                  l.categoryId.equals(categoryId) &
                  (walletId == null
                      ? l.walletId.isNull()
                      : l.walletId.equals(walletId)),
            ))
            .get();
    if (existing.isNotEmpty) {
      await (_db.budgetCategoryLimits.update()
            ..where((l) => l.id.equals(existing.first.id)))
          .write(
            BudgetCategoryLimitsCompanion(
              plannedAmountMinor: Value(amount),
              walletId: walletId != null ? Value(walletId) : const Value(null),
            ),
          );
    } else {
      await _db
          .into(_db.budgetCategoryLimits)
          .insert(
            BudgetCategoryLimitsCompanion.insert(
              budgetId: budgetId,
              categoryId: categoryId,
              plannedAmountMinor: amount,
              walletId: walletId != null ? Value(walletId) : const Value(null),
            ),
          );
    }
  }

  Future<void> removeLimit(
    int budgetId,
    int categoryId, {
    int? walletId,
  }) async {
    final existing =
        await (_db.budgetCategoryLimits.select()..where(
              (l) =>
                  l.budgetId.equals(budgetId) &
                  l.categoryId.equals(categoryId) &
                  (walletId == null
                      ? l.walletId.isNull()
                      : l.walletId.equals(walletId)),
            ))
            .get();
    if (existing.isNotEmpty) {
      await (_db.budgetCategoryLimits.delete()
            ..where((l) => l.id.equals(existing.first.id)))
          .go();
    }
  }

  // Multi-wallet support
  Stream<List<BudgetWallet>> watchBudgetWallets(int budgetId) =>
      (_db.budgetWallets.select()..where((w) => w.budgetId.equals(budgetId)))
          .watch();

  Future<void> addWalletToBudget(int budgetId, int walletId) async {
    await _db
        .into(_db.budgetWallets)
        .insert(
          BudgetWalletsCompanion.insert(budgetId: budgetId, walletId: walletId),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removeWalletFromBudget(int budgetId, int walletId) async {
    await (_db.budgetWallets.delete()..where(
          (w) => w.budgetId.equals(budgetId) & w.walletId.equals(walletId),
        ))
        .go();
  }

  Future<Map<int, int>> spentForBudget(
    int budgetId,
    DateTime start,
    DateTime end,
  ) async {
    final budget = await getById(budgetId);
    if (budget == null) return {};

    final wallets =
        await (_db.budgetWallets.select()
              ..where((w) => w.budgetId.equals(budgetId)))
            .get();

    final q = _db.transactions.select();
    q.where((t) {
      final expenses = t.type.equals('expense');
      return budget.includeIncome
          ? expenses | t.type.equals('income')
          : expenses;
    });
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
      q.where((t) => t.specialType.equals('none') | t.specialType.isNull());
    }

    if (budget.specificMode) {
      final typeClause = budget.includeIncome
          ? "(t.type = 'expense' OR t.type = 'income')"
          : "t.type = 'expense'";
      final specialClause = budget.includeDebtCredit
          ? '1 = 1'
          : "(t.special_type = 'none' OR t.special_type IS NULL)";
      final walletClause = wallets.isEmpty
          ? '1 = 1'
          : 't.wallet_id IN (${List.filled(wallets.length, '?').join(', ')})';
      final rows = await _db
          .customSelect(
            '''
            SELECT t.category_id, SUM(t.amount_minor) AS total
            FROM transactions t
            INNER JOIN transaction_budgets tb ON tb.transaction_id = t.id
            WHERE tb.budget_id = ?
              AND t.category_id IS NOT NULL
              AND t.date >= ?
              AND t.date <= ?
              AND $typeClause
              AND $specialClause
              AND $walletClause
            GROUP BY t.category_id
            ''',
            readsFrom: {_db.transactions, _db.transactionBudgets},
            variables: [
              Variable.withInt(budget.id),
              Variable.withDateTime(start),
              Variable.withDateTime(end),
              ...wallets.map((w) => Variable.withInt(w.walletId)),
            ],
          )
          .get();
      return {
        for (final row in rows)
          row.data['category_id'] as int: row.data['total'] as int,
      };
    }
    final rows = await q.get();
    final map = <int, int>{};
    for (final t in rows) {
      if (t.categoryId != null) {
        map.update(
          t.categoryId!,
          (v) => v + t.amountMinor,
          ifAbsent: () => t.amountMinor,
        );
      }
    }
    return map;
  }
}

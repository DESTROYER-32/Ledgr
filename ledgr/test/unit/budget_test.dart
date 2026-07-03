import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ledgr/core/database/app_database.dart';
import 'package:ledgr/core/database/repositories/budget_repository.dart';
import 'package:ledgr/core/database/repositories/settings_repository.dart';
import 'package:ledgr/core/services/exchange_rate_service.dart';

/// Tests for budget calculation logic
/// Note: These test the calculation math, not the database layer.
void main() {
  group('Budget Calculations', () {
    test('remaining is planned minus spent', () {
      const planned = 100000; // $1000.00
      const spent = 75000; // $750.00
      const remaining = planned - spent;
      expect(remaining, 25000); // $250.00
    });

    test('overspent when spent exceeds planned', () {
      const planned = 100000;
      const spent = 120000;
      const remaining = planned - spent;
      expect(remaining, -20000);
      expect(remaining.isNegative, true);
    });

    test('percentage clamps to 1.0', () {
      const planned = 100000;
      const spent = 200000;
      final percentage = (spent / planned).clamp(0.0, 1.0);
      expect(percentage, 1.0);
    });

    test('percentage is 0 when planned is 0', () {
      const planned = 0;
      const spent = 5000;
      final percentage = planned > 0 ? (spent / planned).clamp(0.0, 1.0) : 0.0;
      expect(percentage, 0.0);
    });

    test('percentage is correct for partial spend', () {
      const planned = 100000;
      const spent = 25000;
      final percentage = (spent / planned).clamp(0.0, 1.0);
      expect(percentage, 0.25);
    });

    test('total budget is sum of category limits', () {
      const limits = [50000, 30000, 20000, 100000]; // $500, $300, $200, $1000
      final total = limits.fold<int>(0, (s, v) => s + v);
      expect(total, 200000); // $2000.00
    });

    test('total spent across categories', () {
      final spentByCat = <int, int>{1: 25000, 2: 15000, 3: 5000};
      final total = spentByCat.values.fold<int>(0, (s, v) => s + v);
      expect(total, 45000);
    });
  });

  group('BudgetRepository', () {
    test('setLimit keeps wallet-specific limits separate', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final repo = BudgetRepository(
        db,
        ExchangeRateService(SettingsRepository(db)),
      );
      final budgetId = await db
          .into(db.budgets)
          .insert(
            BudgetsCompanion.insert(
              name: 'Groceries',
              periodStart: DateTime(2024, 1),
              periodEnd: DateTime(2024, 1, 31),
              currencyCode: 'USD',
            ),
          );
      final categoryId = await db
          .into(db.categories)
          .insert(CategoriesCompanion.insert(name: 'Food', kind: 'expense'));
      final wallet1 = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Checking',
              type: 'checking',
              currencyCode: 'USD',
              initialBalanceMinor: 0,
            ),
          );
      final wallet2 = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Cash',
              type: 'cash',
              currencyCode: 'USD',
              initialBalanceMinor: 0,
            ),
          );

      await repo.setLimit(
        budgetId,
        categoryId,
        walletId: wallet1,
        amount: 10000,
      );
      await repo.setLimit(
        budgetId,
        categoryId,
        walletId: wallet2,
        amount: 25000,
      );

      final limits = await db.select(db.budgetCategoryLimits).get();
      expect(limits, hasLength(2));
      expect(
        {for (final limit in limits) limit.walletId: limit.plannedAmountMinor},
        {wallet1: 10000, wallet2: 25000},
      );
    });

    test('database rejects duplicate global budget category limits', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final budgetId = await db
          .into(db.budgets)
          .insert(
            BudgetsCompanion.insert(
              name: 'Groceries',
              periodStart: DateTime(2024, 1),
              periodEnd: DateTime(2024, 1, 31),
              currencyCode: 'USD',
            ),
          );
      final categoryId = await db
          .into(db.categories)
          .insert(CategoriesCompanion.insert(name: 'Food', kind: 'expense'));

      await db
          .into(db.budgetCategoryLimits)
          .insert(
            BudgetCategoryLimitsCompanion.insert(
              budgetId: budgetId,
              categoryId: categoryId,
              plannedAmountMinor: 10000,
            ),
          );

      await expectLater(
        db
            .into(db.budgetCategoryLimits)
            .insert(
              BudgetCategoryLimitsCompanion.insert(
                budgetId: budgetId,
                categoryId: categoryId,
                plannedAmountMinor: 25000,
              ),
            ),
        throwsA(anything),
      );
    });

    test(
      'spentForBudget includes income only when includeIncome is enabled',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        final repo = BudgetRepository(
          db,
          ExchangeRateService(SettingsRepository(db)),
        );
        final categoryId = await db
            .into(db.categories)
            .insert(CategoriesCompanion.insert(name: 'Food', kind: 'expense'));
        final walletId = await db
            .into(db.wallets)
            .insert(
              WalletsCompanion.insert(
                name: 'Checking',
                type: 'checking',
                currencyCode: 'USD',
                initialBalanceMinor: 0,
              ),
            );
        final start = DateTime(2024, 1);
        final end = DateTime(2024, 1, 31);
        final excludedIncomeBudget = await db
            .into(db.budgets)
            .insert(
              BudgetsCompanion.insert(
                name: 'Expenses only',
                periodStart: start,
                periodEnd: end,
                currencyCode: 'USD',
                includeIncome: const Value(false),
              ),
            );
        final includedIncomeBudget = await db
            .into(db.budgets)
            .insert(
              BudgetsCompanion.insert(
                name: 'Net budget',
                periodStart: start,
                periodEnd: end,
                currencyCode: 'USD',
                includeIncome: const Value(true),
              ),
            );

        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: 'expense',
                amountMinor: 1000,
                currencyCode: 'USD',
                date: DateTime(2024, 1, 10),
                walletId: walletId,
                categoryId: Value(categoryId),
              ),
            );
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: 'income',
                amountMinor: 500,
                currencyCode: 'USD',
                date: DateTime(2024, 1, 11),
                walletId: walletId,
                categoryId: Value(categoryId),
              ),
            );

        expect(await repo.spentForBudget(excludedIncomeBudget, start, end), {
          categoryId: 1000,
        });
        expect(await repo.spentForBudget(includedIncomeBudget, start, end), {
          categoryId: 500,
        });
      },
    );
  });
}

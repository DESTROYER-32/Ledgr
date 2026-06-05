import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Wallets,
    Categories,
    Transactions,
    Budgets,
    BudgetCategoryLimits,
    BudgetWallets,
    RecurringTransactions,
    Settings,
    Objectives,
    AssociatedTitles,
    DeleteLogs,
    ExchangeRates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createIndexes();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {}
        if (from < 3) {
          await m.addColumn(budgets, budgets.isIncome);
          await m.addColumn(budgets, budgets.pinned);
          await m.addColumn(budgets, budgets.color);
        }
        if (from < 4) {
          await _createIndexes();
        }
        if (from < 5) {
          await m.addColumn(budgets, budgets.plannedAmountMinor);
        }
        if (from < 6) {
          try {
            await customStatement(
              'CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, target_amount_minor INTEGER NOT NULL, current_amount_minor INTEGER DEFAULT 0, currency_code TEXT NOT NULL, deadline TEXT, icon INTEGER, color INTEGER, archived INTEGER DEFAULT 0, created_at TEXT NOT NULL DEFAULT (datetime(\'now\')), updated_at TEXT NOT NULL DEFAULT (datetime(\'now\')))',
            );
          } catch (_) {}
          try {
            await m.createTable(exchangeRates);
          } catch (_) {}
        }
        if (from < 7) {
          await _upgradeToV7(m);
        }
        if (from < 8) {
          await _upgradeToV8(m);
        }
        if (from < 9) {
          await _upgradeToV9(m);
        }
      },
    );
  }

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON transactions(wallet_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions(category_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_special_type ON transactions(special_type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_budget_limits_budget_id ON budget_category_limits(budget_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_budget_limits_category_id ON budget_category_limits(category_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_recurring_wallet_id ON recurring_transactions(wallet_id)',
    );
  }

  Future<void> _upgradeToV7(Migrator m) async {
    await m.addColumn(categories, categories.mainCategoryPk);
    await m.addColumn(transactions, transactions.specialType);
    await m.addColumn(transactions, transactions.recurrenceRule);
    await m.addColumn(transactions, transactions.budgetFksExclude);
    await m.addColumn(transactions, transactions.objectiveFk);
    await m.addColumn(transactions, transactions.attachmentPath);
    await m.addColumn(transactions, transactions.methodAdded);
    await m.addColumn(wallets, wallets.color);
    await m.addColumn(wallets, wallets.icon);
    await m.addColumn(wallets, wallets.decimals);
    await m.addColumn(budgets, budgets.archived);
    await m.addColumn(budgets, budgets.includeIncome);
    await m.addColumn(budgets, budgets.includeDebtCredit);
    await m.addColumn(budgets, budgets.includeBalanceCorrection);
    await m.addColumn(budgets, budgets.includeInOtherBudgets);
    await m.addColumn(budgets, budgets.absoluteLimit);
    await m.addColumn(budgets, budgets.recurrenceRule);
    await m.addColumn(budgetCategoryLimits, budgetCategoryLimits.walletId);
    await m.addColumn(recurringTransactions, recurringTransactions.specialType);
    await m.createTable(budgetWallets);
    await m.createTable(objectives);
    await m.createTable(associatedTitles);
    await m.createTable(deleteLogs);

    await customStatement('DROP TABLE IF EXISTS goals');
  }

  Future<void> _upgradeToV8(Migrator m) async {
    // Migrate goals data to objectives if Goals table exists
    try {
      final rows = await customSelect('SELECT * FROM goals').get();
      if (rows.isNotEmpty) {
        for (final row in rows) {
          final data = row.data;
          await into(objectives).insert(
            ObjectivesCompanion.insert(
              name: data['name'] as String? ?? 'Goal',
              type: 'goal',
              amountMinor: data['target_amount_minor'] as int? ?? 0,
              walletId: const Value(null),
              currencyCode: 'USD',
              deadline: data['deadline'] != null
                  ? Value(DateTime.parse(data['deadline'] as String))
                  : const Value(null),
              color: data['color'] != null
                  ? Value(data['color'] as int)
                  : const Value(null),
              icon: const Value(null),
              pinned: const Value(false),
              archived: Value(data['archived'] as bool? ?? false),
            ),
          );
        }
      }
    } catch (_) {}
    await customStatement('DROP TABLE IF EXISTS goals');
  }

  Future<void> _upgradeToV9(Migrator m) async {
    await m.addColumn(budgets, budgets.specificMode);
    await m.addColumn(transactions, transactions.budgetFks);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'budgetly.db'));
    return NativeDatabase(file);
  });
}

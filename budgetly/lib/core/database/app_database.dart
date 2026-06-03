import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Wallets,
  Categories,
  Transactions,
  Budgets,
  BudgetCategoryLimits,
  RecurringTransactions,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Schema v1 -> v2: tags column already existed in v1.
        }
        if (from < 3) {
          await m.addColumn(budgets, budgets.isIncome);
          await m.addColumn(budgets, budgets.pinned);
          await m.addColumn(budgets, budgets.color);
        }
        if (from < 4) {
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON transactions(wallet_id)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions(category_id)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_budget_limits_budget_id ON budget_category_limits(budget_id)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_budget_limits_category_id ON budget_category_limits(category_id)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_recurring_wallet_id ON recurring_transactions(wallet_id)');
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'budgetly.db'));
    return NativeDatabase(file);
  });
}

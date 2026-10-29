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
    Budgets,
    Objectives,
    Transactions,
    TransactionBudgets,
    BudgetCategoryLimits,
    BudgetWallets,
    RecurringTransactions,
    Settings,
    AssociatedTitles,
    DeleteLogs,
    NetWorthSnapshots,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createIndexes();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        await customStatement('PRAGMA busy_timeout = 5000;');
        await customStatement('PRAGMA journal_mode = WAL;');
        await customStatement('PRAGMA synchronous = NORMAL;');
      },
      onUpgrade: (m, from, to) async {
        // Safe non-destructive upgrade strategy
        await _createIndexes();
      },
    );
  }

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON transactions(wallet_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_wallet_date ON transactions(wallet_id, date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_transfer_wallet_date ON transactions(transfer_wallet_id, date)',
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
      'CREATE INDEX IF NOT EXISTS idx_transaction_budgets_transaction_id ON transaction_budgets(transaction_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transaction_budgets_budget_id ON transaction_budgets(budget_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_budget_limits_budget_id ON budget_category_limits(budget_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_budget_limits_category_id ON budget_category_limits(category_id)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_budget_limits_unique_wallet_scope '
      'ON budget_category_limits(budget_id, category_id, COALESCE(wallet_id, -1))',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_recurring_wallet_id ON recurring_transactions(wallet_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_net_worth_snapshots_date ON net_worth_snapshots(date)',
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ledgr.db'));
    return NativeDatabase(file);
  });
}

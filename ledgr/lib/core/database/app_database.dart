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
    InvestmentHoldings,
    PortfolioTransactions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createIndexes();
      },
      onUpgrade: (m, from, to) async {
        // Pre-release safety valve: a short-lived build used schemaVersion 2.
        // The app has not shipped, so downgrade by recreating the local schema
        // instead of carrying a permanent migration path for test databases.
        if (from > to) {
          await customStatement('PRAGMA foreign_keys = OFF;');
          for (final table in const [
            'delete_logs',
            'net_worth_snapshots',
            'portfolio_transactions',
            'investment_holdings',
            'associated_titles',
            'recurring_transactions',
            'budget_wallets',
            'budget_category_limits',
            'transaction_budgets',
            'transactions',
            'objectives',
            'budgets',
            'settings',
            'categories',
            'wallets',
          ]) {
            await customStatement('DROP TABLE IF EXISTS $table;');
          }
          await m.createAll();
          await _createIndexes();
          await customStatement('PRAGMA foreign_keys = ON;');
          return;
        }

        if (from < 2) {
          await m.createTable(netWorthSnapshots);
        }

        if (from < 3) {
          await m.createTable(investmentHoldings);
          await m.createTable(portfolioTransactions);
        }

        await _createIndexes();
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
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_investment_holdings_wallet_id ON investment_holdings(wallet_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_portfolio_transactions_holding_id ON portfolio_transactions(holding_id)',
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

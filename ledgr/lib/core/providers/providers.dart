import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/repositories/budget_repository.dart';
import '../database/repositories/category_repository.dart';
import '../database/repositories/recurring_repository.dart';
import '../database/repositories/settings_repository.dart';
import '../database/repositories/transaction_repository.dart';
import '../database/repositories/wallet_repository.dart';
import '../utils/money_utils.dart';

class ThemeConfig {
  final ThemeMode themeMode;
  final Color seedColor;
  const ThemeConfig({required this.themeMode, required this.seedColor});
}

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(appDatabaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(appDatabaseProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(appDatabaseProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(appDatabaseProvider));
});

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository(ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

// Stream providers for reactive queries
final activeWalletsProvider =
    StreamProvider<List<Wallet>>((ref) => ref.watch(walletRepositoryProvider).watchActive());

final allTransactionsProvider =
    StreamProvider<List<Transaction>>((ref) => ref.watch(transactionRepositoryProvider).watchAll());

final recentTransactionsProvider = StreamProvider<List<Transaction>>(
    (ref) => ref.watch(transactionRepositoryProvider).watchRecent(limit: 5));

final activeCategoriesProvider =
    StreamProvider<List<Category>>((ref) => ref.watch(categoryRepositoryProvider).watchActive());

final expenseCategoriesProvider =
    StreamProvider<List<Category>>((ref) => ref.watch(categoryRepositoryProvider).watchByKind('expense'));

final allBudgetsProvider =
    StreamProvider<List<Budget>>((ref) => ref.watch(budgetRepositoryProvider).watchAll());

final pinnedBudgetsProvider = Provider<List<Budget>>((ref) {
  final budgets = ref.watch(allBudgetsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  return budgets.where((b) => b.pinned && b.periodEnd.isAfter(now)).toList();
});

final activeRecurringProvider = StreamProvider<List<RecurringTransaction>>(
    (ref) => ref.watch(recurringRepositoryProvider).watchActive());

final currencyCodeProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  final currency = await repo.get('currency');
  return currency ?? 'USD';
});

final formatMoneyProvider = Provider<String Function(int)>((ref) {
  final code = ref.watch(currencyCodeProvider).valueOrNull ?? 'USD';
  return (int amountMinor) => MoneyUtils.format(amountMinor, currencyCode: code);
});

final themeConfigProvider = FutureProvider<ThemeConfig>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  final modeStr = await repo.get('theme_mode');
  final seedStr = await repo.get('theme_seed');
  final mode = switch (modeStr) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
  final seed = seedStr != null ? Color(int.parse(seedStr)) : const Color(0xFF1A6D4A);
  return ThemeConfig(themeMode: mode, seedColor: seed);
});

final totalBalanceProvider = FutureProvider<int>((ref) async {
  ref.watch(activeWalletsProvider);
  ref.watch(allTransactionsProvider);
  final repo = ref.watch(walletRepositoryProvider);
  return repo.totalBalance();
});

final walletBalancesProvider = FutureProvider<Map<int, int>>((ref) async {
  ref.watch(activeWalletsProvider);
  ref.watch(allTransactionsProvider);
  final repo = ref.watch(walletRepositoryProvider);
  final wallets = await repo.getAll();
  final map = <int, int>{};
  for (final w in wallets) {
    map[w.id] = await repo.balanceForWallet(w.id);
  }
  return map;
});

final budgetLimitsProvider =
    StreamProvider.family<List<BudgetCategoryLimit>, int>((ref, budgetId) {
  return ref.watch(budgetRepositoryProvider).watchLimits(budgetId);
});

final spentByCategoryProvider = FutureProvider.family<Map<int, int>, String>(
    (ref, key) async {
  ref.watch(allTransactionsProvider);
  final parts = key.split(',');
  final start = DateTime.parse(parts[0]);
  final end = DateTime.parse(parts[1]);
  return ref
      .watch(transactionRepositoryProvider)
      .spentByCategory(start, end);
});

final monthlyIncomeProvider = FutureProvider.family<int, String>((ref, key) async {
  ref.watch(allTransactionsProvider);
  final parts = key.split(',');
  final start = DateTime.parse(parts[0]);
  final end = DateTime.parse(parts[1]);
  return ref.watch(transactionRepositoryProvider).totalIncome(start, end);
});

final monthlyExpensesProvider = FutureProvider.family<int, String>((ref, key) async {
  ref.watch(allTransactionsProvider);
  final parts = key.split(',');
  final start = DateTime.parse(parts[0]);
  final end = DateTime.parse(parts[1]);
  return ref.watch(transactionRepositoryProvider).totalExpenses(start, end);
});

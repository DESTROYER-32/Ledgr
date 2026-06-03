import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/repositories/budget_repository.dart';
import '../database/repositories/category_repository.dart';
import '../database/repositories/recurring_repository.dart';
import '../database/repositories/settings_repository.dart';
import '../database/repositories/transaction_repository.dart';
import '../database/repositories/wallet_repository.dart';

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

final activeRecurringProvider = StreamProvider<List<RecurringTransaction>>(
    (ref) => ref.watch(recurringRepositoryProvider).watchActive());

final currencyCodeProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  final currency = await repo.get('currency');
  return currency ?? 'USD';
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
  final repo = ref.watch(walletRepositoryProvider);
  return repo.totalBalance();
});

final budgetLimitsProvider =
    StreamProvider.family<List<BudgetCategoryLimit>, int>((ref, budgetId) {
  return ref.watch(budgetRepositoryProvider).watchLimits(budgetId);
});

final spentByCategoryProvider = FutureProvider.family<Map<int, int>, String>(
    (ref, key) async {
  final parts = key.split(',');
  final start = DateTime.parse(parts[0]);
  final end = DateTime.parse(parts[1]);
  return ref
      .watch(transactionRepositoryProvider)
      .spentByCategory(start, end);
});

final monthlyIncomeProvider = FutureProvider.family<int, String>((ref, key) async {
  final parts = key.split(',');
  final start = DateTime.parse(parts[0]);
  final end = DateTime.parse(parts[1]);
  return ref.watch(transactionRepositoryProvider).totalIncome(start, end);
});

final monthlyExpensesProvider = FutureProvider.family<int, String>((ref, key) async {
  final parts = key.split(',');
  final start = DateTime.parse(parts[0]);
  final end = DateTime.parse(parts[1]);
  return ref.watch(transactionRepositoryProvider).totalExpenses(start, end);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/repositories/budget_repository.dart';
import '../database/repositories/category_repository.dart';
import '../database/repositories/recurring_repository.dart';
import '../database/repositories/settings_repository.dart';
import '../database/repositories/transaction_repository.dart';
import '../database/repositories/wallet_repository.dart';

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

final totalBalanceProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.totalBalance();
});

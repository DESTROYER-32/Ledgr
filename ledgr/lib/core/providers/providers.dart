import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/repositories/associated_title_repository.dart';
import '../database/repositories/budget_repository.dart';
import '../database/repositories/category_repository.dart';
import '../database/repositories/delete_log_repository.dart';
import '../database/repositories/objective_repository.dart';
import '../database/repositories/recurring_repository.dart';
import '../security/app_lock_controller.dart';
import '../services/backup_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/recurring_service.dart';
import '../database/repositories/settings_repository.dart';
import '../database/repositories/transaction_repository.dart';
import '../database/repositories/wallet_repository.dart';
import '../utils/currency_utils.dart';
import '../utils/money_utils.dart';

class ThemeConfig {
  final ThemeMode themeMode;
  final bool amoled;
  final Color seedColor;
  final String fontFamily;
  final double animationSpeed;
  final bool outlinedIcons;
  const ThemeConfig({
    required this.themeMode,
    this.amoled = false,
    required this.seedColor,
    this.fontFamily = 'System',
    this.animationSpeed = 1.0,
    this.outlinedIcons = false,
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(exchangeRateServiceProvider),
  );
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

final appLockControllerProvider = ChangeNotifierProvider<AppLockController>((
  ref,
) {
  return AppLockController(ref.watch(settingsRepositoryProvider));
});

final appLockStateProvider = Provider<AppLockState>((ref) {
  return ref.watch(appLockControllerProvider).state;
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    ref.watch(appDatabaseProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final objectiveRepositoryProvider = Provider<ObjectiveRepository>((ref) {
  return ObjectiveRepository(ref.watch(appDatabaseProvider));
});

final associatedTitleRepositoryProvider = Provider<AssociatedTitleRepository>((
  ref,
) {
  return AssociatedTitleRepository(ref.watch(appDatabaseProvider));
});

final deleteLogRepositoryProvider = Provider<DeleteLogRepository>((ref) {
  return DeleteLogRepository(ref.watch(appDatabaseProvider));
});

final recurringServiceProvider = Provider<RecurringService>((ref) {
  return RecurringService(
    ref.watch(recurringRepositoryProvider),
    ref.watch(transactionRepositoryProvider),
    ref.watch(walletRepositoryProvider),
  );
});

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  final service = ExchangeRateService(ref.watch(settingsRepositoryProvider));
  ref.onDispose(service.close);
  return service;
});

final exchangeRatesRefreshProvider = StateProvider<int>((ref) => 0);

final exchangeRatesProvider = FutureProvider<Map<String, double>>((ref) async {
  final count = ref.watch(exchangeRatesRefreshProvider);
  final service = ref.watch(exchangeRateServiceProvider);
  return service.getAllRates(refresh: count > 0);
});

final favoriteCurrenciesProvider = FutureProvider<List<String>>((ref) async {
  final raw = await ref
      .watch(settingsRepositoryProvider)
      .get('favorite_currencies');
  if (raw == null || raw.isEmpty) return CurrencyUtils.codes;

  try {
    final decoded = json.decode(raw);
    if (decoded is List) {
      final favorites = decoded
          .whereType<String>()
          .map((code) => code.toUpperCase())
          .where(CurrencyUtils.codes.contains)
          .toSet()
          .toList();
      return favorites.isEmpty ? CurrencyUtils.codes : favorites;
    }
  } catch (_) {
    // Fall back to every currency if stored settings are invalid.
  }

  return CurrencyUtils.codes;
});

List<String> currencyOptionsWithSelection(
  List<String> favoriteCurrencies,
  String? selectedCurrency,
) {
  final options = favoriteCurrencies
      .where(CurrencyUtils.codes.contains)
      .toSet()
      .toList();
  if (selectedCurrency != null &&
      CurrencyUtils.codes.contains(selectedCurrency) &&
      !options.contains(selectedCurrency)) {
    options.insert(0, selectedCurrency);
  }
  return options.isEmpty ? CurrencyUtils.codes : options;
}

final displayCurrencyProvider = FutureProvider<String>((ref) async {
  final setting = await ref
      .watch(settingsRepositoryProvider)
      .get('display_currency');
  if (setting != null) return setting;
  return MoneyUtils.defaultCurrencyCode;
});

final showDefaultCurrencyProvider = FutureProvider<bool>((ref) async {
  final setting = await ref
      .watch(settingsRepositoryProvider)
      .get('show_default_currency');
  return setting != 'false';
});

final userNameProvider = FutureProvider<String?>((ref) async {
  final name = await ref.watch(settingsRepositoryProvider).get('user_name');
  final trimmed = name?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
});

// Stream providers for reactive queries
final activeWalletsProvider = StreamProvider<List<Wallet>>(
  (ref) => ref.watch(walletRepositoryProvider).watchActive(),
);

final allWalletsProvider = StreamProvider<List<Wallet>>(
  (ref) => ref.watch(walletRepositoryProvider).watchAll(),
);

final allTransactionsProvider = StreamProvider<List<Transaction>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchAll(),
);

final recentTransactionsProvider = StreamProvider<List<Transaction>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchRecent(limit: 50),
);

final activeCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchActive(),
);

final parentCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchParents(),
);

final expenseCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchByKind('expense'),
);

final incomeCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchByKind('income'),
);

final allBudgetsProvider = StreamProvider<List<Budget>>(
  (ref) => ref.watch(budgetRepositoryProvider).watchAll(),
);

final activeRecurringProvider = StreamProvider<List<RecurringTransaction>>(
  (ref) => ref.watch(recurringRepositoryProvider).watchActive(),
);

final defaultWalletIdProvider = FutureProvider<int?>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  final walletId = await repo.get('default_wallet_id');
  return walletId == null ? null : int.tryParse(walletId);
});

final themeConfigProvider = FutureProvider<ThemeConfig>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  final modeStr = await repo.get('theme_mode');
  final seedStr = await repo.get('theme_seed');
  final fontStr = await repo.get('font_family');
  final animStr = await repo.get('animation_speed');
  final iconStr = await repo.get('outlined_icons');
  final amoled = modeStr == 'amoled';
  final mode = switch (modeStr) {
    'light' => ThemeMode.light,
    'dark' || 'amoled' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
  final seed = Color(int.tryParse(seedStr ?? '') ?? 0xFF1A6D4A);
  final font = fontStr ?? 'System';
  final anim = animStr != null ? double.tryParse(animStr) ?? 1.0 : 1.0;
  final outlined = iconStr == 'true';
  return ThemeConfig(
    themeMode: mode,
    amoled: amoled,
    seedColor: seed,
    fontFamily: font,
    animationSpeed: anim,
    outlinedIcons: outlined,
  );
});

final totalBalanceProvider = FutureProvider<int>((ref) async {
  ref.watch(activeWalletsProvider);
  ref.watch(allTransactionsProvider);
  ref.watch(exchangeRatesProvider);
  final repo = ref.watch(walletRepositoryProvider);
  final wallets = await repo.getAll();
  final rateService = ref.watch(exchangeRateServiceProvider);
  final displayCurrency = await ref.watch(displayCurrencyProvider.future);
  var total = 0;
  for (final w in wallets) {
    if (w.archived) continue;
    final balance = await repo.balanceForWallet(w.id);
    total += await rateService.convert(
      balance,
      w.currencyCode,
      displayCurrency,
    );
  }
  return total;
});

Future<Map<int, int>> walletBalancesByWalletCurrency(
  WalletRepository repo,
) async {
  final wallets = await repo.getAll();
  final map = <int, int>{};
  for (final w in wallets) {
    final balance = await repo.balanceForWallet(w.id);
    map[w.id] = balance;
  }
  return map;
}

final walletBalancesProvider = FutureProvider<Map<int, int>>((ref) async {
  ref.watch(activeWalletsProvider);
  ref.watch(allTransactionsProvider);
  ref.watch(exchangeRatesProvider);
  final repo = ref.watch(walletRepositoryProvider);
  return walletBalancesByWalletCurrency(repo);
});

final spentByCategoryProvider = FutureProvider.family<Map<int, int>, String>((
  ref,
  key,
) async {
  ref.watch(allTransactionsProvider);
  final parts = key.split(',');
  final start = DateTime.parse(parts[0]);
  final end = DateTime.parse(parts[1]);
  return ref.watch(transactionRepositoryProvider).spentByCategory(start, end);
});

final monthlyIncomeProvider = FutureProvider.family<int, String>((
  ref,
  key,
) async {
  ref.watch(allTransactionsProvider);
  final parts = key.split(',');
  final start = DateTime.parse(parts[0]);
  final end = DateTime.parse(parts[1]);
  return ref.watch(transactionRepositoryProvider).totalIncome(start, end);
});

final allObjectivesProvider = StreamProvider<List<Objective>>(
  (ref) => ref.watch(objectiveRepositoryProvider).watchAll(),
);

final monthlyExpensesProvider = FutureProvider.family<int, String>((
  ref,
  key,
) async {
  ref.watch(allTransactionsProvider);
  final parts = key.split(',');
  final start = DateTime.parse(parts[0]);
  final end = DateTime.parse(parts[1]);
  return ref.watch(transactionRepositoryProvider).totalExpenses(start, end);
});

final deleteLogsProvider = StreamProvider<List<DeleteLog>>(
  (ref) => ref.watch(deleteLogRepositoryProvider).watchAll(),
);

final subcategoriesProvider = StreamProvider.family<List<Category>, int>((
  ref,
  parentId,
) {
  return ref.watch(categoryRepositoryProvider).watchSubcategories(parentId);
});

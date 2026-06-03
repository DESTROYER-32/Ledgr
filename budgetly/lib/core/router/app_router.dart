import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/backup/backup_screen.dart';
import '../../features/budgets/budgets_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/recurring/recurring_screen.dart';
import '../../features/recurring/recurring_form_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/transactions/transaction_form_screen.dart';
import '../../features/categories/category_form_screen.dart';
import '../../features/wallets/wallet_detail_screen.dart';
import '../../features/wallets/wallet_form_screen.dart';
import '../../features/wallets/wallets_screen.dart';
import '../widgets/app_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/budgets',
            name: 'budgets',
            builder: (context, state) => const BudgetsScreen(),
          ),
          GoRoute(
            path: '/wallets',
            name: 'wallets',
            builder: (context, state) => const WalletsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/wallets/new',
        name: 'wallet-new',
        builder: (context, state) => const WalletFormScreen(),
      ),
      GoRoute(
        path: '/wallets/edit/:id',
        name: 'wallet-edit',
        builder: (context, state) => WalletFormScreen(
          walletId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/wallets/:id',
        name: 'wallet-detail',
        builder: (context, state) => WalletDetailScreen(
          walletId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/transactions/new',
        name: 'transaction-new',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TransactionFormScreen(
            preselectedWalletId: extra?['walletId'] as int?,
            preselectedType: extra?['type'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/transactions/:id',
        name: 'transaction-detail',
        builder: (context, state) => TransactionFormScreen(
          transactionId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/categories/new',
        name: 'category-new',
        builder: (context, state) => const CategoryFormScreen(),
      ),
      GoRoute(
        path: '/categories/edit/:id',
        name: 'category-edit',
        builder: (context, state) => CategoryFormScreen(
          categoryId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/backup',
        name: 'backup',
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: '/recurring',
        name: 'recurring',
        builder: (context, state) => const RecurringScreen(),
      ),
      GoRoute(
        path: '/recurring/new',
        name: 'recurring-new',
        builder: (context, state) => const RecurringFormScreen(),
      ),
      GoRoute(
        path: '/recurring/:id',
        name: 'recurring-edit',
        builder: (context, state) => RecurringFormScreen(
          recurringId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
});

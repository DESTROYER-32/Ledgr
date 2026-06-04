import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/backup/backup_screen.dart';
import '../../features/budgets/budget_detail_screen.dart';
import '../../features/budgets/budget_form_screen.dart';
import '../../features/budgets/budgets_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/categories/category_form_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/exchange_rates/exchange_rates_screen.dart';
import '../../features/objectives/objective_detail_screen.dart';
import '../../features/objectives/objective_form_screen.dart';
import '../../features/objectives/objectives_list_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/recurring/recurring_screen.dart';
import '../../features/recurring/recurring_form_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/transactions/transaction_form_screen.dart';
import '../../features/wallets/wallet_detail_screen.dart';
import '../../features/wallets/wallet_form_screen.dart';
import '../../features/wallets/wallets_screen.dart';
import '../../features/smart_labels/associated_titles_screen.dart';
import '../../features/smart_labels/associated_title_form_screen.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/bill_splitter/bill_splitter_screen.dart';
import '../../features/subscriptions/subscriptions_screen.dart';
import '../../features/credit_debt/credit_debt_screen.dart';
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
        path: '/budgets/new',
        name: 'budget-new',
        builder: (context, state) => const BudgetFormScreen(),
      ),
      GoRoute(
        path: '/budgets/:id',
        name: 'budget-detail',
        builder: (context, state) => BudgetDetailScreen(
          budgetId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/budgets/:id/edit',
        name: 'budget-edit',
        builder: (context, state) => BudgetFormScreen(
          budgetId: int.parse(state.pathParameters['id']!),
        ),
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
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CategoryFormScreen(
            preselectedParentId: extra?['parentId'] as int?,
          );
        },
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
      GoRoute(
        path: '/objectives',
        name: 'objectives',
        builder: (context, state) => const ObjectivesListScreen(),
      ),
      GoRoute(
        path: '/objectives/new',
        name: 'objective-new',
        builder: (context, state) => const ObjectiveFormScreen(),
      ),
      GoRoute(
        path: '/objectives/:id',
        name: 'objective-detail',
        builder: (context, state) => ObjectiveDetailScreen(
          objectiveId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/objectives/:id/edit',
        name: 'objective-edit',
        builder: (context, state) => ObjectiveFormScreen(
          objectiveId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/exchange-rates',
        name: 'exchange-rates',
        builder: (context, state) => const ExchangeRatesScreen(),
      ),
      GoRoute(
        path: '/smart-labels',
        name: 'smart-labels',
        builder: (context, state) => const AssociatedTitlesScreen(),
      ),
      GoRoute(
        path: '/smart-labels/new',
        name: 'smart-label-new',
        builder: (context, state) => const AssociatedTitleFormScreen(),
      ),
      GoRoute(
        path: '/smart-labels/:id',
        name: 'smart-label-edit',
        builder: (context, state) => AssociatedTitleFormScreen(
          titleId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/activity',
        name: 'activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      GoRoute(
        path: '/bill-splitter',
        name: 'bill-splitter',
        builder: (context, state) => const BillSplitterScreen(),
      ),
      GoRoute(
        path: '/subscriptions',
        name: 'subscriptions',
        builder: (context, state) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: '/credit-debt',
        name: 'credit-debt',
        builder: (context, state) => const CreditDebtScreen(),
      ),
    ],
  );
});

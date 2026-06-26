import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repositories/transaction_repository.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/balance_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_tile.dart';
import '../../core/widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final displayCurrencyAsync = ref.watch(displayCurrencyProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final exchangeRates = ref.watch(exchangeRatesProvider).valueOrNull ?? {};
    final recurringAsync = ref.watch(activeRecurringProvider);
    final walletsAsync = ref.watch(activeWalletsProvider);
    final walletBalancesAsync = ref.watch(walletBalancesProvider);
    final userNameAsync = ref.watch(userNameProvider);
    final budgetsAsync = ref.watch(allBudgetsProvider);
    final activeBudgets =
        budgetsAsync.valueOrNull
            ?.where((b) => b.periodEnd.isAfter(DateTime.now()))
            .toList() ??
        [];
    final objectivesAsync = ref.watch(allObjectivesProvider);

    return Scaffold(
      appBar: AppBar(
        title: userNameAsync.when(
          data: (name) => Text(dashboardGreeting(name: name)),
          loading: () => const Text('Budgetly'),
          error: (_, _) => const Text('Budgetly'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            onPressed: () => context.push('/recurring'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(totalBalanceProvider);
          ref.invalidate(allTransactionsProvider);
          ref.invalidate(allBudgetsProvider);
          ref.invalidate(activeWalletsProvider);
          ref.invalidate(activeRecurringProvider);
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildSetupCard(context, theme, cs, walletsAsync, ref),
            _buildBalanceCard(
              context,
              theme,
              cs,
              totalBalanceAsync,
              displayCurrencyAsync,
            ),
            const SizedBox(height: 20),
            _buildWalletCards(
              context,
              theme,
              cs,
              walletsAsync,
              walletBalancesAsync,
            ),
            const SizedBox(height: 20),
            _buildMonthlySummary(
              context,
              theme,
              cs,
              transactionsAsync,
              displayCurrencyAsync,
              exchangeRates,
            ),
            const SizedBox(height: 16),
            _buildInsightsCard(
              context,
              theme,
              cs,
              ref,
              displayCurrencyAsync,
              activeBudgets,
            ),
            const SizedBox(height: 24),
            _buildQuickActions(context, cs),
            const SizedBox(height: 24),
            _buildBudgetCards(context, theme, cs, activeBudgets),
            const SizedBox(height: 24),
            _buildGoalsSection(context, theme, cs, objectivesAsync),
            const SizedBox(height: 24),
            _buildSpendingChart(context, theme, cs, ref),
            const SizedBox(height: 24),
            _buildUpcomingRecurring(context, theme, cs, recurringAsync),
            const SizedBox(height: 24),
            _buildRecentTransactions(
              context,
              theme,
              transactionsAsync,
              ref.watch(activeCategoriesProvider),
              displayCurrencyAsync,
              exchangeRates,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AsyncValue<List<Wallet>> walletsAsync,
    WidgetRef ref,
  ) {
    return walletsAsync.when(
      data: (wallets) {
        if (wallets.isNotEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.rocket_launch,
                        color: cs.onPrimaryContainer,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Welcome to Budgetly!',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Set up your first account and categories to get started.',
                    style: TextStyle(color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => context.push('/wallets/new'),
                        icon: const Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                        ),
                        label: const Text('Add Account'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => context.push('/categories'),
                        icon: const Icon(Icons.category, size: 16),
                        label: const Text('Manage Categories'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AsyncValue<int> totalBalanceAsync,
    AsyncValue<String> displayCurrencyAsync,
  ) {
    final currencyCode =
        displayCurrencyAsync.valueOrNull ?? MoneyUtils.defaultCurrencyCode;
    return totalBalanceAsync.when(
      data: (total) {
        return BalanceCard(
          label: 'Total Balance',
          amount: MoneyUtils.format(total, currencyCode: currencyCode),
          icon: Icons.account_balance_wallet,
          accentColor: cs.primary,
          bottom: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: Icon(
                  Icons.account_balance,
                  size: 14,
                  color: cs.primary,
                ),
                label: const Text('Accounts', style: TextStyle(fontSize: 12)),
                onPressed: () => context.push('/wallets'),
              ),
              ActionChip(
                avatar: Icon(Icons.track_changes, size: 14, color: cs.primary),
                label: const Text('Budgets', style: TextStyle(fontSize: 12)),
                onPressed: () => context.push('/budgets'),
              ),
              ActionChip(
                avatar: Icon(Icons.category, size: 14, color: cs.primary),
                label: const Text('Categories', style: TextStyle(fontSize: 12)),
                onPressed: () => context.push('/categories'),
              ),
            ],
          ),
        );
      },
      error: (e, _) =>
          const BalanceCard(label: 'Total Balance', amount: 'Error'),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SizedBox(height: 100, child: LinearProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildWalletCards(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AsyncValue<List<Wallet>> walletsAsync,
    AsyncValue<Map<int, int>> balancesAsync,
  ) {
    final balances = balancesAsync.valueOrNull ?? {};
    return walletsAsync.when(
      data: (wallets) {
        if (wallets.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Accounts',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/wallets'),
                  child: const Text('View All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 148,
              child: PageView.builder(
                clipBehavior: Clip.none,
                itemCount: wallets.length,
                itemBuilder: (_, i) {
                  final w = wallets[i];
                  final balance = balances[w.id] ?? w.initialBalanceMinor;
                  final icon = w.type == 'cash'
                      ? Icons.money
                      : w.type == 'credit_card'
                      ? Icons.credit_card
                      : w.type == 'savings'
                      ? Icons.savings
                      : Icons.account_balance;
                  return _miniWalletCard(context, cs, w, icon, balance);
                },
              ),
            ),
          ],
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }

  Widget _miniWalletCard(
    BuildContext context,
    ColorScheme cs,
    Wallet w,
    IconData icon,
    int balance,
  ) {
    final color = w.color != null ? Color(w.color!) : cs.primary;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/wallets/${w.id}'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 22, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      w.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    w.currencyCode,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                MoneyUtils.format(balance, currencyCode: w.currencyCode),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                w.type.replaceAll('_', ' '),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AsyncValue<List<Objective>> objectivesAsync,
  ) {
    return objectivesAsync.when(
      data: (objectives) {
        final active = objectives.where((o) => !o.archived).toList();
        if (active.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  'Goals & Loans',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/objectives'),
                  child: const Text('View All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 138,
              child: PageView.builder(
                clipBehavior: Clip.none,
                itemCount: active.length,
                itemBuilder: (_, i) => _objectiveCard(context, cs, active[i]),
              ),
            ),
          ],
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }

  Widget _objectiveCard(
    BuildContext context,
    ColorScheme cs,
    Objective objective,
  ) {
    final color = objective.color != null
        ? Color(objective.color!)
        : cs.primary;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/objectives/${objective.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer(
            builder: (context, ref, _) {
              final txRepo = ref.watch(transactionRepositoryProvider);
              return FutureBuilder<List<Transaction>>(
                future: txRepo.getByObjective(objective.id),
                builder: (context, snap) {
                  final total = (snap.data ?? const <Transaction>[]).fold<int>(
                    0,
                    (sum, t) => sum + t.amountMinor,
                  );
                  final progress = objective.amountMinor > 0
                      ? (total / objective.amountMinor).clamp(0.0, 1.0)
                      : 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            objective.type == 'loan'
                                ? Icons.swap_horiz
                                : Icons.flag,
                            color: color,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              objective.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            objective.type == 'loan' ? 'Loan' : 'Goal',
                            style: TextStyle(fontSize: 12, color: color),
                          ),
                        ],
                      ),
                      if (objective.type == 'goal') ...[
                        const Spacer(),
                        Text(
                          '${MoneyUtils.format(total, currencyCode: objective.currencyCode)} / ${MoneyUtils.format(objective.amountMinor, currencyCode: objective.currencyCode)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: cs.surfaceContainerHighest,
                            color: color,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCards(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    List<Budget> activeBudgets,
  ) {
    if (activeBudgets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.track_changes, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              'Budgets',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/budgets'),
              child: const Text('View All', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 138,
          child: PageView.builder(
            clipBehavior: Clip.none,
            itemCount: activeBudgets.length + 1,
            itemBuilder: (_, i) {
              if (i == activeBudgets.length) {
                return _addBudgetCard(context, cs);
              }
              return _budgetCardPreview(context, cs, activeBudgets[i]);
            },
          ),
        ),
      ],
    );
  }

  Widget _budgetCardPreview(
    BuildContext context,
    ColorScheme cs,
    Budget budget,
  ) {
    final color = budget.color != null ? Color(budget.color!) : cs.primary;
    final isGoal = budget.isIncome;
    return GestureDetector(
      onTap: () => context.push('/budgets/${budget.id}'),
      child: Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.08), cs.surface],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isGoal ? Icons.savings : Icons.track_changes,
                    size: 20,
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      budget.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    isGoal ? 'Goal' : 'Budget',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const Spacer(),
              Consumer(
                builder: (context, ref, _) {
                  final txRepo = ref.watch(transactionRepositoryProvider);
                  return FutureBuilder<int>(
                    future: _getBudgetPreviewTotal(txRepo, budget, isGoal),
                    builder: (context, snap) {
                      final total = snap.data ?? 0;
                      if (budget.plannedAmountMinor > 0) {
                        final pct = (total / budget.plannedAmountMinor).clamp(
                          0.0,
                          1.0,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${MoneyUtils.format(total, currencyCode: budget.currencyCode)} / ${MoneyUtils.format(budget.plannedAmountMinor, currencyCode: budget.currencyCode)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: cs.surfaceContainerHighest,
                                color: isGoal ? AppColors.income : cs.primary,
                              ),
                            ),
                          ],
                        );
                      }
                      return Text(
                        '${MoneyUtils.formatDateShort(budget.periodStart)} - ${MoneyUtils.formatDateShort(budget.periodEnd)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addBudgetCard(BuildContext context, ColorScheme cs) {
    return GestureDetector(
      onTap: () => context.push('/budgets/new'),
      child: Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 28,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'Add Budget',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AsyncValue<List<Transaction>> transactionsAsync,
    AsyncValue<String> displayCurrencyAsync,
    Map<String, double> exchangeRates,
  ) {
    final currencyCode =
        displayCurrencyAsync.valueOrNull ?? MoneyUtils.defaultCurrencyCode;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return transactionsAsync.when(
      data: (transactions) {
        var income = 0;
        var expenses = 0;
        for (final t in transactions) {
          if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
          if (t.date.isAfter(todayEnd)) continue;
          final converted = MoneyUtils.convertMinor(
            t.amountMinor,
            fromCurrency: t.currencyCode,
            toCurrency: currencyCode,
            rates: exchangeRates,
          );
          if (t.type == 'income') income += converted;
          if (t.type == 'expense') expenses += converted;
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Month',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.arrow_downward,
                        label: 'Income',
                        value: MoneyUtils.format(
                          income,
                          currencyCode: currencyCode,
                        ),
                        color: AppColors.income,
                      ),
                    ),
                    Container(width: 1, height: 40, color: cs.outlineVariant),
                    Expanded(
                      child: StatTile(
                        icon: Icons.arrow_upward,
                        label: 'Expenses',
                        value: MoneyUtils.format(
                          expenses,
                          currencyCode: currencyCode,
                        ),
                        color: AppColors.expense,
                      ),
                    ),
                    Container(width: 1, height: 40, color: cs.outlineVariant),
                    Expanded(
                      child: StatTile(
                        icon: Icons.account_balance_wallet,
                        label: 'Net',
                        value: MoneyUtils.format(
                          income - expenses,
                          currencyCode: currencyCode,
                        ),
                        color: income - expenses >= 0
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      error: (_, _) => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Error loading summary'),
        ),
      ),
      loading: () => _loadingCard,
    );
  }

  static Future<int> _getBudgetPreviewTotal(
    TransactionRepository txRepo,
    Budget budget,
    bool isGoal,
  ) async {
    if (budget.specificMode) {
      final txns = await txRepo.search(
        startDate: budget.periodStart,
        endDate: budget.periodEnd,
        type: isGoal ? 'income' : 'expense',
      );
      return txns
          .where((t) {
            if (t.budgetFks == null) return false;
            final fks = t.budgetFks!
                .split(',')
                .map((s) => int.tryParse(s.trim()))
                .where((n) => n != null)
                .cast<int>()
                .toList();
            return fks.contains(budget.id);
          })
          .fold<int>(0, (sum, t) => sum + t.amountMinor);
    }
    return isGoal
        ? txRepo.totalIncome(budget.periodStart, budget.periodEnd)
        : txRepo.totalExpenses(budget.periodStart, budget.periodEnd);
  }

  static const _loadingCard = Card(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    ),
  );

  Widget _buildQuickActions(BuildContext context, ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            context,
            Icons.arrow_upward,
            'Expense',
            () => context.push(
              '/transactions/new',
              extra: <String, dynamic>{'type': 'expense'},
            ),
            AppColors.expense,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            context,
            Icons.arrow_downward,
            'Income',
            () => context.push(
              '/transactions/new',
              extra: <String, dynamic>{'type': 'income'},
            ),
            AppColors.income,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            context,
            Icons.swap_horiz,
            'Transfer',
            () => context.push(
              '/transactions/new',
              extra: <String, dynamic>{'type': 'transfer'},
            ),
            AppColors.transfer,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    WidgetRef ref,
    AsyncValue<String> displayCurrencyAsync,
    List<Budget> activeBudgets,
  ) {
    final currencyCode =
        displayCurrencyAsync.valueOrNull ?? MoneyUtils.defaultCurrencyCode;
    return FutureBuilder<_DashboardInsights>(
      future: _loadInsights(ref, activeBudgets),
      builder: (context, snapshot) {
        final insights = snapshot.data;
        if (insights == null) return _loadingCard;
        if (!insights.hasData) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Insights',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (insights.previousExpenses > 0)
                  _InsightRow(
                    icon: insights.expenseDelta >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    text:
                        'Expenses are ${insights.expenseDelta.abs().toStringAsFixed(0)}% ${insights.expenseDelta >= 0 ? 'higher' : 'lower'} than last month.',
                  ),
                if (insights.largestExpense != null)
                  _InsightRow(
                    icon: Icons.receipt_long,
                    text:
                        'Largest expense: ${insights.largestExpense!.title ?? 'Untitled'} at ${MoneyUtils.format(insights.largestExpense!.amountMinor, currencyCode: insights.largestExpense!.currencyCode)}.',
                  ),
                if (insights.rolloverPreview != 0)
                  _InsightRow(
                    icon: Icons.sync_alt,
                    text:
                        'Budget rollover preview: ${MoneyUtils.format(insights.rolloverPreview, currencyCode: currencyCode)} ${insights.rolloverPreview >= 0 ? 'available' : 'overspent'} across active budgets.',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<_DashboardInsights> _loadInsights(
    WidgetRef ref,
    List<Budget> activeBudgets,
  ) async {
    final txRepo = ref.read(transactionRepositoryProvider);
    final now = DateTime.now();
    final currentStart = DateTime(now.year, now.month, 1);
    final currentEnd = DateTime(now.year, now.month + 1, 0);
    final previousStart = DateTime(now.year, now.month - 1, 1);
    final previousEnd = DateTime(now.year, now.month, 0);
    final currentExpenses = await txRepo.totalExpenses(
      currentStart,
      currentEnd,
    );
    final previousExpenses = await txRepo.totalExpenses(
      previousStart,
      previousEnd,
    );
    final currentExpenseRows = await txRepo.search(
      startDate: currentStart,
      endDate: currentEnd,
      type: 'expense',
      specialType: 'none',
    );
    currentExpenseRows.sort((a, b) => b.amountMinor.compareTo(a.amountMinor));
    var rolloverPreview = 0;
    for (final budget in activeBudgets.where((b) => !b.isIncome)) {
      final spent = await _getBudgetPreviewTotal(txRepo, budget, false);
      rolloverPreview += budget.plannedAmountMinor - spent;
    }
    return _DashboardInsights(
      currentExpenses: currentExpenses,
      previousExpenses: previousExpenses,
      largestExpense: currentExpenseRows.firstOrNull,
      rolloverPreview: rolloverPreview,
    );
  }

  Widget _actionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    Color color,
  ) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingChart(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    WidgetRef ref,
  ) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    final periodKey = '${start.toIso8601String()},${end.toIso8601String()}';
    final spentAsync = ref.watch(spentByCategoryProvider(periodKey));
    final catsAsync = ref.watch(activeCategoriesProvider);

    return spentAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();
        return catsAsync.when(
          data: (cats) {
            final catMap = {for (final c in cats) c.id: c};
            final sorted = data.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final top = sorted.take(5).toList();
            final totalSpent = data.values.fold<int>(0, (s, v) => s + v);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Spending',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sections: top.map((e) {
                                  final cat = catMap[e.key];
                                  final color = cat?.color != null
                                      ? Color(cat!.color!)
                                      : cs.primary;
                                  final pct = e.value / totalSpent;
                                  return PieChartSectionData(
                                    value: pct * 100,
                                    color: color,
                                    radius: 28,
                                    title: '${(pct * 100).toStringAsFixed(0)}%',
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: top.map((e) {
                                final cat = catMap[e.key];
                                final color = cat?.color != null
                                    ? Color(cat!.color!)
                                    : cs.primary;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          cat?.name ?? 'Cat ${e.key}',
                                          style: const TextStyle(fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (e, _) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        );
      },
      error: (e, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }

  Widget _buildUpcomingRecurring(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AsyncValue<List<RecurringTransaction>> recurringAsync,
  ) {
    return recurringAsync.when(
      data: (items) {
        final active = items.where((r) => r.active).take(3).toList();
        if (active.isEmpty) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.repeat, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Upcoming',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/recurring'),
                      child: const Text(
                        'Manage',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...active.map((r) {
                  final isExpense = r.transactionType == 'expense';
                  final isIncome = r.transactionType == 'income';
                  final color = isExpense
                      ? AppColors.expense
                      : (isIncome ? AppColors.income : AppColors.transfer);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isExpense
                                ? Icons.arrow_upward
                                : (isIncome
                                      ? Icons.arrow_downward
                                      : Icons.swap_horiz),
                            color: color,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            r.title ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        if (r.nextDueDate != null)
                          Text(
                            MoneyUtils.formatDateShort(r.nextDueDate!),
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          MoneyUtils.format(r.amountMinor),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      error: (e, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<Transaction>> transactionsAsync,
    AsyncValue<List<Category>> categoriesAsync,
    AsyncValue<String> displayCurrencyAsync,
    Map<String, double> exchangeRates,
  ) {
    final displayCurrency =
        displayCurrencyAsync.valueOrNull ?? MoneyUtils.defaultCurrencyCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Transaction History',
          actionLabel: 'See All',
          onAction: () => context.push('/transactions'),
        ),
        transactionsAsync.when(
          data: (transactions) {
            final categoriesById = {
              for (final c in categoriesAsync.valueOrNull ?? <Category>[])
                c.id: c,
            };
            final now = DateTime.now();
            final todayEnd = DateTime(
              now.year,
              now.month,
              now.day,
              23,
              59,
              59,
              999,
            );
            final visibleTransactions =
                transactions.where((t) => !t.date.isAfter(todayEnd)).toList()
                  ..sort((a, b) => b.date.compareTo(a.date));

            if (visibleTransactions.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 40,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions yet. Tap + to add one.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final grouped = <String, List<Transaction>>{};
            for (final t in visibleTransactions) {
              final key =
                  '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
              grouped.putIfAbsent(key, () => []).add(t);
            }
            final sortedKeys = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));
            final monthNames = [
              '',
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec',
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedKeys.take(3).expand((key) {
                final parts = key.split('-');
                final year = int.parse(parts[0]);
                final month = int.parse(parts[1]);
                final txns = grouped[key]!;
                return [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                    child: Text(
                      '${monthNames[month]} $year',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ...txns.take(10).map((t) {
                    final category = t.categoryId == null
                        ? null
                        : categoriesById[t.categoryId];
                    final converted = MoneyUtils.convertMinor(
                      t.amountMinor,
                      fromCurrency: t.currencyCode,
                      toCurrency: displayCurrency,
                      rates: exchangeRates,
                    );
                    return TransactionTile(
                      id: t.id,
                      type: t.type,
                      amountMinor: t.amountMinor,
                      title: t.title,
                      date: t.date,
                      currencyCode: t.currencyCode,
                      displayAmountMinor: converted,
                      displayCurrencyCode: displayCurrency,
                      categoryName: category?.name,
                      categoryColor: category?.color == null
                          ? null
                          : Color(category!.color!),
                      categoryIcon: category?.icon,
                      onTap: () => context.push('/transactions/${t.id}'),
                    );
                  }),
                ];
              }).toList(),
            );
          },
          error: (e, _) => Center(child: Text('$e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

@visibleForTesting
String dashboardGreeting({String? name, DateTime? now}) {
  final trimmedName = name?.trim();
  if (trimmedName == null || trimmedName.isEmpty) return 'Budgetly';

  final hour = (now ?? DateTime.now()).hour;
  final period = switch (hour) {
    >= 5 && < 12 => 'Good morning',
    >= 12 && < 17 => 'Good afternoon',
    _ => 'Good evening',
  };
  return '$period, $trimmedName';
}

class _DashboardInsights {
  const _DashboardInsights({
    required this.currentExpenses,
    required this.previousExpenses,
    required this.largestExpense,
    required this.rolloverPreview,
  });

  final int currentExpenses;
  final int previousExpenses;
  final Transaction? largestExpense;
  final int rolloverPreview;

  bool get hasData =>
      currentExpenses != 0 ||
      previousExpenses != 0 ||
      largestExpense != null ||
      rolloverPreview != 0;

  double get expenseDelta => previousExpenses == 0
      ? 0
      : ((currentExpenses - previousExpenses) / previousExpenses) * 100;
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

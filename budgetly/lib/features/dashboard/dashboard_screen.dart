import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/database/app_database.dart';
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
    final recentAsync = ref.watch(recentTransactionsProvider);
    final recurringAsync = ref.watch(activeRecurringProvider);
    final walletsAsync = ref.watch(activeWalletsProvider);
    final walletBalancesAsync = ref.watch(walletBalancesProvider);
    final pinnedBudgets = ref.watch(pinnedBudgetsProvider);
    final budgetsAsync = ref.watch(allBudgetsProvider);
    final objectivesAsync = ref.watch(allObjectivesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgetly'),
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
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(allBudgetsProvider);
          ref.invalidate(activeWalletsProvider);
          ref.invalidate(activeRecurringProvider);
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildSetupCard(context, theme, cs, walletsAsync, ref),
            _buildBalanceCard(context, theme, cs, totalBalanceAsync),
            const SizedBox(height: 20),
            _buildWalletCards(context, theme, cs, walletsAsync, walletBalancesAsync),
            const SizedBox(height: 20),
            _buildMonthlySummary(context, theme, cs, ref),
            const SizedBox(height: 24),
            _buildQuickActions(context, cs),
            const SizedBox(height: 24),
            _buildBudgetCards(context, theme, cs, pinnedBudgets, budgetsAsync),
            const SizedBox(height: 24),
            _buildGoalsSection(context, theme, cs, objectivesAsync),
            const SizedBox(height: 24),
            _buildSpendingChart(context, theme, cs, ref),
            const SizedBox(height: 24),
            _buildUpcomingRecurring(context, theme, cs, recurringAsync),
            const SizedBox(height: 24),
            _buildRecentTransactions(context, theme, recentAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupCard(BuildContext context, ThemeData theme,
      ColorScheme cs, AsyncValue<List<Wallet>> walletsAsync, WidgetRef ref) {
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
                      Icon(Icons.rocket_launch, color: cs.onPrimaryContainer, size: 24),
                      const SizedBox(width: 12),
                      Text('Welcome to Budgetly!',
                          style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Set up your first account and categories to get started.',
                      style: TextStyle(color: cs.onPrimaryContainer)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => context.push('/wallets/new'),
                        icon: const Icon(Icons.account_balance_wallet, size: 16),
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

  Widget _buildBalanceCard(BuildContext context, ThemeData theme,
      ColorScheme cs, AsyncValue<int> totalBalanceAsync) {
    return totalBalanceAsync.when(
      data: (total) {
        return BalanceCard(
          label: 'Total Balance',
          amount: MoneyUtils.format(total),
          icon: Icons.account_balance_wallet,
          accentColor: cs.primary,
          bottom: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: Icon(Icons.account_balance,
                    size: 14, color: cs.primary),
                label: const Text('Accounts',
                    style: TextStyle(fontSize: 12)),
                onPressed: () => context.push('/wallets'),
              ),
              ActionChip(
                avatar: Icon(Icons.track_changes,
                    size: 14, color: cs.primary),
                label: const Text('Budgets',
                    style: TextStyle(fontSize: 12)),
                onPressed: () => context.push('/budgets'),
              ),
              ActionChip(
                avatar: Icon(Icons.category,
                    size: 14, color: cs.primary),
                label: const Text('Categories',
                    style: TextStyle(fontSize: 12)),
                onPressed: () => context.push('/categories'),
              ),
            ],
          ),
        );
      },
      error: (e, _) => const BalanceCard(
          label: 'Total Balance', amount: 'Error'),
      loading: () => const Card(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                  height: 100,
                  child: LinearProgressIndicator()))),
    );
  }

  Widget _buildWalletCards(BuildContext context, ThemeData theme,
      ColorScheme cs, AsyncValue<List<Wallet>> walletsAsync,
      AsyncValue<Map<int, int>> balancesAsync) {
    final balances = balancesAsync.valueOrNull ?? {};
    return walletsAsync.when(
      data: (wallets) {
        if (wallets.length < 2) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Accounts',
                    style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                )),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/wallets'),
                  child: const Text('View All',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: wallets.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final w = wallets[i];
                  final balance = balances[w.id] ?? w.initialBalanceMinor;
                  final icon = w.type == 'cash'
                      ? Icons.money
                      : w.type == 'credit'
                          ? Icons.credit_card
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

  Widget _miniWalletCard(BuildContext context, ColorScheme cs, Wallet w,
      IconData icon, int balance) {
    return GestureDetector(
      onTap: () => context.push('/wallets/${w.id}'),
      child: Card(
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: cs.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(w.name,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                MoneyUtils.format(balance, currencyCode: w.currencyCode),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
              Text(w.currencyCode,
                  style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context, ThemeData theme,
      ColorScheme cs, AsyncValue<List<Objective>> objectivesAsync) {
    return objectivesAsync.when(
      data: (objectives) {
        final active = objectives.where((o) => !o.archived).take(3).toList();
        if (active.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text('Goals & Loans',
                    style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                )),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/objectives'),
                  child: const Text('View All',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...active.map((o) => _objectiveRow(context, cs, o)),
          ],
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }

  Widget _objectiveRow(BuildContext context, ColorScheme cs, Objective objective) {
    final color = objective.color != null ? Color(objective.color!) : cs.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/objectives/${objective.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  objective.type == 'loan' ? Icons.swap_horiz : Icons.flag,
                  color: color, size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(objective.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        objective.type == 'loan' ? 'Loan' : 'Goal',
                        style: TextStyle(fontSize: 11,
                            color: objective.type == 'loan'
                                ? cs.error : cs.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCards(
      BuildContext context,
      ThemeData theme,
      ColorScheme cs,
      List<Budget> pinnedBudgets,
      AsyncValue<List<Budget>> budgetsAsync) {
    if (pinnedBudgets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.track_changes,
                size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text('Budgets',
                style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            )),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/budgets'),
              child: const Text('View All',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pinnedBudgets.length + 1,
            separatorBuilder: (_, _) =>
                const SizedBox(width: 10),
            itemBuilder: (_, i) {
              if (i == pinnedBudgets.length) {
                return _addBudgetCard(context, cs);
              }
              final b = pinnedBudgets[i];
              return _budgetCardPreview(context, cs, b);
            },
          ),
        ),
      ],
    );
  }

  Widget _budgetCardPreview(
      BuildContext context, ColorScheme cs, Budget budget) {
    final color = budget.color != null
        ? Color(budget.color!)
        : cs.primary;
    final isIncome = budget.isIncome;
    return GestureDetector(
      onTap: () => context.push('/budgets/${budget.id}'),
      child: Card(
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.08),
                cs.surface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes,
                      size: 14, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(budget.name,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isIncome ? 'Savings' : 'Expense',
                style: TextStyle(
                  fontSize: 10,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${MoneyUtils.formatDateShort(budget.periodStart)} - ${MoneyUtils.formatDateShort(budget.periodEnd)}',
                style: TextStyle(
                    fontSize: 10, color: cs.onSurfaceVariant),
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
          width: 100,
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline,
                  size: 24, color: cs.onSurfaceVariant),
              const SizedBox(height: 6),
              Text('Add Budget',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, ThemeData theme,
      ColorScheme cs, WidgetRef ref) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    final periodKey = '${start.toIso8601String()},${end.toIso8601String()}';
    final incomeAsync = ref.watch(monthlyIncomeProvider(periodKey));
    final expensesAsync = ref.watch(monthlyExpensesProvider(periodKey));

    return incomeAsync.when(
      data: (income) {
        return expensesAsync.when(
          data: (expenses) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Month',
                        style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    )),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            icon: Icons.arrow_downward,
                            label: 'Income',
                            value: MoneyUtils.format(income),
                            color: AppColors.income,
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 40,
                            color: cs.outlineVariant),
                        Expanded(
                          child: StatTile(
                            icon: Icons.arrow_upward,
                            label: 'Expenses',
                            value: MoneyUtils.format(expenses),
                            color: AppColors.expense,
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 40,
                            color: cs.outlineVariant),
                        Expanded(
                          child: StatTile(
                            icon: Icons.account_balance_wallet,
                            label: 'Net',
                            value: MoneyUtils.format(income - expenses),
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
          error: (_, _) => const Card(child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('Error loading expenses'),
          )),
          loading: () => _loadingCard,
        );
      },
      error: (_, _) => const Card(child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('Error loading income'),
      )),
      loading: () => _loadingCard,
    );
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
            () => context.push('/transactions/new',
                extra: <String, dynamic>{'type': 'expense'}),
            AppColors.expense,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            context,
            Icons.arrow_downward,
            'Income',
            () => context.push('/transactions/new',
                extra: <String, dynamic>{'type': 'income'}),
            AppColors.income,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            context,
            Icons.swap_horiz,
            'Transfer',
            () => context.push('/transactions/new',
                extra: <String, dynamic>{'type': 'transfer'}),
            AppColors.transfer,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, IconData icon,
      String label, VoidCallback onTap, Color color) {
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
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingChart(BuildContext context, ThemeData theme,
      ColorScheme cs, WidgetRef ref) {
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
            final totalSpent =
                data.values.fold<int>(0, (s, v) => s + v);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top Spending',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    )),
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
                                  final pct = e.value /
                                      totalSpent;
                                  return PieChartSectionData(
                                    value: pct * 100,
                                    color: color,
                                    radius: 28,
                                    title:
                                        '${(pct * 100).toStringAsFixed(0)}%',
                                    titleStyle:
                                        const TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.bold,
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
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: top.map((e) {
                                final cat = catMap[e.key];
                                final color = cat?.color != null
                                    ? Color(cat!.color!)
                                    : cs.primary;
                                return Padding(
                                  padding: const EdgeInsets
                                      .symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape:
                                              BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(
                                          width: 6),
                                      Expanded(
                                        child: Text(
                                          cat?.name ??
                                              'Cat ${e.key}',
                                          style:
                                              const TextStyle(
                                                  fontSize:
                                                      11),
                                          overflow: TextOverflow
                                              .ellipsis,
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
      AsyncValue<List<RecurringTransaction>> recurringAsync) {
    return recurringAsync.when(
      data: (items) {
        final active =
            items.where((r) => r.active).take(3).toList();
        if (active.isEmpty) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.repeat,
                        size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Text('Upcoming',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    )),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          context.push('/recurring'),
                      child: const Text('Manage',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...active.map((r) {
                  final isExpense =
                      r.transactionType == 'expense';
                  final isIncome =
                      r.transactionType == 'income';
                  final color = isExpense
                      ? AppColors.expense
                      : (isIncome
                          ? AppColors.income
                          : AppColors.transfer);
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                color.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(8),
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
                          child: Text(r.title ?? '',
                              style:
                                  const TextStyle(fontSize: 13)),
                        ),
                        if (r.nextDueDate != null)
                          Text(
                            MoneyUtils.formatDateShort(
                                r.nextDueDate!),
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

  Widget _buildRecentTransactions(BuildContext context,
      ThemeData theme, AsyncValue<List<Transaction>> recentAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Transaction History',
          actionLabel: 'See All',
          onAction: () => context.push('/search'),
        ),
        recentAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long,
                            size: 40,
                            color:
                                theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions yet. Tap + to add one.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color: theme
                                .colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final grouped = <String, List<Transaction>>{};
            for (final t in transactions) {
              final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
              grouped.putIfAbsent(key, () => []).add(t);
            }
            final sortedKeys = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));
            final monthNames = [
              '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                ...txns.take(10).map((t) => TransactionTile(
                      id: t.id,
                      type: t.type,
                      amountMinor: t.amountMinor,
                      title: t.title,
                      date: t.date,
                      onTap: () =>
                          context.push('/transactions/${t.id}'),
                    )),
              ];
            }).toList());
          },
          error: (e, _) =>
              Center(child: Text('$e')),
          loading: () => const Center(
              child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

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
    final walletsAsync = ref.watch(activeWalletsProvider);
    final recentAsync = ref.watch(recentTransactionsProvider);
    final recurringAsync = ref.watch(activeRecurringProvider);

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
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildBalanceCard(context, theme, cs, walletsAsync),
            const SizedBox(height: 20),
            _buildMonthlySummary(context, theme, cs, ref),
            const SizedBox(height: 24),
            _buildQuickActions(context, cs),
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

  Widget _buildBalanceCard(BuildContext context, ThemeData theme,
      ColorScheme cs, AsyncValue<List<Wallet>> walletsAsync) {
    return walletsAsync.when(
      data: (wallets) {
        final total = wallets.fold<int>(
            0, (s, w) => s + w.initialBalanceMinor);
        return BalanceCard(
          label: 'Total Balance',
          amount: MoneyUtils.format(total),
          icon: Icons.account_balance_wallet,
          accentColor: cs.primary,
          bottom: Row(
            children: [
              ActionChip(
                avatar: Icon(Icons.account_balance,
                    size: 14, color: cs.primary),
                label: const Text('Accounts',
                    style: TextStyle(fontSize: 12)),
                onPressed: () => context.push('/wallets'),
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: Icon(Icons.track_changes,
                    size: 14, color: cs.primary),
                label: const Text('Budgets',
                    style: TextStyle(fontSize: 12)),
                onPressed: () => context.push('/budgets'),
              ),
              const SizedBox(width: 8),
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

  Widget _buildMonthlySummary(BuildContext context, ThemeData theme,
      ColorScheme cs, WidgetRef ref) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    final repo = ref.read(transactionRepositoryProvider);

    return FutureBuilder<List<int>>(
      future: Future.wait([
        repo.totalIncome(start, end),
        repo.totalExpenses(start, end)
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(
                    3,
                    (_) => const Expanded(
                        child: Column(children: [
                      SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2)),
                    ]))),
              ),
            ),
          );
        }
        final income = snapshot.data![0];
        final expenses = snapshot.data![1];
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
    );
  }

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

    return FutureBuilder<Map<int, int>>(
      future: ref
          .read(transactionRepositoryProvider)
          .spentByCategory(start, end),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data!;
        final catsAsync = ref.watch(activeCategoriesProvider);

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
          title: 'Recent Transactions',
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
            return Column(
                children: transactions.map((t) {
              return TransactionTile(
                id: t.id,
                type: t.type,
                amountMinor: t.amountMinor,
                title: t.title,
                date: t.date,
                onTap: () =>
                    context.push('/transactions/${t.id}'),
              );
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

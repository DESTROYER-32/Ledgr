import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(activeWalletsProvider);
    final recentAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgetly'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBalanceCard(context, theme, walletsAsync),
            const SizedBox(height: 16),
            _buildMonthlySummary(context, theme, ref),
            const SizedBox(height: 16),
            _buildQuickActions(context, theme),
            const SizedBox(height: 16),
            _buildRecentTransactions(context, theme, recentAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, ThemeData theme, AsyncValue<List<Wallet>> walletsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Balance',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            walletsAsync.when(
              data: (wallets) {
                final total = wallets.fold<int>(0, (s, w) => s + w.initialBalanceMinor);
                return Text(
                  MoneyUtils.format(total),
                  style: theme.textTheme.headlineLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                );
              },
              error: (e, _) => const Text('Error'),
              loading: () =>
                  const SizedBox(height: 32, child: LinearProgressIndicator()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildNavChip(context, Icons.account_balance, 'Accounts', '/wallets'),
                const SizedBox(width: 8),
                _buildNavChip(context, Icons.track_changes, 'Budgets', '/budgets'),
                const SizedBox(width: 8),
                _buildNavChip(context, Icons.category, 'Categories', '/categories'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavChip(BuildContext context, IconData icon, String label, String route) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => context.push(route),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, ThemeData theme, WidgetRef ref) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    final repo = ref.read(transactionRepositoryProvider);

    return FutureBuilder<List<int>>(
      future: Future.wait([repo.totalIncome(start, end), repo.totalExpenses(start, end)]),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(3, (_) => const Expanded(
                  child: Column(children: [
                    SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  ]),
                )),
              ),
            ),
          );
        }
        final income = snapshot.data![0];
        final expenses = snapshot.data![1];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildStat(theme, 'Income', MoneyUtils.format(income), AppColors.income, Icons.arrow_downward)),
                Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
                Expanded(child: _buildStat(theme, 'Expenses', MoneyUtils.format(expenses), AppColors.expense, Icons.arrow_upward)),
                Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
                Expanded(child: _buildStat(theme, 'Net', MoneyUtils.format(income - expenses), income - expenses >= 0 ? AppColors.income : AppColors.expense, Icons.account_balance_wallet)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(ThemeData theme, String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context, theme, Icons.arrow_upward, 'Expense',
            () => context.push('/transactions/new', extra: <String, dynamic>{'type': 'expense'}),
            AppColors.expense,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            context, theme, Icons.arrow_downward, 'Income',
            () => context.push('/transactions/new', extra: <String, dynamic>{'type': 'income'}),
            AppColors.income,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            context, theme, Icons.swap_horiz, 'Transfer',
            () => context.push('/transactions/new', extra: <String, dynamic>{'type': 'transfer'}),
            AppColors.transfer,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, ThemeData theme, IconData icon, String label, VoidCallback onTap, Color color) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(fontSize: 11, color: color),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
      BuildContext context, ThemeData theme, AsyncValue<List<Transaction>> recentAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions', style: theme.textTheme.titleMedium),
            TextButton(
              onPressed: () => context.push('/search'),
              child: const Text('See All'),
            ),
          ],
        ),
        recentAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No transactions yet. Tap + to add one.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: transactions.map((t) {
                final isExpense = t.type == 'expense';
                final isIncome = t.type == 'income';
                final color = isExpense
                    ? AppColors.expense
                    : (isIncome ? AppColors.income : AppColors.transfer);
                final sign = isExpense ? '-' : (isIncome ? '+' : '');
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      radius: 18,
                      child: Icon(
                        isExpense
                            ? Icons.arrow_upward
                            : (isIncome
                                ? Icons.arrow_downward
                                : Icons.swap_horiz),
                        color: color,
                        size: 18,
                      ),
                    ),
                    title: Text(t.title ?? t.type,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(MoneyUtils.formatDateShort(t.date),
                        style: const TextStyle(fontSize: 12)),
                    trailing: Text('$sign${MoneyUtils.format(t.amountMinor)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 14)),
                  ),
                );
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

import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class WalletDetailScreen extends ConsumerWidget {
  final int walletId;
  const WalletDetailScreen({super.key, required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(activeWalletsProvider);
    final theme = Theme.of(context);

    return walletsAsync.when(
      data: (wallets) {
        final wallet = wallets.where((w) => w.id == walletId).firstOrNull;
        if (wallet == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Account')),
            body: const Center(child: Text('Account not found')),
          );
        }
        return _buildScaffold(context, ref, wallet, theme);
      },
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: Center(child: Text('$e')),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
    ThemeData theme,
  ) {
    final balanceAsync = ref.watch(walletBalancesProvider);
    final txStream = ref
        .read(transactionRepositoryProvider)
        .watchByWallet(wallet.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              final repo = ref.read(walletRepositoryProvider);
              if (v == 'archive') {
                await repo.archive(wallet.id);
                if (context.mounted) context.pop();
              } else if (v == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete account?'),
                    content: Text('Delete "${wallet.name}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await repo.delete(wallet.id);
                  if (context.mounted) context.pop();
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: txStream,
        builder: (context, snapshot) {
          final transactions = snapshot.data ?? const <Transaction>[];
          return balanceAsync.when(
            data: (balances) {
              final balance = balances[wallet.id] ?? wallet.initialBalanceMinor;
              final analytics = _AccountAnalytics.fromTransactions(
                wallet: wallet,
                transactions: transactions,
              );
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(walletBalancesProvider);
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    _BalanceHero(wallet: wallet, balance: balance),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push(
                              '/wallets/transfer',
                              extra: <String, dynamic>{
                                'fromWalletId': wallet.id,
                              },
                            ),
                            icon: const Icon(Icons.swap_horiz_rounded),
                            label: const Text('Transfer'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showCorrectBalanceDialog(
                              context,
                              ref,
                              wallet,
                              balance,
                            ),
                            icon: const Icon(Icons.tune_rounded),
                            label: const Text('Correct balance'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _AnalyticsOverview(analytics: analytics),
                    const SizedBox(height: 16),
                    _CashflowChart(analytics: analytics),
                    const SizedBox(height: 16),
                    _BreakdownRows(analytics: analytics),
                    const SizedBox(height: 16),
                    _RecentActivity(
                      transactions: transactions.take(8).toList(),
                    ),
                  ],
                ),
              );
            },
            error: (_, _) => const Center(child: Text('Error loading balance')),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/transactions/new',
          extra: <String, dynamic>{'walletId': wallet.id},
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCorrectBalanceDialog(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
    int currentBalance,
  ) async {
    final controller = TextEditingController(
      text: (currentBalance / 100).toStringAsFixed(2),
    );
    final noteController = TextEditingController();
    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Correct balance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the actual balance for ${wallet.name}. Budgetly will add one adjustment transaction for the difference.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Actual balance',
                  prefixText: '${wallet.currencyCode} ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Optional',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final target =
                    ((double.tryParse(controller.text.trim()) ?? 0) * 100)
                        .round();
                final diff = target - currentBalance;
                if (diff == 0) {
                  Navigator.pop(dialogContext, true);
                  return;
                }
                await ref
                    .read(transactionRepositoryProvider)
                    .insert(
                      TransactionsCompanion.insert(
                        type: diff > 0 ? 'income' : 'expense',
                        specialType: const Value('none'),
                        amountMinor: diff.abs(),
                        currencyCode: wallet.currencyCode,
                        date: DateTime.now(),
                        walletId: wallet.id,
                        title: const Value('Balance correction'),
                        note: Value(
                          noteController.text.trim().isEmpty
                              ? null
                              : noteController.text.trim(),
                        ),
                      ),
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (saved == true && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Balance corrected')));
      }
    } finally {
      controller.dispose();
      noteController.dispose();
    }
  }
}

class _BalanceHero extends StatelessWidget {
  final Wallet wallet;
  final int balance;
  const _BalanceHero({required this.wallet, required this.balance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current balance',
            style: theme.textTheme.titleSmall?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: .75),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            MoneyUtils.format(balance, currencyCode: wallet.currencyCode),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${wallet.currencyCode} • ${wallet.type.replaceAll('_', ' ').toUpperCase()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: .72),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsOverview extends StatelessWidget {
  final _AccountAnalytics analytics;
  const _AnalyticsOverview({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _MetricTile(
          title: 'Incoming',
          amount: analytics.incoming,
          currencyCode: analytics.currencyCode,
          icon: Icons.south_west_rounded,
          color: AppColors.income,
        ),
        _MetricTile(
          title: 'Outgoing',
          amount: analytics.outgoing,
          currencyCode: analytics.currencyCode,
          icon: Icons.north_east_rounded,
          color: AppColors.expense,
        ),
        _MetricTile(
          title: 'Net flow',
          amount: analytics.incoming - analytics.outgoing,
          currencyCode: analytics.currencyCode,
          icon: Icons.show_chart_rounded,
          color: analytics.incoming >= analytics.outgoing
              ? AppColors.income
              : Colors.orange,
        ),
        _CountTile(count: analytics.count),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final int amount;
  final String currencyCode;
  final IconData icon;
  final Color color;
  const _MetricTile({
    required this.title,
    required this.amount,
    required this.currencyCode,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: color.withValues(alpha: .14),
              foregroundColor: color,
              child: Icon(icon, size: 19),
            ),
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            Text(
              MoneyUtils.format(amount, currencyCode: currencyCode),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  final int count;
  const _CountTile({required this.count});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: color.withValues(alpha: .14),
              foregroundColor: color,
              child: const Icon(Icons.receipt_long_outlined, size: 19),
            ),
            Text('Activity', style: Theme.of(context).textTheme.labelMedium),
            Text(
              '$count items',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashflowChart extends StatelessWidget {
  final _AccountAnalytics analytics;
  const _CashflowChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      ...analytics.monthlyIncoming.values,
      ...analytics.monthlyOutgoing.values,
    ].fold<int>(0, (a, b) => a > b ? a : b);
    final labels = analytics.monthlyIncoming.keys.toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cashflow',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Last 6 months, incoming and outgoing separated',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 210,
              child: BarChart(
                BarChartData(
                  maxY: (maxValue * 1.2).clamp(1, double.infinity).toDouble(),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            labels[i],
                            style: Theme.of(context).textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < labels.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: (analytics.monthlyIncoming[labels[i]] ?? 0)
                                .toDouble(),
                            color: AppColors.income,
                            width: 9,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          BarChartRodData(
                            toY: (analytics.monthlyOutgoing[labels[i]] ?? 0)
                                .toDouble(),
                            color: AppColors.expense,
                            width: 9,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRows extends StatelessWidget {
  final _AccountAnalytics analytics;
  const _BreakdownRows({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MiniBreakdown(
            title: 'Outgoing',
            entries: analytics.outgoingBreakdown,
            color: AppColors.expense,
            currencyCode: analytics.currencyCode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniBreakdown(
            title: 'Incoming',
            entries: analytics.incomingBreakdown,
            color: AppColors.income,
            currencyCode: analytics.currencyCode,
          ),
        ),
      ],
    );
  }
}

class _MiniBreakdown extends StatelessWidget {
  final String title;
  final List<MapEntry<String, int>> entries;
  final Color color;
  final String currencyCode;
  const _MiniBreakdown({
    required this.title,
    required this.entries,
    required this.color,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (entries.isEmpty)
              Text('No data', style: Theme.of(context).textTheme.bodySmall)
            else
              for (final entry in entries.take(4)) ...[
                Text(
                  entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  MoneyUtils.format(entry.value, currencyCode: currencyCode),
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final List<Transaction> transactions;
  const _RecentActivity({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent activity',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No activity yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final t in transactions) _ActivityTile(transaction: t),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Transaction transaction;
  const _ActivityTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final isIncome = transaction.type == 'income';
    final color = isExpense
        ? AppColors.expense
        : (isIncome ? AppColors.income : AppColors.transfer);
    final sign = isExpense ? '-' : (isIncome ? '+' : '');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(
          isExpense
              ? Icons.arrow_upward
              : (isIncome ? Icons.arrow_downward : Icons.swap_horiz),
          color: color,
          size: 20,
        ),
      ),
      title: Text(transaction.title ?? transaction.type),
      subtitle: Text(MoneyUtils.formatDateShort(transaction.date)),
      trailing: Text(
        '$sign${MoneyUtils.format(transaction.amountMinor)}',
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
      onTap: () => context.push('/transactions/${transaction.id}'),
    );
  }
}

class _AccountAnalytics {
  final String currencyCode;
  final int incoming;
  final int outgoing;
  final int count;
  final Map<String, int> monthlyIncoming;
  final Map<String, int> monthlyOutgoing;
  final List<MapEntry<String, int>> incomingBreakdown;
  final List<MapEntry<String, int>> outgoingBreakdown;

  const _AccountAnalytics({
    required this.currencyCode,
    required this.incoming,
    required this.outgoing,
    required this.count,
    required this.monthlyIncoming,
    required this.monthlyOutgoing,
    required this.incomingBreakdown,
    required this.outgoingBreakdown,
  });

  factory _AccountAnalytics.fromTransactions({
    required Wallet wallet,
    required List<Transaction> transactions,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 5);
    final monthlyIncoming = <String, int>{};
    final monthlyOutgoing = <String, int>{};
    final incomingBreakdown = <String, int>{};
    final outgoingBreakdown = <String, int>{};
    var incoming = 0;
    var outgoing = 0;
    var count = 0;

    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i);
      monthlyIncoming[_monthKey(d)] = 0;
      monthlyOutgoing[_monthKey(d)] = 0;
    }

    for (final t in transactions) {
      final isIncoming =
          t.type == 'income' ||
          (t.type == 'transfer' && t.transferWalletId == wallet.id);
      final isOutgoing =
          t.type == 'expense' ||
          (t.type == 'transfer' && t.walletId == wallet.id);
      if (!isIncoming && !isOutgoing) continue;
      count++;

      final month = _monthKey(t.date);
      final label = t.type == 'transfer'
          ? (isIncoming ? 'Transfers in' : 'Transfers out')
          : (t.title ?? (isIncoming ? 'Income' : 'Expense'));

      if (isIncoming) {
        incoming += t.amountMinor;
        incomingBreakdown[label] =
            (incomingBreakdown[label] ?? 0) + t.amountMinor;
        if (!t.date.isBefore(start) && monthlyIncoming.containsKey(month)) {
          monthlyIncoming[month] = monthlyIncoming[month]! + t.amountMinor;
        }
      } else {
        outgoing += t.amountMinor;
        outgoingBreakdown[label] =
            (outgoingBreakdown[label] ?? 0) + t.amountMinor;
        if (!t.date.isBefore(start) && monthlyOutgoing.containsKey(month)) {
          monthlyOutgoing[month] = monthlyOutgoing[month]! + t.amountMinor;
        }
      }
    }

    return _AccountAnalytics(
      currencyCode: wallet.currencyCode,
      incoming: incoming,
      outgoing: outgoing,
      count: count,
      monthlyIncoming: monthlyIncoming,
      monthlyOutgoing: monthlyOutgoing,
      incomingBreakdown: _topEntries(incomingBreakdown),
      outgoingBreakdown: _topEntries(outgoingBreakdown),
    );
  }
}

String _monthKey(DateTime date) =>
    '${date.month}/${date.year.toString().substring(2)}';

List<MapEntry<String, int>> _topEntries(Map<String, int> data) {
  final entries = data.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(8).toList();
}

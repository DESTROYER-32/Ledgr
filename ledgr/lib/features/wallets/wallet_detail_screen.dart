import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../core/utils/minor_conversion_cache.dart';
import '../../core/utils/money_utils.dart';

final _walletDetailFilterProvider = StateProvider.autoDispose
    .family<_AccountFilter, int>((ref, walletId) => const _AccountFilter());

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
    final filter = ref.watch(_walletDetailFilterProvider(wallet.id));
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
              final categories =
                  ref.watch(activeCategoriesProvider).valueOrNull ?? [];
              final displayCurrency =
                  ref.watch(displayCurrencyProvider).valueOrNull ??
                  MoneyUtils.defaultCurrencyCode;
              final showDefaultCurrency =
                  ref.watch(showDefaultCurrencyProvider).valueOrNull ?? true;
              final exchangeRates =
                  ref.watch(exchangeRatesProvider).valueOrNull ?? {};
              final categoriesById = {for (final c in categories) c.id: c};
              final analytics = _AccountAnalytics.fromTransactions(
                wallet: wallet,
                transactions: transactions,
                filter: filter,
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
                    _FilterChips(
                      filter: filter,
                      onChanged: (next) =>
                          ref
                                  .read(
                                    _walletDetailFilterProvider(
                                      wallet.id,
                                    ).notifier,
                                  )
                                  .state =
                              next,
                    ),
                    const SizedBox(height: 16),
                    _AnalyticsOverview(analytics: analytics),
                    const SizedBox(height: 16),
                    _CashflowChart(analytics: analytics),
                    const SizedBox(height: 16),
                    _TransactionFlowList(
                      wallet: wallet,
                      analytics: analytics,
                      categoriesById: categoriesById,
                      displayCurrency: displayCurrency,
                      showDefaultCurrency: showDefaultCurrency,
                      exchangeRates: exchangeRates,
                      filter: filter,
                      onChanged: (next) =>
                          ref
                                  .read(
                                    _walletDetailFilterProvider(
                                      wallet.id,
                                    ).notifier,
                                  )
                                  .state =
                              next,
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
      text: MoneyUtils.toMajorText(
        currentBalance,
        currencyCode: wallet.currencyCode,
      ),
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
                final target = MoneyUtils.toMinor(
                  double.tryParse(controller.text.trim()) ?? 0,
                  currencyCode: wallet.currencyCode,
                );
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
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _CashflowPill(
                    title: 'Incoming',
                    amount: analytics.incoming,
                    currencyCode: analytics.currencyCode,
                    icon: Icons.south_west_rounded,
                    color: AppColors.income,
                  ),
                ),
                Container(
                  width: 1,
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _CashflowPill(
                    title: 'Outgoing',
                    amount: analytics.outgoing,
                    currencyCode: analytics.currencyCode,
                    icon: Icons.north_east_rounded,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                title: 'Net flow',
                amount: analytics.incoming - analytics.outgoing,
                currencyCode: analytics.currencyCode,
                icon: Icons.show_chart_rounded,
                color: analytics.incoming >= analytics.outgoing
                    ? AppColors.income
                    : Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _CountTile(count: analytics.count)),
          ],
        ),
      ],
    );
  }
}

class _CashflowPill extends StatelessWidget {
  final String title;
  final int amount;
  final String currencyCode;
  final IconData icon;
  final Color color;
  const _CashflowPill({
    required this.title,
    required this.amount,
    required this.currencyCode,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: .14),
          foregroundColor: color,
          child: Icon(icon, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          MoneyUtils.format(amount, currencyCode: currencyCode),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
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
      ...analytics.incomingSeries,
      ...analytics.outgoingSeries,
    ].fold<int>(0, (a, b) => a > b ? a : b);
    final labels = analytics.chartLabels;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cashflow trend',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              analytics.filter.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: (maxValue * 1.2).clamp(1, double.infinity).toDouble(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: .35),
                      strokeWidth: 1,
                    ),
                  ),
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
                        interval: labels.length > 6 ? 2 : 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[i],
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    _lineData(analytics.incomingSeries, AppColors.income),
                    _lineData(analytics.outgoingSeries, AppColors.expense),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                _LegendDot(color: AppColors.income, label: 'Incoming'),
                SizedBox(width: 16),
                _LegendDot(color: AppColors.expense, label: 'Outgoing'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _lineData(List<int> values, Color color) => LineChartBarData(
    spots: [
      for (var i = 0; i < values.length; i++)
        FlSpot(i.toDouble(), values[i].toDouble()),
    ],
    isCurved: true,
    color: color,
    barWidth: 3,
    dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(show: true, color: color.withValues(alpha: .10)),
  );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _FilterChips extends StatelessWidget {
  final _AccountFilter filter;
  final ValueChanged<_AccountFilter> onChanged;
  const _FilterChips({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  selected: filter.mode == _FilterMode.allTime,
                  label: const Text('All time'),
                  onSelected: (_) =>
                      onChanged(filter.copyWith(mode: _FilterMode.allTime)),
                ),
                ChoiceChip(
                  selected: filter.mode == _FilterMode.cycle,
                  label: const Text('Cycle'),
                  onSelected: (_) =>
                      onChanged(filter.copyWith(mode: _FilterMode.cycle)),
                ),
                ChoiceChip(
                  selected: filter.mode == _FilterMode.pastDays,
                  label: Text('Past ${filter.pastDays} days'),
                  onSelected: (_) => _pickPastDays(context),
                ),
                ChoiceChip(
                  selected: filter.mode == _FilterMode.dateRange,
                  label: const Text('Date range'),
                  onSelected: (_) => _pickDateRange(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPastDays(BuildContext context) async {
    final controller = TextEditingController(text: '${filter.pastDays}');
    try {
      final days = await showDialog<int>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Past days'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Number of days'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                int.tryParse(controller.text.trim()) ?? filter.pastDays,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      );
      if (days != null) {
        onChanged(
          filter.copyWith(
            mode: _FilterMode.pastDays,
            pastDays: days.clamp(1, 3650),
          ),
        );
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      initialDateRange: DateTimeRange(
        start: filter.startDate ?? DateTime(now.year, now.month),
        end: filter.endDate ?? now,
      ),
    );
    if (picked != null) {
      onChanged(
        filter.copyWith(
          mode: _FilterMode.dateRange,
          startDate: picked.start,
          endDate: picked.end,
        ),
      );
    }
  }
}

class _TransactionFlowList extends StatelessWidget {
  final Wallet wallet;
  final _AccountAnalytics analytics;
  final Map<int, Category> categoriesById;
  final String displayCurrency;
  final bool showDefaultCurrency;
  final Map<String, double> exchangeRates;
  final _AccountFilter filter;
  final ValueChanged<_AccountFilter> onChanged;
  const _TransactionFlowList({
    required this.wallet,
    required this.analytics,
    required this.categoriesById,
    required this.displayCurrency,
    required this.showDefaultCurrency,
    required this.exchangeRates,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOutgoing = filter.flow == _FlowType.outgoing;
    final transactions = isOutgoing
        ? analytics.outgoingTransactions
        : analytics.incomingTransactions;
    final color = isOutgoing ? AppColors.expense : AppColors.income;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowTabs(
              selected: filter.flow,
              onChanged: (flow) => onChanged(filter.copyWith(flow: flow)),
            ),
            const SizedBox(height: 12),
            Text(
              '${transactions.length} transaction${transactions.length == 1 ? '' : 's'} • ${analytics.filter.label}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No ${isOutgoing ? 'outgoing' : 'incoming'} transactions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              for (final t in transactions) ...[
                _ActivityTile(
                  transaction: t,
                  category: t.categoryId == null
                      ? null
                      : categoriesById[t.categoryId],
                  overrideColor: color,
                  displayCurrency: displayCurrency,
                  showDefaultCurrency: showDefaultCurrency,
                  exchangeRates: exchangeRates,
                  walletId: wallet.id,
                ),
                if (t != transactions.last) const Divider(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _FlowTabs extends StatelessWidget {
  final _FlowType selected;
  final ValueChanged<_FlowType> onChanged;
  const _FlowTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FlowTabButton(
              label: 'Outgoing',
              icon: Icons.north_east_rounded,
              color: AppColors.expense,
              selected: selected == _FlowType.outgoing,
              onTap: () => onChanged(_FlowType.outgoing),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _FlowTabButton(
              label: 'Incoming',
              icon: Icons.south_west_rounded,
              color: AppColors.income,
              selected: selected == _FlowType.incoming,
              onTap: () => onChanged(_FlowType.incoming),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _FlowTabButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: selected ? color.withValues(alpha: .16) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? color : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? color : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _FilterMode { allTime, cycle, pastDays, dateRange }

enum _FlowType { outgoing, incoming }

class _AccountFilter {
  final _FilterMode mode;
  final int pastDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final _FlowType flow;

  const _AccountFilter({
    this.mode = _FilterMode.cycle,
    this.pastDays = 30,
    this.startDate,
    this.endDate,
    this.flow = _FlowType.outgoing,
  });

  _AccountFilter copyWith({
    _FilterMode? mode,
    int? pastDays,
    DateTime? startDate,
    DateTime? endDate,
    _FlowType? flow,
  }) => _AccountFilter(
    mode: mode ?? this.mode,
    pastDays: pastDays ?? this.pastDays,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    flow: flow ?? this.flow,
  );

  DateTime? get effectiveStart {
    final now = DateTime.now();
    return switch (mode) {
      _FilterMode.allTime => null,
      _FilterMode.cycle => DateTime(now.year, now.month),
      _FilterMode.pastDays => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: pastDays - 1)),
      _FilterMode.dateRange => startDate,
    };
  }

  DateTime? get effectiveEnd {
    if (mode == _FilterMode.dateRange) {
      return endDate?.add(const Duration(days: 1));
    }
    return null;
  }

  String get label {
    final now = DateTime.now();
    return switch (mode) {
      _FilterMode.allTime => 'All time',
      _FilterMode.cycle => 'Current cycle • ${now.month}/${now.year}',
      _FilterMode.pastDays => 'Past $pastDays days',
      _FilterMode.dateRange =>
        startDate == null || endDate == null
            ? 'Date range'
            : '${MoneyUtils.formatDateShort(startDate!)} - ${MoneyUtils.formatDateShort(endDate!)}',
    };
  }
}

class _ActivityTile extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final Color? overrideColor;
  final String displayCurrency;
  final bool showDefaultCurrency;
  final Map<String, double> exchangeRates;
  final int walletId;
  const _ActivityTile({
    required this.transaction,
    this.category,
    this.overrideColor,
    required this.displayCurrency,
    required this.showDefaultCurrency,
    required this.exchangeRates,
    required this.walletId,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final isIncome = transaction.type == 'income';
    final fallbackColor =
        overrideColor ??
        (isExpense
            ? AppColors.expense
            : (isIncome ? AppColors.income : AppColors.transfer));
    final itemCategory = category;
    final color = itemCategory == null
        ? fallbackColor
        : AppColors.fromStored(itemCategory.color, fallbackColor);
    final fallbackAmountColor = isExpense
        ? AppColors.expense
        : isIncome
        ? AppColors.income
        : AppColors.transfer;
    final amountColor = overrideColor ?? fallbackAmountColor;
    final sign =
        isExpense ||
            (transaction.type == 'transfer' && transaction.walletId == walletId)
        ? '-'
        : '+';
    final originalCurrency = transaction.currencyCode;
    final convertedAmount = MinorConversionCache(
      toCurrency: displayCurrency,
      rates: exchangeRates,
    ).convert(transaction.amountMinor, fromCurrency: originalCurrency);
    final showConverted =
        showDefaultCurrency &&
        convertedAmount != null &&
        originalCurrency.toUpperCase() != displayCurrency.toUpperCase();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(
          category == null
              ? (transaction.type == 'transfer'
                    ? Icons.swap_horiz
                    : Icons.category_outlined)
              : materialCategoryIcon(category!.icon),
          color: color,
          size: 20,
        ),
      ),
      title: Text(transaction.title ?? transaction.type),
      subtitle: Text(
        category == null
            ? MoneyUtils.formatDateShort(transaction.date)
            : '${MoneyUtils.formatDateShort(transaction.date)} • ${category!.name}',
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$sign${MoneyUtils.format(transaction.amountMinor, currencyCode: originalCurrency)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: amountColor),
          ),
          if (showConverted) ...[
            const SizedBox(height: 2),
            Text(
              '$sign${MoneyUtils.format(convertedAmount, currencyCode: displayCurrency)}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      onTap: () => context.push('/transactions/${transaction.id}'),
    );
  }
}

class _AccountAnalytics {
  final String currencyCode;
  final _AccountFilter filter;
  final int incoming;
  final int outgoing;
  final int count;
  final List<String> chartLabels;
  final List<int> incomingSeries;
  final List<int> outgoingSeries;
  final List<Transaction> incomingTransactions;
  final List<Transaction> outgoingTransactions;
  final List<MapEntry<String, int>> incomingBreakdown;
  final List<MapEntry<String, int>> outgoingBreakdown;

  const _AccountAnalytics({
    required this.currencyCode,
    required this.filter,
    required this.incoming,
    required this.outgoing,
    required this.count,
    required this.chartLabels,
    required this.incomingSeries,
    required this.outgoingSeries,
    required this.incomingTransactions,
    required this.outgoingTransactions,
    required this.incomingBreakdown,
    required this.outgoingBreakdown,
  });

  factory _AccountAnalytics.fromTransactions({
    required Wallet wallet,
    required List<Transaction> transactions,
    required _AccountFilter filter,
  }) {
    final start = filter.effectiveStart;
    final end = filter.effectiveEnd;
    final chartBuckets = _chartBuckets(
      start: start,
      end: end,
      allTransactions: transactions,
    );
    final incomingSeries = List<int>.filled(chartBuckets.length, 0);
    final outgoingSeries = List<int>.filled(chartBuckets.length, 0);
    final incomingBreakdown = <String, int>{};
    final outgoingBreakdown = <String, int>{};
    final incomingTransactions = <Transaction>[];
    final outgoingTransactions = <Transaction>[];
    var incoming = 0;
    var outgoing = 0;
    var count = 0;

    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    for (final t in sorted) {
      if (start != null && t.date.isBefore(start)) continue;
      if (end != null && !t.date.isBefore(end)) continue;

      final isIncoming =
          t.type == 'income' ||
          (t.type == 'transfer' && t.transferWalletId == wallet.id);
      final isOutgoing =
          t.type == 'expense' ||
          (t.type == 'transfer' && t.walletId == wallet.id);
      if (!isIncoming && !isOutgoing) continue;
      count++;

      final bucketIndex = _bucketIndexFor(t.date, chartBuckets);
      if (isIncoming) {
        incoming += t.amountMinor;
        incomingTransactions.add(t);
        if (bucketIndex != null) incomingSeries[bucketIndex] += t.amountMinor;
        final label = t.type == 'transfer'
            ? 'Transfers in'
            : (t.title ?? 'Income');
        incomingBreakdown[label] =
            (incomingBreakdown[label] ?? 0) + t.amountMinor;
      } else {
        outgoing += t.amountMinor;
        outgoingTransactions.add(t);
        if (bucketIndex != null) outgoingSeries[bucketIndex] += t.amountMinor;
        final label = t.type == 'transfer'
            ? 'Transfers out'
            : (t.title ?? 'Expense');
        outgoingBreakdown[label] =
            (outgoingBreakdown[label] ?? 0) + t.amountMinor;
      }
    }

    return _AccountAnalytics(
      currencyCode: wallet.currencyCode,
      filter: filter,
      incoming: incoming,
      outgoing: outgoing,
      count: count,
      chartLabels: chartBuckets.map((b) => b.label).toList(),
      incomingSeries: incomingSeries,
      outgoingSeries: outgoingSeries,
      incomingTransactions: incomingTransactions,
      outgoingTransactions: outgoingTransactions,
      incomingBreakdown: _topEntries(incomingBreakdown),
      outgoingBreakdown: _topEntries(outgoingBreakdown),
    );
  }
}

class _ChartBucket {
  final DateTime start;
  final DateTime end;
  final String label;
  const _ChartBucket({
    required this.start,
    required this.end,
    required this.label,
  });
}

List<_ChartBucket> _chartBuckets({
  required DateTime? start,
  required DateTime? end,
  required List<Transaction> allTransactions,
}) {
  final now = DateTime.now();
  final effectiveStart =
      start ??
      _earliestTransactionDate(allTransactions) ??
      DateTime(now.year, now.month - 5);
  final effectiveEnd =
      end ??
      DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  final days = effectiveEnd
      .difference(effectiveStart)
      .inDays
      .abs()
      .clamp(1, 100000);

  if (days <= 45) {
    final buckets = <_ChartBucket>[];
    for (
      var d = DateTime(
        effectiveStart.year,
        effectiveStart.month,
        effectiveStart.day,
      );
      d.isBefore(effectiveEnd);
      d = d.add(const Duration(days: 1))
    ) {
      buckets.add(
        _ChartBucket(
          start: d,
          end: d.add(const Duration(days: 1)),
          label: '${d.day}/${d.month}',
        ),
      );
    }
    return buckets.isEmpty ? [_singleBucket(now)] : buckets;
  }

  final buckets = <_ChartBucket>[];
  var cursor = DateTime(effectiveStart.year, effectiveStart.month);
  final last = DateTime(effectiveEnd.year, effectiveEnd.month + 1);
  while (cursor.isBefore(last)) {
    final next = DateTime(cursor.year, cursor.month + 1);
    buckets.add(
      _ChartBucket(
        start: cursor,
        end: next,
        label: '${cursor.month}/${cursor.year.toString().substring(2)}',
      ),
    );
    cursor = next;
  }
  return buckets.isEmpty ? [_singleBucket(now)] : buckets;
}

_ChartBucket _singleBucket(DateTime date) => _ChartBucket(
  start: DateTime(date.year, date.month, date.day),
  end: DateTime(date.year, date.month, date.day).add(const Duration(days: 1)),
  label: '${date.day}/${date.month}',
);

DateTime? _earliestTransactionDate(List<Transaction> transactions) {
  if (transactions.isEmpty) return null;
  return transactions
      .map((t) => t.date)
      .reduce((a, b) => a.isBefore(b) ? a : b);
}

int? _bucketIndexFor(DateTime date, List<_ChartBucket> buckets) {
  for (var i = 0; i < buckets.length; i++) {
    final b = buckets[i];
    if (!date.isBefore(b.start) && date.isBefore(b.end)) return i;
  }
  return null;
}

List<MapEntry<String, int>> _topEntries(Map<String, int> data) {
  final entries = data.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(8).toList();
}

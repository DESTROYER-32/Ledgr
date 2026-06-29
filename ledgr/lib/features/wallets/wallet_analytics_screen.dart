import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/empty_state.dart';

class WalletAnalyticsScreen extends ConsumerStatefulWidget {
  final int walletId;
  const WalletAnalyticsScreen({super.key, required this.walletId});

  @override
  ConsumerState<WalletAnalyticsScreen> createState() =>
      _WalletAnalyticsScreenState();
}

class _WalletAnalyticsScreenState extends ConsumerState<WalletAnalyticsScreen> {
  _Range _range = _Range.month;
  bool _includeTransfers = true;

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(allWalletsProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    final wallet = walletsAsync.valueOrNull
        ?.where((w) => w.id == widget.walletId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(wallet?.name ?? 'Account analytics')),
      body:
          walletsAsync.isLoading ||
              transactionsAsync.isLoading ||
              categoriesAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(
              wallet,
              walletsAsync.valueOrNull ?? [],
              transactionsAsync.valueOrNull ?? [],
              categoriesAsync.valueOrNull ?? [],
            ),
    );
  }

  Widget _buildBody(
    Wallet? wallet,
    List<Wallet> wallets,
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    if (wallet == null) return const Center(child: Text('Account not found'));
    final report = _buildReport(wallet, wallets, transactions, categories);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<_Range>(
              segments: const [
                ButtonSegment(value: _Range.month, label: Text('Month')),
                ButtonSegment(value: _Range.threeMonths, label: Text('3M')),
                ButtonSegment(value: _Range.year, label: Text('Year')),
                ButtonSegment(value: _Range.all, label: Text('All')),
              ],
              selected: {_range},
              onSelectionChanged: (v) => setState(() => _range = v.first),
            ),
            FilterChip(
              selected: _includeTransfers,
              label: const Text('Transfers'),
              avatar: const Icon(Icons.swap_horiz_rounded, size: 18),
              onSelected: (v) => setState(() => _includeTransfers = v),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (report.count == 0)
          const EmptyState(
            icon: Icons.insights_outlined,
            title: 'No account activity',
            subtitle: 'Try a wider date range or include transfers.',
          )
        else ...[
          _SummaryGrid(report: report),
          const SizedBox(height: 16),
          _CashflowCard(report: report),
          const SizedBox(height: 16),
          _BreakdownCard(
            title: 'Outgoing',
            icon: Icons.arrow_upward_rounded,
            color: Colors.red,
            entries: report.outgoingBreakdown,
            currencyCode: wallet.currencyCode,
          ),
          const SizedBox(height: 16),
          _BreakdownCard(
            title: 'Incoming',
            icon: Icons.arrow_downward_rounded,
            color: Colors.green,
            entries: report.incomingBreakdown,
            currencyCode: wallet.currencyCode,
          ),
          const SizedBox(height: 8),
          Text(
            'Outgoing and incoming are shown from this account’s perspective. Transfers are separated by direction when enabled.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  _WalletReport _buildReport(
    Wallet wallet,
    List<Wallet> wallets,
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    final start = _range.startDate();
    final categoryById = {for (final c in categories) c.id: c.name};
    final walletById = {for (final w in wallets) w.id: w.name};
    final incoming = <String, int>{};
    final outgoing = <String, int>{};
    final incomingBreakdown = <String, int>{};
    final outgoingBreakdown = <String, int>{};
    var totalIncoming = 0;
    var totalOutgoing = 0;
    var count = 0;

    final now = DateTime.now();
    final visibleTransactions = transactions.where((t) {
      final touchesWallet =
          t.walletId == wallet.id || t.transferWalletId == wallet.id;
      if (!touchesWallet) return false;
      if (start != null && t.date.isBefore(start)) return false;
      if (t.type == 'transfer' && !_includeTransfers) return false;
      return true;
    }).toList();
    final firstChartMonth =
        _range == _Range.all && visibleTransactions.isNotEmpty
        ? visibleTransactions
              .map((t) => DateTime(t.date.year, t.date.month))
              .reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime(now.year, now.month - _chartMonthsForRange(_range) + 1);
    for (
      var d = firstChartMonth;
      !d.isAfter(DateTime(now.year, now.month));
      d = DateTime(d.year, d.month + 1)
    ) {
      incoming[_monthKey(d)] = 0;
      outgoing[_monthKey(d)] = 0;
    }

    for (final t in transactions) {
      final touchesWallet =
          t.walletId == wallet.id || t.transferWalletId == wallet.id;
      if (!touchesWallet) continue;
      if (start != null && t.date.isBefore(start)) continue;
      if (t.type == 'transfer' && !_includeTransfers) continue;

      final isIncoming =
          t.type == 'income' ||
          (t.type == 'transfer' && t.transferWalletId == wallet.id);
      final isOutgoing =
          t.type == 'expense' ||
          (t.type == 'transfer' && t.walletId == wallet.id);
      if (!isIncoming && !isOutgoing) continue;

      count++;
      final month = _monthKey(t.date);
      final amount = t.amountMinor;
      if (isIncoming) {
        totalIncoming += amount;
        if (incoming.containsKey(month)) {
          incoming[month] = incoming[month]! + amount;
        }
        final from = t.type == 'transfer'
            ? 'Transfer from ${walletById[t.walletId] ?? 'Account'}'
            : (categoryById[t.categoryId] ?? t.title ?? 'Income');
        incomingBreakdown[from] = (incomingBreakdown[from] ?? 0) + amount;
      } else if (isOutgoing) {
        totalOutgoing += amount;
        if (outgoing.containsKey(month)) {
          outgoing[month] = outgoing[month]! + amount;
        }
        final to = t.type == 'transfer'
            ? 'Transfer to ${walletById[t.transferWalletId] ?? 'Account'}'
            : (categoryById[t.categoryId] ?? t.title ?? 'Expense');
        outgoingBreakdown[to] = (outgoingBreakdown[to] ?? 0) + amount;
      }
    }

    return _WalletReport(
      currencyCode: wallet.currencyCode,
      incoming: incoming,
      outgoing: outgoing,
      incomingBreakdown: _topEntries(incomingBreakdown),
      outgoingBreakdown: _topEntries(outgoingBreakdown),
      totalIncoming: totalIncoming,
      totalOutgoing: totalOutgoing,
      count: count,
    );
  }
}

enum _Range { month, threeMonths, year, all }

int _chartMonthsForRange(_Range range) => switch (range) {
  _Range.month => 1,
  _Range.threeMonths => 3,
  _Range.year || _Range.all => 12,
};

extension on _Range {
  DateTime? startDate() {
    final now = DateTime.now();
    return switch (this) {
      _Range.month => DateTime(now.year, now.month),
      _Range.threeMonths => DateTime(now.year, now.month - 2),
      _Range.year => DateTime(now.year),
      _Range.all => null,
    };
  }
}

class _SummaryGrid extends StatelessWidget {
  final _WalletReport report;
  const _SummaryGrid({required this.report});

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
        _MetricCard(
          'Incoming',
          report.totalIncoming,
          Colors.green,
          Icons.arrow_downward_rounded,
          report.currencyCode,
        ),
        _MetricCard(
          'Outgoing',
          report.totalOutgoing,
          Colors.red,
          Icons.arrow_upward_rounded,
          report.currencyCode,
        ),
        _MetricCard(
          'Net',
          report.totalIncoming - report.totalOutgoing,
          report.totalIncoming >= report.totalOutgoing
              ? Colors.green
              : Colors.orange,
          Icons.ssid_chart_rounded,
          report.currencyCode,
        ),
        _CountCard(count: report.count),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final int amount;
  final Color color;
  final IconData icon;
  final String currencyCode;
  const _MetricCard(
    this.title,
    this.amount,
    this.color,
    this.icon,
    this.currencyCode,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
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

class _CountCard extends StatelessWidget {
  final int count;
  const _CountCard({required this.count});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          Text('Transactions', style: Theme.of(context).textTheme.labelMedium),
          Text(
            '$count',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

class _CashflowCard extends StatelessWidget {
  final _WalletReport report;
  const _CashflowCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final labels = report.incoming.keys.toList();
    final maxValue = [
      ...report.incoming.values,
      ...report.outgoing.values,
    ].fold<int>(0, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incoming vs outgoing',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: (maxValue * 1.2).clamp(1, double.infinity).toDouble(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
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
                            toY: (report.incoming[labels[i]] ?? 0).toDouble(),
                            color: Colors.green,
                            width: 8,
                          ),
                          BarChartRodData(
                            toY: (report.outgoing[labels[i]] ?? 0).toDouble(),
                            color: Colors.red,
                            width: 8,
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

class _BreakdownCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<MapEntry<String, int>> entries;
  final String currencyCode;
  const _BreakdownCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.entries,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Text('No $title activity'.toLowerCase())
            else
              for (final entry in entries)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.key),
                  trailing: Text(
                    MoneyUtils.format(entry.value, currencyCode: currencyCode),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _WalletReport {
  final String currencyCode;
  final Map<String, int> incoming;
  final Map<String, int> outgoing;
  final List<MapEntry<String, int>> incomingBreakdown;
  final List<MapEntry<String, int>> outgoingBreakdown;
  final int totalIncoming;
  final int totalOutgoing;
  final int count;
  const _WalletReport({
    required this.currencyCode,
    required this.incoming,
    required this.outgoing,
    required this.incomingBreakdown,
    required this.outgoingBreakdown,
    required this.totalIncoming,
    required this.totalOutgoing,
    required this.count,
  });
}

String _monthKey(DateTime date) =>
    '${date.month}/${date.year.toString().substring(2)}';

List<MapEntry<String, int>> _topEntries(Map<String, int> data) {
  final entries = data.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(8).toList();
}

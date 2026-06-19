import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/empty_state.dart';

final analyticsReportProvider = FutureProvider.autoDispose<_AnalyticsReport>((
  ref,
) async {
  final transactions = await ref.watch(allTransactionsProvider.future);
  final categories = await ref.watch(activeCategoriesProvider.future);
  final wallets = await ref.watch(allWalletsProvider.future);
  final displayCurrency = await ref.watch(displayCurrencyProvider.future);
  final exchange = ref.watch(exchangeRateServiceProvider);

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final nextMonth = DateTime(now.year, now.month + 1);
  final trendStart = DateTime(now.year, now.month - 5);

  final categoryById = {for (final c in categories) c.id: c};
  final walletById = {for (final w in wallets) w.id: w};
  final monthlyExpense = <String, int>{};
  final monthlyIncome = <String, int>{};
  final categoryExpense = <String, int>{};
  final accountExpense = <String, int>{};

  var monthIncome = 0;
  var monthExpense = 0;
  var transactionCount = 0;

  for (var i = 5; i >= 0; i--) {
    final date = DateTime(now.year, now.month - i);
    final key = _monthKey(date);
    monthlyExpense[key] = 0;
    monthlyIncome[key] = 0;
  }

  for (final t in transactions) {
    if (t.type == 'transfer') continue;
    final converted = await exchange.convert(
      t.amountMinor,
      t.currencyCode,
      displayCurrency,
      onDate: t.date,
    );

    if (!t.date.isBefore(trendStart)) {
      final key = _monthKey(t.date);
      if (monthlyExpense.containsKey(key) && t.type == 'expense') {
        monthlyExpense[key] = monthlyExpense[key]! + converted;
      } else if (monthlyIncome.containsKey(key) && t.type == 'income') {
        monthlyIncome[key] = monthlyIncome[key]! + converted;
      }
    }

    final inCurrentMonth =
        !t.date.isBefore(monthStart) && t.date.isBefore(nextMonth);
    if (!inCurrentMonth) continue;

    transactionCount++;
    if (t.type == 'income') {
      monthIncome += converted;
    } else if (t.type == 'expense') {
      monthExpense += converted;
      final category = categoryById[t.categoryId]?.name ?? 'Uncategorized';
      categoryExpense[category] = (categoryExpense[category] ?? 0) + converted;
      final account = walletById[t.walletId]?.name ?? 'Account #${t.walletId}';
      accountExpense[account] = (accountExpense[account] ?? 0) + converted;
    }
  }

  return _AnalyticsReport(
    displayCurrency: displayCurrency,
    monthIncome: monthIncome,
    monthExpense: monthExpense,
    netCashflow: monthIncome - monthExpense,
    transactionCount: transactionCount,
    monthlyExpense: monthlyExpense,
    monthlyIncome: monthlyIncome,
    categoryExpense: _topEntries(categoryExpense),
    accountExpense: _topEntries(accountExpense),
  );
});

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(analyticsReportProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(analyticsReportProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analyticsReportProvider);
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        child: reportAsync.when(
          data: (report) => report.transactionCount == 0
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 120),
                    const EmptyState(
                      icon: Icons.insights_outlined,
                      title: 'No analytics yet',
                      subtitle:
                          'Add transactions this month to see spending trends, category breakdowns, and account insights.',
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _SummaryGrid(report: report),
                    const SizedBox(height: 16),
                    _TrendCard(report: report),
                    const SizedBox(height: 16),
                    _CategoryCard(report: report),
                    const SizedBox(height: 16),
                    _BreakdownCard(
                      title: 'Spending by Account',
                      icon: Icons.account_balance_wallet_outlined,
                      entries: report.accountExpense,
                      currencyCode: report.displayCurrency,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analytics use your display currency and convert historical transactions with available cached or custom exchange rates.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              EmptyState(
                icon: Icons.error_outline,
                title: 'Unable to load analytics',
                subtitle: '$error',
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final _AnalyticsReport report;
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
          title: 'Income',
          value: MoneyUtils.format(
            report.monthIncome,
            currencyCode: report.displayCurrency,
          ),
          icon: Icons.arrow_downward_rounded,
          color: Colors.green,
        ),
        _MetricCard(
          title: 'Expenses',
          value: MoneyUtils.format(
            report.monthExpense,
            currencyCode: report.displayCurrency,
          ),
          icon: Icons.arrow_upward_rounded,
          color: Colors.red,
        ),
        _MetricCard(
          title: 'Net',
          value: MoneyUtils.format(
            report.netCashflow,
            currencyCode: report.displayCurrency,
          ),
          icon: Icons.ssid_chart_rounded,
          color: report.netCashflow >= 0 ? Colors.green : Colors.orange,
        ),
        _MetricCard(
          title: 'Transactions',
          value: report.transactionCount.toString(),
          icon: Icons.receipt_long_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: .14),
              foregroundColor: color,
              child: Icon(icon, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final _AnalyticsReport report;
  const _TrendCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labels = report.monthlyExpense.keys.toList();
    final maxValue = [
      ...report.monthlyExpense.values,
      ...report.monthlyIncome.values,
      1,
    ].reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart_rounded, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  '6-Month Trend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 210,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxValue * 1.15,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: cs.outlineVariant.withValues(alpha: .5),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[index],
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _lineData(
                      report.monthlyIncome.values.toList(),
                      Colors.green,
                    ),
                    _lineData(
                      report.monthlyExpense.values.toList(),
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                _LegendDot(color: Colors.green, label: 'Income'),
                SizedBox(width: 16),
                _LegendDot(color: Colors.red, label: 'Expenses'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _lineData(List<int> values, Color color) {
    return LineChartBarData(
      isCurved: true,
      barWidth: 3,
      color: color,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: .10),
      ),
      spots: [
        for (var i = 0; i < values.length; i++)
          FlSpot(i.toDouble(), values[i].toDouble()),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _AnalyticsReport report;
  const _CategoryCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.donut_large_rounded, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Category Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (report.categoryExpense.isEmpty)
              Text(
                'No expenses this month.',
                style: TextStyle(color: cs.onSurfaceVariant),
              )
            else ...[
              SizedBox(
                height: 190,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 46,
                    sections: [
                      for (var i = 0; i < report.categoryExpense.length; i++)
                        PieChartSectionData(
                          value: report.categoryExpense[i].amount.toDouble(),
                          title:
                              '${report.categoryExpense[i].percentOf(report.monthExpense).round()}%',
                          radius: 58,
                          color: _chartColor(i, cs),
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _BreakdownList(
                entries: report.categoryExpense,
                currencyCode: report.displayCurrency,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_AnalyticsEntry> entries;
  final String currencyCode;

  const _BreakdownCard({
    required this.title,
    required this.icon,
    required this.entries,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Text(
                'No expenses this month.',
                style: TextStyle(color: cs.onSurfaceVariant),
              )
            else
              _BreakdownList(entries: entries, currencyCode: currencyCode),
          ],
        ),
      ),
    );
  }
}

class _BreakdownList extends StatelessWidget {
  final List<_AnalyticsEntry> entries;
  final String currencyCode;

  const _BreakdownList({required this.entries, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _chartColor(i, Theme.of(context).colorScheme),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entries[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  MoneyUtils.format(
                    entries[i].amount,
                    currencyCode: currencyCode,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _AnalyticsReport {
  final String displayCurrency;
  final int monthIncome;
  final int monthExpense;
  final int netCashflow;
  final int transactionCount;
  final Map<String, int> monthlyExpense;
  final Map<String, int> monthlyIncome;
  final List<_AnalyticsEntry> categoryExpense;
  final List<_AnalyticsEntry> accountExpense;

  const _AnalyticsReport({
    required this.displayCurrency,
    required this.monthIncome,
    required this.monthExpense,
    required this.netCashflow,
    required this.transactionCount,
    required this.monthlyExpense,
    required this.monthlyIncome,
    required this.categoryExpense,
    required this.accountExpense,
  });
}

class _AnalyticsEntry {
  final String label;
  final int amount;
  const _AnalyticsEntry(this.label, this.amount);

  double percentOf(int total) => total <= 0 ? 0 : amount / total * 100;
}

List<_AnalyticsEntry> _topEntries(Map<String, int> values) {
  final entries =
      values.entries
          .map((entry) => _AnalyticsEntry(entry.key, entry.value))
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
  return entries.take(6).toList();
}

String _monthKey(DateTime date) => DateFormat('MMM').format(date);

Color _chartColor(int index, ColorScheme cs) {
  final colors = [
    cs.primary,
    cs.tertiary,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];
  return colors[index % colors.length];
}

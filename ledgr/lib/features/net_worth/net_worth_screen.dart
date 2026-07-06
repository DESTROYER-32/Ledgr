import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/money_utils.dart';
import '../../core/database/app_database.dart';
import 'net_worth_calculator.dart';
import 'net_worth_providers.dart';

class NetWorthScreen extends ConsumerWidget {
  const NetWorthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(currentNetWorthProvider);
    final historyAsync = ref.watch(netWorthHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Net Worth')),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current net worth',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      MoneyUtils.format(
                        summary.netWorthMinor,
                        currencyCode: summary.currencyCode,
                      ),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            label: 'Assets',
                            amount: summary.assetsMinor,
                            currency: summary.currencyCode,
                          ),
                        ),
                        Expanded(
                          child: _Metric(
                            label: 'Liabilities',
                            amount: summary.liabilitiesMinor,
                            currency: summary.currencyCode,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _HistoryChart(historyAsync: historyAsync),
            const SizedBox(height: 16),
            _Breakdown(title: 'Assets', items: summary.assetWallets),
            const SizedBox(height: 16),
            _Breakdown(title: 'Liabilities', items: summary.liabilityItems),
          ],
        ),
      ),
    );
  }
}

class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.historyAsync});

  final AsyncValue<List<NetWorthSnapshot>> historyAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trend', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            historyAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('History unavailable: $error'),
              data: (history) {
                if (history.length < 2) {
                  return const Text(
                    'A trend chart will appear after more snapshots are saved.',
                  );
                }
                final currency = history.last.currencyCode;
                final spots = [
                  for (var i = 0; i < history.length; i++)
                    FlSpot(
                      i.toDouble(),
                      MoneyUtils.toMajor(
                        history[i].netWorthMinor,
                        currencyCode: currency,
                      ),
                    ),
                ];
                return SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(drawVerticalLine: false),
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.amount,
    required this.currency,
  });
  final String label;
  final int amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          MoneyUtils.format(amount, currencyCode: currency),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.title, required this.items});
  final String title;
  final List<NetWorthBreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nothing to show yet.'),
            )
          else
            ...items.map(
              (item) => ListTile(
                title: Text(item.name),
                trailing: Text(
                  MoneyUtils.format(
                    item.amountMinor,
                    currencyCode: item.currencyCode,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

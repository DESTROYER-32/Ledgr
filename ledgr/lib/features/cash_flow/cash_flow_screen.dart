import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/money_utils.dart';
import 'cash_flow_providers.dart';

class CashFlowScreen extends ConsumerWidget {
  const CashFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionAsync = ref.watch(overallCashFlowProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cash Flow Forecast')),
      body: projectionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (projection) {
          final theme = Theme.of(context);
          final spots = [
            for (var i = 0; i < projection.points.length; i++)
              FlSpot(
                i.toDouble(),
                MoneyUtils.toMajor(
                  projection.points[i].balanceMinor,
                  currencyCode: projection.currencyCode,
                ),
              ),
          ];
          final bottomInterval = projection.points.length <= 1
              ? 1.0
              : ((projection.points.length - 1) / 3).roundToDouble();
          final values = spots.map((spot) => spot.y).toList();
          final minY = values.reduce((a, b) => a < b ? a : b);
          final maxY = values.reduce((a, b) => a > b ? a : b);
          final range = (maxY - minY).abs();
          final leftInterval = range == 0 ? 1.0 : range / 3;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next 90 days',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 260,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: leftInterval,
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 56,
                                  interval: leftInterval,
                                  getTitlesWidget: (value, meta) {
                                    final minor = MoneyUtils.toMinor(
                                      value,
                                      currencyCode: projection.currencyCode,
                                    );
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        MoneyUtils.formatCompact(
                                          minor,
                                          currencyCode: projection.currencyCode,
                                        ),
                                        style: theme.textTheme.labelSmall,
                                        textAlign: TextAlign.right,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: bottomInterval,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.round();
                                    if (index < 0 ||
                                        index >= projection.points.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final isTick =
                                        index == 0 ||
                                        index == projection.points.length - 1 ||
                                        index % bottomInterval.round() == 0;
                                    if (!isTick) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        AppDateUtils.formatDateShort(
                                          projection.points[index].date,
                                        ),
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                left: BorderSide(color: theme.dividerColor),
                                bottom: BorderSide(color: theme.dividerColor),
                              ),
                            ),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) => touchedSpots
                                    .map(
                                      (spot) => LineTooltipItem(
                                        MoneyUtils.format(
                                          projection
                                              .points[spot.x.toInt()]
                                              .balanceMinor,
                                          currencyCode: projection.currencyCode,
                                        ),
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lowest projected balance: ${MoneyUtils.format(projection.lowestPoint.balanceMinor, currencyCode: projection.currencyCode)} on ${AppDateUtils.formatDate(projection.lowestPoint.date)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upcoming cash flow',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (projection.events.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No upcoming transactions or active recurring items.',
                    ),
                  ),
                )
              else
                ...projection.events
                    .take(30)
                    .map(
                      (event) => Card(
                        child: ListTile(
                          title: Text(event.title),
                          subtitle: Text(AppDateUtils.formatDate(event.date)),
                          trailing: Text(
                            MoneyUtils.format(
                              event.amountMinor,
                              currencyCode: event.currencyCode,
                            ),
                            style: TextStyle(
                              color: event.amountMinor < 0
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

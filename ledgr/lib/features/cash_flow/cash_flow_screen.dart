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
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
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

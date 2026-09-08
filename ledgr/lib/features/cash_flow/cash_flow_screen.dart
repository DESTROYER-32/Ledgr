import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import 'cash_flow_providers.dart';
import 'widgets/upcoming_bill_tile.dart';

class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key, this.walletId});

  final int? walletId;

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  int _days = 90;

  String? _walletName(List<Wallet> wallets) {
    for (final wallet in wallets) {
      if (wallet.id == widget.walletId) return wallet.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final projectionAsync = ref.watch(
      cashFlowProjectionProvider(
        CashFlowRequest(walletId: widget.walletId, days: _days),
      ),
    );
    final walletAsync = widget.walletId == null
        ? null
        : ref.watch(activeWalletsProvider).whenData(_walletName);
    final title = widget.walletId == null
        ? 'Cash Flow Forecast'
        : 'Cash Flow${walletAsync?.valueOrNull == null ? '' : ': ${walletAsync!.valueOrNull}'}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 30, label: Text('30D')),
                  ButtonSegment(value: 60, label: Text('60D')),
                  ButtonSegment(value: 90, label: Text('90D')),
                ],
                selected: {_days},
                onSelectionChanged: (value) =>
                    setState(() => _days = value.first),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next $_days days',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Safe to spend: ${MoneyUtils.format(projection.lowestPoint.balanceMinor, currencyCode: projection.currencyCode)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: projection.lowestPoint.balanceMinor < 0
                              ? theme.colorScheme.error
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
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
                                    final tickInterval = bottomInterval.round();
                                    final isTick = index == 0 ||
                                        index == projection.points.length - 1 ||
                                        (tickInterval > 0 &&
                                            index % tickInterval == 0);
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
                                          projection.points[spot.x.toInt()]
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
              Text('Upcoming cash flow', style: theme.textTheme.titleMedium),
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
                    .map((event) => UpcomingBillTile(event: event)),
            ],
          );
        },
      ),
    );
  }
}

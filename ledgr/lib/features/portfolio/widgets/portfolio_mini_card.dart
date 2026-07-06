import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money_utils.dart';
import '../portfolio_providers.dart';

class PortfolioMiniCard extends ConsumerWidget {
  const PortfolioMiniCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(portfolioSummaryProvider);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/portfolio'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: summaryAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Portfolio unavailable: $error'),
            data: (summary) => Row(
              children: [
                const Icon(Icons.pie_chart_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portfolio',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        MoneyUtils.format(
                          summary.totalValueMinor,
                          currencyCode: summary.currencyCode,
                        ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${summary.totalGainLossMinor >= 0 ? '+' : ''}${MoneyUtils.format(summary.totalGainLossMinor, currencyCode: summary.currencyCode)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/money_utils.dart';
import 'portfolio_providers.dart';
import 'widgets/allocation_chart.dart';
import 'widgets/holding_tile.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(portfolioSummaryProvider);
    final holdingsAsync = ref.watch(portfolioHoldingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            onPressed: () => context.push('/portfolio/holdings/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          summaryAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('$error'),
              ),
            ),
            data: (summary) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total value', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Text(
                      MoneyUtils.format(
                        summary.totalValueMinor,
                        currencyCode: summary.currencyCode,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${summary.totalGainLossMinor >= 0 ? '+' : ''}${MoneyUtils.format(summary.totalGainLossMinor, currencyCode: summary.currencyCode)}${summary.gainLossPercent == null ? '' : ' (${summary.gainLossPercent! >= 0 ? '+' : ''}${summary.gainLossPercent!.toStringAsFixed(1)}%)'}',
                      style: TextStyle(
                        color: summary.totalGainLossMinor >= 0
                            ? Colors.green
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AllocationChart(allocation: summary.allocationByType),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Holdings', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          holdingsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('$error'),
            data: (holdings) => holdings.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('No holdings yet.'),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () =>
                                context.push('/portfolio/holdings/new'),
                            icon: const Icon(Icons.add),
                            label: const Text('Add holding'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final holding in holdings)
                        HoldingTile(
                          holding: holding,
                          onTap: () => context.push(
                            '/portfolio/holdings/${holding.id}/edit',
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

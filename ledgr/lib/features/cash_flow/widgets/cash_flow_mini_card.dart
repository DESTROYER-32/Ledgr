import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money_utils.dart';
import '../cash_flow_providers.dart';

class CashFlowMiniCard extends ConsumerWidget {
  const CashFlowMiniCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectionAsync = ref.watch(overallCashFlowProvider);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/cash-flow'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: projectionAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Cash flow unavailable: $error'),
            data: (projection) => Row(
              children: [
                const Icon(Icons.show_chart),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash Flow Forecast',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lowest: ${MoneyUtils.format(projection.lowestPoint.balanceMinor, currencyCode: projection.currencyCode)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'on ${AppDateUtils.formatDateShort(projection.lowestPoint.date)} • ${projection.events.length} upcoming',
                        style: theme.textTheme.bodySmall,
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

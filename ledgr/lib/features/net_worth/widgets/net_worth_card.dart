import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money_utils.dart';
import '../net_worth_providers.dart';

class NetWorthCard extends ConsumerWidget {
  const NetWorthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final summaryAsync = ref.watch(currentNetWorthProvider);
    final deltaAsync = ref.watch(netWorthMonthlyDeltaProvider);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/net-worth'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: summaryAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Net worth unavailable: $error'),
            data: (summary) => Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Icon(
                    Icons.account_balance,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Net Worth', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        MoneyUtils.format(
                          summary.netWorthMinor,
                          currencyCode: summary.currencyCode,
                        ),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      deltaAsync.maybeWhen(
                        data: (delta) => Text(
                          delta == null
                              ? 'Assets ${MoneyUtils.format(summary.assetsMinor, currencyCode: summary.currencyCode)} • Debt ${MoneyUtils.format(summary.liabilitiesMinor, currencyCode: summary.currencyCode)}'
                              : '${delta.amountMinor >= 0 ? '+' : ''}${MoneyUtils.format(delta.amountMinor, currencyCode: summary.currencyCode)} last 30 days${delta.percent == null ? '' : ' (${delta.percent! >= 0 ? '+' : ''}${delta.percent!.toStringAsFixed(1)}%)'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: delta == null
                                ? null
                                : delta.amountMinor >= 0
                                ? Colors.green
                                : cs.error,
                          ),
                        ),
                        orElse: () => Text(
                          'Assets ${MoneyUtils.format(summary.assetsMinor, currencyCode: summary.currencyCode)} • Debt ${MoneyUtils.format(summary.liabilitiesMinor, currencyCode: summary.currencyCode)}',
                          style: theme.textTheme.bodySmall,
                        ),
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

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';

class CreditDebtScreen extends ConsumerWidget {
  const CreditDebtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Credit & Debt')),
      body: transactionsAsync.when(
        data: (transactions) {
          final credit =
              transactions.where((t) => t.specialType == 'credit').toList();
          final debt =
              transactions.where((t) => t.specialType == 'debt').toList();

          if (credit.isEmpty && debt.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text('No credit or debt', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Mark a transaction as "Credit" (lent) or "Debt" (borrowed) to track it here.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (credit.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Money Lent (Credit)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ),
                ...credit.map((t) => _buildTile(t, theme, Colors.orange)),
                const SizedBox(height: 16),
              ],
              if (debt.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Money Borrowed (Debt)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.expense,
                    ),
                  ),
                ),
                ...debt.map((t) => _buildTile(t, theme, AppColors.expense)),
              ],
            ],
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildTile(Transaction t, ThemeData theme, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          t.specialType == 'credit' ? Icons.arrow_upward : Icons.arrow_downward,
          color: color,
        ),
        title: Text(t.title ?? ''),
        subtitle: Text(MoneyUtils.formatDate(t.date)),
        trailing: Text(
          MoneyUtils.format(t.amountMinor, currencyCode: t.currencyCode),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          final subs = transactions
              .where((t) => t.specialType == 'subscription')
              .toList();
          if (subs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.subscriptions,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No subscriptions',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Mark a transaction as "Subscription" to see it here.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final t = subs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  leading: const Icon(Icons.subscriptions,
                      color: Colors.blue),
                  title: Text(t.title ?? ''),
                  subtitle: Text(
                    '${MoneyUtils.formatDate(t.date)} \u2022 ${t.categoryId != null ? 'Cat #${t.categoryId}' : ''}',
                  ),
                  trailing: Text(
                    MoneyUtils.format(t.amountMinor,
                        currencyCode: t.currencyCode),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: t.type == 'income'
                          ? Colors.green
                          : theme.colorScheme.error,
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

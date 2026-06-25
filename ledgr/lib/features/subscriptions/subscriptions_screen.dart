import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/utils/recurring_utils.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subscriptions & Scheduled'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.subscriptions), text: 'Subscriptions'),
              Tab(icon: Icon(Icons.event_repeat), text: 'Scheduled'),
            ],
          ),
        ),
        body: transactionsAsync.when(
          data: (transactions) {
            final subscriptions = transactions
                .where((t) => t.specialType == 'subscription')
                .toList();
            final scheduled = transactions
                .where(
                  (t) =>
                      t.specialType == 'scheduled' ||
                      t.specialType == 'repetitive',
                )
                .toList();
            return TabBarView(
              children: [
                _TransactionList(
                  transactions: subscriptions,
                  emptyIcon: Icons.subscriptions,
                  emptyTitle: 'No subscriptions',
                  emptyMessage:
                      'Subscriptions are recurring outgoing payments like Netflix or Amazon Prime.',
                  icon: Icons.subscriptions,
                  iconColor: Colors.blue,
                ),
                _TransactionList(
                  transactions: scheduled,
                  emptyIcon: Icons.event_repeat,
                  emptyTitle: 'No scheduled transactions',
                  emptyMessage:
                      'Scheduled transactions can be money out or money in, like SIPs and SWPs.',
                  icon: Icons.event_repeat,
                  iconColor: theme.colorScheme.primary,
                ),
              ],
            );
          },
          error: (e, _) => Center(child: Text('$e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final IconData icon;
  final Color iconColor;

  const _TransactionList({
    required this.transactions,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(emptyTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                emptyMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        final frequency = _frequencyLabel(t.recurrenceRule);
        final category = t.categoryId != null ? 'Cat #${t.categoryId}' : null;
        final subtitleParts = [
          MoneyUtils.formatDate(t.date),
          ?frequency,
          ?category,
        ];

        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            leading: Icon(icon, color: iconColor),
            title: Text(t.title ?? ''),
            subtitle: Text(subtitleParts.join(' • ')),
            trailing: Text(
              MoneyUtils.format(t.amountMinor, currencyCode: t.currencyCode),
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
  }

  String? _frequencyLabel(String? recurrenceRule) => recurrenceRule == null
      ? null
      : recurrenceRule == 'one_time'
      ? 'One time'
      : RecurringUtils.describeSchedule(recurrenceRule);
}

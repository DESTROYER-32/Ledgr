import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/money_utils.dart';
import '../../core/utils/recurring_utils.dart';
import '../../core/widgets/empty_state.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(activeRecurringProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: recurringAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.repeat,
              title: 'No Recurring Transactions',
              subtitle: 'Add recurring bills, subscriptions, or salary.',
              actionLabel: 'Add Recurring',
              onAction: () => context.push('/recurring/new'),
            );
          }
          final upcoming = _buildUpcomingInstances(items);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length + (upcoming.isEmpty ? 0 : 1),
            itemBuilder: (_, i) {
              if (i == 0 && upcoming.isNotEmpty) {
                return _UpcomingPreviewCard(upcoming: upcoming);
              }
              final itemIndex = upcoming.isEmpty ? i : i - 1;
              final r = items[itemIndex];
              final isExpense = r.transactionType == 'expense';
              final isIncome = r.transactionType == 'income';
              final color = isExpense
                  ? AppColors.expense
                  : (isIncome ? AppColors.income : AppColors.transfer);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isExpense
                          ? Icons.arrow_upward
                          : (isIncome
                              ? Icons.arrow_downward
                              : Icons.swap_horiz),
                      color: color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    r.title ?? r.transactionType,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${_scheduleLabel(r.scheduleRule)}  ·  ${r.nextDueDate != null ? MoneyUtils.formatDateShort(r.nextDueDate!) : ''}',
                    style: const TextStyle(fontSize: AppTextSizes.small),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        MoneyUtils.format(
                          r.amountMinor,
                          currencyCode: r.currencyCode,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: r.active,
                        onChanged: (v) async {
                          try {
                            await ref.read(recurringRepositoryProvider).update(
                                  r.id,
                                  RecurringTransactionsCompanion(
                                    active: Value(v),
                                  ),
                                );
                          } catch (error, stackTrace) {
                            AppLogger.warning(
                              'Failed to update recurring item active state',
                              error: error,
                              stackTrace: stackTrace,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not update recurring item.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => context.push('/recurring/${r.id}'),
                ),
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recurring/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _scheduleLabel(String rule) => RecurringUtils.describeSchedule(rule);

  List<_RecurringPreviewItem> _buildUpcomingInstances(
    List<RecurringTransaction> items,
  ) {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day + 90);
    final previews = <_RecurringPreviewItem>[];
    for (final item in items) {
      final nextDue = item.nextDueDate;
      if (nextDue == null) continue;
      for (final date in RecurringUtils.generateInstances(
        item.scheduleRule,
        nextDue,
        item.endDate != null && item.endDate!.isBefore(end)
            ? item.endDate
            : end,
        12,
      )) {
        if (date.isBefore(DateTime(today.year, today.month, today.day))) {
          continue;
        }
        previews.add(_RecurringPreviewItem(item, date));
      }
    }
    previews.sort((a, b) => a.date.compareTo(b.date));
    return previews.take(8).toList();
  }
}

class _RecurringPreviewItem {
  const _RecurringPreviewItem(this.recurring, this.date);

  final RecurringTransaction recurring;
  final DateTime date;
}

class _UpcomingPreviewCard extends StatelessWidget {
  const _UpcomingPreviewCard({required this.upcoming});

  final List<_RecurringPreviewItem> upcoming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_repeat, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Upcoming next 90 days',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...upcoming.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.recurring.title ?? item.recurring.transactionType,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(MoneyUtils.formatDateShort(item.date)),
                    const SizedBox(width: 12),
                    Text(
                      MoneyUtils.format(item.recurring.amountMinor),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

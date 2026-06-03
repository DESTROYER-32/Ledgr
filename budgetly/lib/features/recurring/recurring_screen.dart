import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/empty_state.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(activeRecurringProvider);
    final theme = Theme.of(context);

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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final r = items[i];
              final isExpense = r.transactionType == 'expense';
              final isIncome = r.transactionType == 'income';
              final color = isExpense
                  ? AppColors.expense
                  : (isIncome ? AppColors.income : AppColors.transfer);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
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
                  title: Text(r.title ?? r.transactionType,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${_scheduleLabel(r.scheduleRule)}  ·  ${r.nextDueDate != null ? MoneyUtils.formatDateShort(r.nextDueDate!) : ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        MoneyUtils.format(r.amountMinor),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: r.active,
                        onChanged: (v) async {
                          await ref
                              .read(recurringRepositoryProvider)
                              .update(
                                r.id,
                                RecurringTransactionsCompanion(
                                    active: Value(v)),
                              );
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

  String _scheduleLabel(String rule) {
    if (rule == 'daily') return 'Daily';
    if (rule == 'weekly') return 'Weekly';
    if (rule == 'monthly') return 'Monthly';
    if (rule == 'yearly') return 'Yearly';
    return rule;
  }
}

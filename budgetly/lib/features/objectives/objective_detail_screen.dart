import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';

class ObjectiveDetailScreen extends ConsumerWidget {
  final int objectiveId;
  const ObjectiveDetailScreen({super.key, required this.objectiveId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectivesAsync = ref.watch(allObjectivesProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final theme = Theme.of(context);

    return objectivesAsync.when(
      data: (objectives) {
        final objective = objectives
            .where((o) => o.id == objectiveId)
            .firstOrNull;
        if (objective == null) {
          return const Center(child: Text('Not found'));
        }

        final transactions =
            transactionsAsync.valueOrNull
                ?.where((t) => t.objectiveFk == objectiveId)
                .toList() ??
            [];
        final totalSpent = transactions.fold<int>(
          0,
          (sum, t) => sum + t.amountMinor,
        );

        return Scaffold(
          floatingActionButton: objective.type == 'goal'
              ? FloatingActionButton.extended(
                  onPressed: () => _addMoney(context, ref, objective),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Money'),
                )
              : null,
          appBar: AppBar(
            title: const Text('Detail'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/objectives/$objectiveId/edit'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        objective.type == 'loan'
                            ? Icons.swap_horiz
                            : Icons.flag,
                        size: 48,
                        color: objective.color != null
                            ? Color(objective.color!)
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        objective.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        MoneyUtils.format(
                          objective.amountMinor,
                          currencyCode: objective.currencyCode,
                        ),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: objective.type == 'loan'
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        objective.type == 'loan'
                            ? 'Total Loaned'
                            : 'Target Amount',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: objective.amountMinor > 0
                            ? (totalSpent / objective.amountMinor).clamp(
                                0.0,
                                1.0,
                              )
                            : 0,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(totalSpent / objective.amountMinor * 100).toStringAsFixed(1)}%  \u2022  ${MoneyUtils.format(totalSpent, currencyCode: objective.currencyCode)} saved',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (objective.deadline != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Deadline: ${MoneyUtils.formatDate(objective.deadline!)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Linked Transactions', style: theme.textTheme.titleMedium),
              if (transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No transactions linked to this objective.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...transactions.map(
                  (t) => ListTile(
                    leading: Icon(
                      t.type == 'income'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: t.type == 'income' ? Colors.green : Colors.red,
                    ),
                    title: Text(t.title ?? ''),
                    subtitle: Text(MoneyUtils.formatDate(t.date)),
                    trailing: Text(
                      MoneyUtils.format(
                        t.amountMinor,
                        currencyCode: t.currencyCode,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      error: (e, _) => Center(child: Text('$e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

Future<void> _addMoney(
  BuildContext context,
  WidgetRef ref,
  Objective objective,
) async {
  final wallets = await ref.read(walletRepositoryProvider).watchActive().first;
  if (!context.mounted) return;
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (ctx) => _AddMoneyDialog(wallets: wallets),
  );
  if (result == null || !context.mounted) return;
  final walletId = result['walletId'] as int;
  final amount = ((result['amount'] as double) * 100).round();
  final date = result['date'] as DateTime;

  final wallet = await ref.read(walletRepositoryProvider).getById(walletId);
  if (wallet == null || !context.mounted) return;

  await ref
      .read(transactionRepositoryProvider)
      .insert(
        TransactionsCompanion.insert(
          type: 'income',
          specialType: const Value('none'),
          amountMinor: amount,
          currencyCode: wallet.currencyCode,
          date: date,
          walletId: walletId,
          objectiveFk: Value(objective.id),
        ),
      );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${MoneyUtils.format(amount, currencyCode: wallet.currencyCode)} added to ${objective.name}',
      ),
    ),
  );
}

class _AddMoneyDialog extends StatefulWidget {
  final List<Wallet> wallets;
  const _AddMoneyDialog({required this.wallets});

  @override
  State<_AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<_AddMoneyDialog> {
  int? _selectedWalletId;
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Money to Goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _selectedWalletId,
            decoration: const InputDecoration(
              labelText: 'Account',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            isExpanded: true,
            items: widget.wallets
                .map(
                  (w) => DropdownMenuItem<int>(
                    value: w.id,
                    child: Text('${w.name} (${w.currencyCode})'),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedWalletId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                setState(() => _date = picked);
              }
            },
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(MoneyUtils.formatDateShort(_date)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (_selectedWalletId == null || amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please select an account and enter a valid amount.',
                  ),
                ),
              );
              return;
            }
            Navigator.pop(context, {
              'walletId': _selectedWalletId,
              'amount': amount,
              'date': _date,
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

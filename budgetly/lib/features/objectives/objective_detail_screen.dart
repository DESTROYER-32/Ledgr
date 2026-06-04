import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.push('/objectives/$objectiveId/edit'),
          ),
        ],
      ),
      body: objectivesAsync.when(
        data: (objectives) {
          final objective =
              objectives.where((o) => o.id == objectiveId).firstOrNull;
          if (objective == null) {
            return const Center(child: Text('Not found'));
          }

          final transactions =
              transactionsAsync.valueOrNull?.where(
                    (t) => t.objectiveFk == objectiveId,
                  ).toList() ??
                  [];
          final totalSpent = transactions.fold<int>(
              0, (sum, t) => sum + t.amountMinor);

          return ListView(
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
                      Text(objective.name,
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        MoneyUtils.format(objective.amountMinor,
                            currencyCode: objective.currencyCode),
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
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: objective.amountMinor > 0
                            ? (totalSpent / objective.amountMinor)
                                .clamp(0.0, 1.0)
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
              Text('Linked Transactions',
                  style: theme.textTheme.titleMedium),
              if (transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No transactions linked to this objective.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              else
                ...transactions.map((t) => ListTile(
                      leading: Icon(
                        t.type == 'income'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: t.type == 'income'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(t.title ?? ''),
                      subtitle: Text(MoneyUtils.formatDate(t.date)),
                      trailing: Text(
                        MoneyUtils.format(t.amountMinor,
                            currencyCode: t.currencyCode),
                      ),
                    )),
            ],
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

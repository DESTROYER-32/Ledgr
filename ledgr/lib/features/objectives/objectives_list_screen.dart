import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/empty_state.dart';

class ObjectivesListScreen extends ConsumerWidget {
  const ObjectivesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectivesAsync = ref.watch(allObjectivesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals & Loans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/objectives/new'),
          ),
        ],
      ),
      body: objectivesAsync.when(
        data: (objectives) {
          if (objectives.isEmpty) {
            return EmptyState(
              icon: Icons.flag,
              title: 'No Goals or Loans',
              subtitle:
                  'Create savings goals or track money you lent or borrowed.',
              actionLabel: 'Add',
              onAction: () => context.push('/objectives/new'),
            );
          }
          final goals = objectives.where((o) => o.type == 'goal').toList();
          final loans = objectives.where((o) => o.type == 'loan').toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (goals.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Savings Goals',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                ...goals.map((o) => _buildTile(context, ref, o, theme)),
                const SizedBox(height: 16),
              ],
              if (loans.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Loans & Debts',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                ...loans.map((o) => _buildTile(context, ref, o, theme)),
              ],
            ],
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    WidgetRef ref,
    Objective objective,
    ThemeData theme,
  ) {
    final color = objective.color != null
        ? Color(objective.color!)
        : theme.colorScheme.primary;
    final isGoal = objective.type == 'goal';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/objectives/${objective.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      isGoal ? Icons.flag : Icons.swap_horiz,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          objective.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${isGoal ? 'Goal' : 'Loan'} \u2022 ${objective.currencyCode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      final repo = ref.read(objectiveRepositoryProvider);
                      if (v == 'archive') {
                        await repo.archive(objective.id);
                      } else if (v == 'edit') {
                        if (context.mounted) {
                          context.push('/objectives/${objective.id}/edit');
                        }
                      } else if (v == 'delete') {
                        await repo.delete(objective.id);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              if (isGoal) ...[
                const SizedBox(height: 12),
                _buildObjectiveProgress(ref, objective, theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectiveProgress(
    WidgetRef ref,
    Objective objective,
    ThemeData theme,
  ) {
    return FutureBuilder<List<Transaction>>(
      future: ref
          .read(transactionRepositoryProvider)
          .getByObjective(objective.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 4);
        final total = snapshot.data!.fold<int>(
          0,
          (sum, t) => sum + t.amountMinor,
        );
        final progress = objective.amountMinor > 0
            ? total / objective.amountMinor
            : 0.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${MoneyUtils.formatCompact(total, currencyCode: objective.currencyCode)} / ${MoneyUtils.formatCompact(objective.amountMinor, currencyCode: objective.currencyCode)}',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}

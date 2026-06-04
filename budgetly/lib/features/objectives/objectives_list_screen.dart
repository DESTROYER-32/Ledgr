import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
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
              subtitle: 'Create savings goals or track money you lent or borrowed.',
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
                  child: Text('Savings Goals',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: theme.colorScheme.primary)),
                ),
                ...goals.map((o) => _buildTile(context, ref, o, theme)),
                const SizedBox(height: 16),
              ],
              if (loans.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Loans & Debts',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: theme.colorScheme.primary)),
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

  Widget _buildTile(BuildContext context, WidgetRef ref,
      Objective objective, ThemeData theme) {
    final color = objective.color != null
        ? Color(objective.color!)
        : theme.colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            objective.type == 'loan' ? Icons.swap_horiz : Icons.flag,
            color: color,
            size: 20,
          ),
        ),
        title: Text(objective.name),
        subtitle: Text(
          '${objective.type == 'loan' ? 'Loan' : 'Goal'} \u2022 ${objective.currencyCode}',
        ),
        trailing: PopupMenuButton<String>(
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
            const PopupMenuItem(value: 'archive', child: Text('Archive')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => context.push('/objectives/${objective.id}'),
      ),
    );
  }
}

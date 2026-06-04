import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/empty_state.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static IconData _goalIconData(int? icon) {
    // ignore: non_const_argument_for_const_parameter
    if (icon != null) return IconData(icon);
    return Icons.savings;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(allGoalsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Goals & Loans')),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.flag_outlined,
              title: 'No Goals Yet',
              subtitle: 'Track savings goals, payoff targets, and long-term loans.',
              actionLabel: 'Add Goal',
              onAction: () => context.push('/goals/new'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final goal = goals[i];
              final color = goal.color != null ? Color(goal.color!) : Theme.of(context).colorScheme.primary;
              final pct = goal.targetAmountMinor > 0
                  ? (goal.currentAmountMinor / goal.targetAmountMinor).clamp(0.0, 1.0)
                  : 0.0;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.14),
                    child: Icon(
                      _goalIconData(goal.icon),
                      color: color,
                    ),
                  ),
                  title: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: pct,
                        color: color,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${MoneyUtils.format(goal.currentAmountMinor)} / ${MoneyUtils.format(goal.targetAmountMinor)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/goals/${goal.id}'),
                ),
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/goals/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

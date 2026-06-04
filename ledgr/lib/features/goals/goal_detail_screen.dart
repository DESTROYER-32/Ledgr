import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class GoalDetailScreen extends ConsumerWidget {
  final int goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  static const _goalIcons = <int, IconData>{
    0xe0b6: Icons.flag,
    0xe2e7: Icons.savings,
    0xe1e2: Icons.star,
    0xe0e0: Icons.favorite,
    0xe574: Icons.trending_up,
    0xe227: Icons.school,
    0xe149: Icons.home,
    0xe0d2: Icons.card_giftcard,
    0xe0b9: Icons.flight,
    0xe0c0: Icons.directions_car,
  };

  static IconData _goalIconData(int? icon) {
    if (icon != null && _goalIcons.containsKey(icon)) return _goalIcons[icon]!;
    return Icons.savings;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(allGoalsProvider);
    return goalsAsync.when(
      data: (goals) {
        final goal = goals.where((g) => g.id == goalId).firstOrNull;
        if (goal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Goal')),
            body: const Center(child: Text('Goal not found')),
          );
        }

        final color = goal.color != null ? Color(goal.color!) : Theme.of(context).colorScheme.primary;
        final pct = goal.targetAmountMinor > 0
            ? (goal.currentAmountMinor / goal.targetAmountMinor).clamp(0.0, 1.0)
            : 0.0;
        final remaining = goal.targetAmountMinor - goal.currentAmountMinor;

        return Scaffold(
          appBar: AppBar(
            title: Text(goal.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) async {
                  final repo = ref.read(goalRepositoryProvider);
                  if (v == 'edit') {
                    context.push('/goals/${goal.id}/edit');
                  } else if (v == 'archive') {
                    await repo.archive(goal.id);
                    if (context.mounted) context.pop();
                  } else if (v == 'delete') {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete goal?'),
                        content: Text('Delete "${goal.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await repo.delete(goal.id);
                      if (context.mounted) context.pop();
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'archive', child: Text('Archive')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _goalIconData(goal.icon),
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          const Text('Savings goal'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '${MoneyUtils.format(goal.currentAmountMinor)} / ${MoneyUtils.format(goal.targetAmountMinor)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        minHeight: 10,
                        value: pct,
                        color: color,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        remaining <= 0 ? 'Target reached' : '${MoneyUtils.format(remaining)} remaining',
                        style: TextStyle(
                          color: remaining <= 0 ? AppColors.income : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (goal.deadline != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.date_range, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              'Deadline: ${MoneyUtils.formatDateShort(goal.deadline!)}',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(title: const Text('Goal')), body: Center(child: Text('$e'))),
    );
  }
}

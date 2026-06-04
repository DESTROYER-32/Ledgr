import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';

class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(allGoalsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/goals/new'),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No goals yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => context.push('/goals/new'),
                    child: const Text('Create Goal'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (_, i) => _buildGoalCard(context, theme, goals[i]),
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

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
    return Icons.flag;
  }

  Widget _buildGoalCard(BuildContext context, ThemeData theme, Goal goal) {
    final cs = theme.colorScheme;
    final color = goal.color != null ? Color(goal.color!) : cs.primary;
    final pct = goal.targetAmountMinor > 0
        ? (goal.currentAmountMinor / goal.targetAmountMinor).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/goals/${goal.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_goalIconData(goal.icon),
                      color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(goal.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  if (goal.deadline != null)
                    Text(MoneyUtils.formatDateShort(goal.deadline!),
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: color.withValues(alpha: 0.12),
                  color: color,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(MoneyUtils.format(goal.currentAmountMinor),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                  Text(' / ${MoneyUtils.format(goal.targetAmountMinor)}',
                      style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                  const Spacer(),
                  Text('${(pct * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

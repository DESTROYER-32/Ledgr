import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  DateTime _currentMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final periodStart = _currentMonth;
    final periodEnd =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    return Scaffold(
      appBar: AppBar(
        title:
            Text('${_monthName(_currentMonth.month)} ${_currentMonth.year}'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () =>
              setState(() => _currentMonth =
                  AppDateUtils.previousMonth(_currentMonth)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                setState(() => _currentMonth =
                    AppDateUtils.nextMonth(_currentMonth)),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/budgets/new'),
            tooltip: 'Create Budget',
          ),
        ],
      ),
      body: _buildBody(theme, cs, periodStart, periodEnd),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme cs,
      DateTime start, DateTime end) {
    final budgetsAsync = ref.watch(allBudgetsProvider);
    return budgetsAsync.when(
      data: (budgets) {
        final monthBudgets = budgets.where(
          (b) =>
              !b.periodStart.isAfter(end) &&
              !b.periodEnd.isBefore(start),
        ).toList();

        if (monthBudgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.track_changes,
                    size: 64, color: cs.outline),
                const SizedBox(height: 16),
                Text('No budgets this month',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Create a budget to track your spending.',
                    style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () =>
                      context.push('/budgets/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Budget'),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...monthBudgets.map((b) =>
                _buildBudgetCard(theme, cs, b)),
          ],
        );
      },
      error: (e, _) =>
          Center(child: Text('Error: $e')),
      loading: () =>
          const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBudgetCard(
      ThemeData theme, ColorScheme cs, Budget budget) {
    final color = budget.color != null
        ? Color(budget.color!)
        : cs.primary;
    final isIncome = budget.isIncome;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            context.push('/budgets/${budget.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.06),
                cs.surface,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isIncome
                          ? Icons.savings
                          : Icons.track_changes,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(budget.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        Text(
                          isIncome
                              ? 'Savings'
                              : 'Expense',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (budget.pinned)
                    Icon(Icons.push_pin,
                        size: 14,
                        color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'delete') {
                        final ok =
                            await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title:
                                const Text('Delete Budget'),
                            content: Text(
                                'Delete "${budget.name}" and all its limits?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(
                                          ctx, false),
                                  child: const Text(
                                      'Cancel')),
                              FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(
                                          ctx, true),
                                  child: const Text(
                                      'Delete')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          final repo = ref
                              .read(
                                  budgetRepositoryProvider);
                          await repo.delete(budget.id);
                        }
                      }
                    },
                    icon: Icon(Icons.more_vert,
                        size: 18,
                        color: cs.onSurfaceVariant),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.date_range,
                      size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${MoneyUtils.formatDateShort(budget.periodStart)} - ${MoneyUtils.formatDateShort(budget.periodEnd)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}

class AppDateUtils {
  static DateTime previousMonth(DateTime d) =>
      DateTime(d.year, d.month - 1, 1);
  static DateTime nextMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 1);
}

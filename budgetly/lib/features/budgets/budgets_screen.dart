import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repositories/transaction_repository.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final periodStart = _currentMonth;
    final periodEnd = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_monthName(_currentMonth.month)} ${_currentMonth.year}'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => setState(
            () => _currentMonth = AppDateUtils.previousMonth(_currentMonth),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(
              () => _currentMonth = AppDateUtils.nextMonth(_currentMonth),
            ),
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

  Widget _buildBody(
    ThemeData theme,
    ColorScheme cs,
    DateTime start,
    DateTime end,
  ) {
    final budgetsAsync = ref.watch(allBudgetsProvider);
    return budgetsAsync.when(
      data: (budgets) {
        final monthBudgets = budgets
            .where(
              (b) =>
                  !b.periodStart.isAfter(end) && !b.periodEnd.isBefore(start),
            )
            .toList();

        if (monthBudgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.track_changes, size: 64, color: cs.outline),
                const SizedBox(height: 16),
                Text(
                  'No budgets this month',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a budget to track your spending.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/budgets/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Budget'),
                ),
              ],
            ),
          );
        }

        final expenseBudgets = monthBudgets.where((b) => !b.isIncome).toList();
        final savingsBudgets = monthBudgets.where((b) => b.isIncome).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (expenseBudgets.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Budgets',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              ...expenseBudgets.map(
                (b) => _buildBudgetCard(theme, cs, b, false),
              ),
            ],
            if (savingsBudgets.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Goals',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              ...savingsBudgets.map(
                (b) => _buildBudgetCard(theme, cs, b, true),
              ),
            ],
            if (monthBudgets.isEmpty) ...[],
            _buildAddBudgetCard(theme, cs),
          ],
        );
      },
      error: (e, _) => Center(child: Text('Error: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBudgetCard(
    ThemeData theme,
    ColorScheme cs,
    Budget budget,
    bool isGoal,
  ) {
    final color = AppColors.fromStored(budget.color, cs.primary);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/budgets/${budget.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.06), cs.surface],
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isGoal ? Icons.savings : Icons.track_changes,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          isGoal ? 'Goal' : 'Budget',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (budget.pinned)
                    Icon(Icons.push_pin, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'delete') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Budget'),
                            content: Text(
                              'Delete "${budget.name}" and all its limits?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          final repo = ref.read(budgetRepositoryProvider);
                          await repo.delete(budget.id);
                        }
                      }
                    },
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18),
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
                  Icon(Icons.date_range, size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${MoneyUtils.formatDateShort(budget.periodStart)} - ${MoneyUtils.formatDateShort(budget.periodEnd)}',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildProgressBar(budget, isGoal, cs),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _budgetTotal(
    TransactionRepository repo,
    Budget budget,
    bool isGoal,
  ) async {
    if (budget.specificMode) {
      return repo.totalByBudget(
        budgetId: budget.id,
        start: budget.periodStart,
        end: budget.periodEnd,
        type: isGoal ? 'income' : 'expense',
      );
    }
    return isGoal
        ? repo.totalIncome(budget.periodStart, budget.periodEnd)
        : repo.totalExpenses(budget.periodStart, budget.periodEnd);
  }

  Widget _buildProgressBar(Budget budget, bool isGoal, ColorScheme cs) {
    final repo = ref.read(transactionRepositoryProvider);
    return FutureBuilder<int>(
      future: _budgetTotal(repo, budget, isGoal),
      builder: (context, snapshot) {
        if (!snapshot.hasData || budget.plannedAmountMinor == 0) {
          return const SizedBox(height: 4);
        }
        final total = snapshot.data!;
        final progress = total / budget.plannedAmountMinor;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${MoneyUtils.formatCompact(total, currencyCode: budget.currencyCode)} / ${MoneyUtils.formatCompact(budget.plannedAmountMinor, currencyCode: budget.currencyCode)}',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddBudgetCard(ThemeData theme, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 1.5),
      ),
      color: cs.surfaceContainerLow,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/budgets/new'),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Create Budget',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}

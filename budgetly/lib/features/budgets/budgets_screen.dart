import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  DateTime _currentMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  Budget? _budget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          if (_budget != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'delete') _deleteBudget(_budget!);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Delete Budget'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(theme, periodStart, periodEnd),
      floatingActionButton: _budget != null
          ? FloatingActionButton(
              onPressed: () => _addLimit(_budget!),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(ThemeData theme, DateTime start, DateTime end) {
    final budgetsAsync = ref.watch(allBudgetsProvider);
    return budgetsAsync.when(
      data: (budgets) {
        final budget = budgets.where(
          (b) => b.periodStart == start && b.periodEnd == end,
        ).firstOrNull;
        _budget = budget;
        if (budget == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.track_changes,
                    size: 64, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text('No budget set',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _createBudget(start, end),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Budget'),
                ),
              ],
            ),
          );
        }
        return _budgetLimitsView(theme, budget, start, end);
      },
      error: (e, _) => Center(child: Text('Error: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _budgetLimitsView(ThemeData theme, Budget budget, DateTime start, DateTime end) {
    final limitsAsync = ref.watch(budgetLimitsProvider(budget.id));
    final catsAsync = ref.watch(activeCategoriesProvider);
    return limitsAsync.when(
      data: (limits) {
        if (limits.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No spending limits set.',
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _addLimit(budget),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Limit'),
                ),
              ],
            ),
          );
        }
        return catsAsync.when(
          data: (cats) {
            final catMap = {for (final c in cats) c.id: c};
            return ListView(
              padding: const EdgeInsets.all(16),
              children: limits.map((limit) {
                return _buildLimitCard(theme, budget, limit, start, end, catMap);
              }).toList(),
            );
          },
          error: (e, _) => Center(child: Text('Error: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
      error: (e, _) => Center(child: Text('Error: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLimitCard(ThemeData theme, Budget budget,
      BudgetCategoryLimit limit, DateTime start, DateTime end,
      Map<int, Category> catMap) {
    final cat = catMap[limit.categoryId];
    final catName = cat?.name ?? 'Deleted Category';
    final catColor = cat?.color != null ? Color(cat!.color!) : theme.colorScheme.primary;

    final periodKey = '${start.toIso8601String()},${end.toIso8601String()}';
    final transactionsAsync = ref.watch(spentByCategoryProvider(periodKey));
    return transactionsAsync.when(
      data: (spentMap) {
        final spent = spentMap[limit.categoryId] ?? 0;
        final remaining = limit.plannedAmountMinor - spent;
        final percentage = limit.plannedAmountMinor > 0
            ? (spent / limit.plannedAmountMinor).clamp(0.0, 1.0)
            : 0.0;
        final isOver = remaining < 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                        backgroundColor: catColor.withValues(alpha: 0.15),
                        radius: 16),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(catName,
                            style: const TextStyle(fontWeight: FontWeight.w600))),
                    Text(MoneyUtils.format(spent),
                        style: TextStyle(
                            color: isOver ? AppColors.expense : null)),
                    const SizedBox(width: 8),
                    Text('/ ${MoneyUtils.format(limit.plannedAmountMinor)}',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(width: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _removeLimit(budget.id, limit.categoryId),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 14,
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: isOver ? AppColors.expense : AppColors.income,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOver
                      ? '${MoneyUtils.format(-remaining)} over'
                      : '${MoneyUtils.format(remaining)} remaining',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: isOver
                          ? AppColors.expense
                          : theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
      error: (_, _) => const Card(
        margin: EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Error loading spent data'),
        ),
      ),
      loading: () => const Card(
        margin: EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> _createBudget(DateTime start, DateTime end) async {
    final repo = ref.read(budgetRepositoryProvider);
    final budgetId = await repo.insert(BudgetsCompanion.insert(
      name: '${_monthName(start.month)} ${start.year}',
      periodStart: start,
      periodEnd: end,
      currencyCode: 'USD',
    ));
    final budget = await repo.getById(budgetId);
    if (budget != null) _addLimit(budget);
  }

  Future<void> _addLimit(Budget budget) async {
    final cats = await ref.read(categoryRepositoryProvider).watchActive().first;
    if (!mounted) return;
    final expenseCats = cats.where((c) => c.kind == 'expense').toList();
    if (expenseCats.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No expense categories found.'),
            action: SnackBarAction(
              label: 'Create',
              onPressed: () => context.push('/categories'),
            ),
          ),
        );
      }
      return;
    }

    Category? selectedCat;
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Spending Limit'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Category>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: expenseCats
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        ))
                    .toList(),
                onChanged: (v) => selectedCat = v,
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter an amount';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(c, true);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && selectedCat != null && mounted) {
      final amount = (double.tryParse(amountController.text) ?? 0) * 100;
      if (amount > 0) {
        await ref
            .read(budgetRepositoryProvider)
            .setLimit(budget.id, selectedCat!.id, amount.round());
      }
    }
  }

  Future<void> _deleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Delete this budget and all its spending limits?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final repo = ref.read(budgetRepositoryProvider);
      final limits = await repo.watchLimits(budget.id).first;
      for (final limit in limits) {
        await repo.removeLimit(budget.id, limit.categoryId);
      }
      await repo.delete(budget.id);
    }
  }

  Future<void> _removeLimit(int budgetId, int categoryId) async {
    final repo = ref.read(budgetRepositoryProvider);
    await repo.removeLimit(budgetId, categoryId);
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        ],
      ),
      body: _buildBody(theme, periodStart, periodEnd),
    );
  }

  Widget _buildBody(ThemeData theme, DateTime start, DateTime end) {
    return FutureBuilder<Budget?>(
      future: ref.read(budgetRepositoryProvider).getForPeriod(start, end),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final budget = snapshot.data;
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
    );
  }

  Widget _budgetLimitsView(ThemeData theme, Budget budget, DateTime start, DateTime end) {
    final limitsStream =
        ref.read(budgetRepositoryProvider).watchLimits(budget.id);
    return StreamBuilder(
      stream: limitsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final limits = snapshot.data!;
        if (limits.isEmpty) {
          return Center(
            child: Text('No spending limits set. Tap + to add.',
                style: theme.textTheme.bodyLarge),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: limits.map((limit) {
            return _buildLimitCard(theme, budget, limit, start, end);
          }).toList(),
        );
      },
    );
  }

  Widget _buildLimitCard(ThemeData theme, Budget budget,
      BudgetCategoryLimit limit, DateTime start, DateTime end) {
    final catsAsync = ref.watch(activeCategoriesProvider);
    String catName = 'Category ${limit.categoryId}';
    Color catColor = theme.colorScheme.primary;
    catsAsync.whenData((cats) {
      final cat = cats.where((c) => c.id == limit.categoryId).firstOrNull;
      if (cat != null) {
        catName = cat.name;
        if (cat.color != null) catColor = Color(cat.color!);
      }
    });

    return FutureBuilder<int>(
      future: ref
          .read(transactionRepositoryProvider)
          .spentByCategory(start, end)
          .then((map) => map[limit.categoryId] ?? 0),
      builder: (context, spentSnap) {
        final spent = spentSnap.data ?? 0;
        final remaining = limit.plannedAmountMinor - spent;
        final percentage = limit.plannedAmountMinor > 0
            ? (spent / limit.plannedAmountMinor).clamp(0.0, 1.0)
            : 0.0;
        final isOver = remaining < 0;

        final raw = limit.plannedAmountMinor;
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
                    Text('/ ${MoneyUtils.format(raw)}',
                        style: theme.textTheme.bodySmall),
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

    final cats = await ref.read(categoryRepositoryProvider).watchActive().first;
    if (!mounted) return;
    final scaffoldContext = context;
    for (final cat in cats.where((c) => c.kind == 'expense')) {
      final amountStr = await showDialog<String>(
        // ignore: use_build_context_synchronously
        context: scaffoldContext,
        builder: (c) => AlertDialog(
          title: Text('Limit for ${cat.name}'),
          content: const TextField(
            decoration: InputDecoration(
                labelText: 'Amount', prefixText: '\$ '),
            keyboardType:
                TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Skip')),
            FilledButton(
                onPressed: () => Navigator.pop(c, '0'),
                child: const Text('Set \$0')),
          ],
        ),
      );
      if (amountStr != null && mounted) {
        final amount = (double.tryParse(amountStr) ?? 0) * 100;
        if (amount > 0) {
          await repo.setLimit(budgetId, cat.id, amount.round());
        }
      }
    }
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}

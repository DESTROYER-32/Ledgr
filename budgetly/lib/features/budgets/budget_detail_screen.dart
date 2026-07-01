import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/modern_selection_field.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/transaction_tile.dart';

class BudgetDetailScreen extends ConsumerStatefulWidget {
  final int budgetId;
  const BudgetDetailScreen({super.key, required this.budgetId});

  @override
  ConsumerState<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends ConsumerState<BudgetDetailScreen> {
  Budget? _budget;
  List<BudgetCategoryLimit> _limits = [];
  Map<int, int> _spentByCategory = {};
  int _totalSpent = 0;
  int _totalPlanned = 0;
  int _prevTotalSpent = 0;
  bool _loading = true;
  DateTime? _currentStart;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(budgetRepositoryProvider);
    final budget = await repo.getById(widget.budgetId);
    if (budget == null) {
      if (mounted) context.pop();
      return;
    }
    _currentStart = budget.periodStart;
    final limits = await repo.watchLimits(budget.id).first;
    final txRepo = ref.read(transactionRepositoryProvider);
    final totalPlanned = limits.isNotEmpty
        ? limits.fold<int>(0, (s, l) => s + l.plannedAmountMinor)
        : budget.plannedAmountMinor;

    Map<int, int> byCategory;
    int totalSpent;
    if (budget.specificMode) {
      final filtered = await txRepo.getByBudget(
        budgetId: budget.id,
        start: _currentStart!,
        end: budget.periodEnd,
        type: budget.isIncome ? 'income' : 'expense',
      );
      byCategory = <int, int>{};
      for (final t in filtered) {
        if (t.categoryId != null) {
          byCategory.update(
            t.categoryId!,
            (v) => v + t.amountMinor,
            ifAbsent: () => t.amountMinor,
          );
        }
      }
      totalSpent = filtered.fold<int>(0, (s, t) => s + t.amountMinor);
    } else if (budget.isIncome) {
      byCategory = await txRepo.incomeByCategory(
        _currentStart!,
        budget.periodEnd,
      );
      totalSpent = byCategory.values.fold<int>(0, (s, v) => s + v);
    } else {
      byCategory = await txRepo.spentByCategory(
        _currentStart!,
        budget.periodEnd,
      );
      totalSpent = byCategory.values.fold<int>(0, (s, v) => s + v);
    }

    final filteredSpent = limits.isNotEmpty
        ? Map.fromEntries(
            byCategory.entries.where(
              (e) => limits.any((l) => l.categoryId == e.key),
            ),
          )
        : byCategory;

    final duration = budget.periodEnd.difference(budget.periodStart);
    final prevEnd = budget.periodStart.subtract(const Duration(days: 1));
    final prevStart = prevEnd.subtract(duration);
    int prevTotalSpent;
    if (budget.specificMode) {
      prevTotalSpent = await txRepo.totalByBudget(
        budgetId: budget.id,
        start: prevStart,
        end: prevEnd,
        type: budget.isIncome ? 'income' : 'expense',
      );
    } else if (budget.isIncome) {
      final prevByCategory = await txRepo.incomeByCategory(prevStart, prevEnd);
      prevTotalSpent = prevByCategory.values.fold<int>(0, (s, v) => s + v);
    } else {
      final prevByCategory = await txRepo.spentByCategory(prevStart, prevEnd);
      prevTotalSpent = prevByCategory.values.fold<int>(0, (s, v) => s + v);
    }

    if (mounted) {
      setState(() {
        _budget = budget;
        _limits = limits;
        _spentByCategory = filteredSpent;
        _totalSpent = limits.isNotEmpty
            ? filteredSpent.values.fold<int>(0, (s, v) => s + v)
            : totalSpent;
        _totalPlanned = totalPlanned;
        _prevTotalSpent = prevTotalSpent;
        _loading = false;
      });
    }
  }

  Future<void> _addLimit() async {
    final cats = await ref.read(categoryRepositoryProvider).getActive();
    if (!mounted) return;
    final cat = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _LimitDialog(
        categories: cats,
        isIncome: _budget!.isIncome,
        currencyCode: _budget!.currencyCode,
      ),
    );
    if (cat == null) return;
    final repo = ref.read(budgetRepositoryProvider);
    await repo.setLimit(
      widget.budgetId,
      cat['categoryId'] as int,
      amount: cat['amount'] as int,
    );
    _load();
  }

  Future<void> _removeLimit(int categoryId) async {
    final repo = ref.read(budgetRepositoryProvider);
    await repo.removeLimit(widget.budgetId, categoryId);
    _load();
  }

  Future<void> _addMoneyToGoal(Budget budget) async {
    final wallets = await ref.read(walletRepositoryProvider).getActive();
    if (!mounted) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddMoneyDialog(wallets: wallets, budget: budget),
    );
    if (result == null || !mounted) return;
    final walletId = result['walletId'] as int;
    final wallet = await ref.read(walletRepositoryProvider).getById(walletId);
    if (wallet == null || !mounted) return;

    final amount = MoneyUtils.toMinor(
      result['amount'] as double,
      currencyCode: wallet.currencyCode,
    );
    final date = result['date'] as DateTime;

    await ref.read(transactionRepositoryProvider).insertWithBudgets(
      TransactionsCompanion.insert(
        type: 'income',
        specialType: const Value('none'),
        amountMinor: amount,
        currencyCode: wallet.currencyCode,
        date: date,
        walletId: walletId,
      ),
      [budget.id],
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${MoneyUtils.format(amount, currencyCode: wallet.currencyCode)} added to ${budget.name}',
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budget')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final budget = _budget!;
    final color = AppColors.fromStored(budget.color, cs.primary);
    final pct = _totalPlanned > 0
        ? (_totalSpent / _totalPlanned).clamp(0.0, 1.0)
        : 0.0;
    final remaining = _totalPlanned - _totalSpent;
    final isOver = _totalSpent > _totalPlanned;

    return Scaffold(
      floatingActionButton: budget.isIncome
          ? FloatingActionButton.extended(
              onPressed: () => _addMoneyToGoal(budget),
              icon: const Icon(Icons.add),
              label: const Text('Add Money'),
            )
          : null,
      appBar: AppBar(
        title: Text(budget.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') {
                context.push('/budgets/${budget.id}/edit');
              } else if (v == 'pin') {
                final repo = ref.read(budgetRepositoryProvider);
                await repo.update(
                  budget.id,
                  BudgetsCompanion(pinned: Value(!budget.pinned)),
                );
                _load();
              } else if (v == 'delete') {
                final nav = Navigator.of(context);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete budget?'),
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
                if (ok == true && mounted) {
                  final repo = ref.read(budgetRepositoryProvider);
                  await repo.delete(budget.id);
                  nav.pop();
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'pin',
                child: ListTile(
                  leading: Icon(
                    budget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                  title: Text(budget.pinned ? 'Unpin' : 'Pin to dashboard'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: AppColors.expense),
                  title: Text(
                    'Delete',
                    style: TextStyle(color: AppColors.expense),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildHeader(theme, cs, budget, color),
          const SizedBox(height: 16),
          _buildProgressCard(theme, cs, budget, color, pct, remaining, isOver),
          const SizedBox(height: 16),
          _buildHistoryCard(theme, cs, budget),
          const SizedBox(height: 16),
          if (_limits.isNotEmpty)
            _buildCategoryBreakdown(theme, cs, budget, color),
          if (_spentByCategory.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPieChart(theme, cs, budget),
          ],
          const SizedBox(height: 16),
          _buildTransactions(theme, cs, budget),
        ],
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    ColorScheme cs,
    Budget budget,
    Color color,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.08), cs.surface],
          ),
        ),
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
                    budget.isIncome ? Icons.savings : Icons.track_changes,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      budget.isIncome ? 'Goal' : 'Budget',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (budget.pinned)
                  Icon(Icons.push_pin, size: 16, color: cs.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.date_range, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  '${MoneyUtils.formatDateShort(budget.periodStart)} - ${MoneyUtils.formatDateShort(budget.periodEnd)}',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ThemeData theme, ColorScheme cs, Budget budget) {
    final diff = _totalSpent - _prevTotalSpent;
    final pctChange = _prevTotalSpent > 0
        ? ((diff / _prevTotalSpent) * 100).round()
        : 0;
    final increased = diff > 0;
    final isIncome = budget.isIncome;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'vs Previous Period',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  increased ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 20,
                  color: increased == isIncome
                      ? AppColors.income
                      : AppColors.expense,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${MoneyUtils.format(_prevTotalSpent, currencyCode: budget.currencyCode)} \u2192 ${MoneyUtils.format(_totalSpent, currencyCode: budget.currencyCode)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${increased ? '+' : ''}$pctChange% ${_historyChangeLabel(isIncome: isIncome, increased: increased)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    ThemeData theme,
    ColorScheme cs,
    Budget budget,
    Color color,
    double pct,
    int remaining,
    bool isOver,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  budget.isIncome ? 'Saved' : 'Spent',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (_totalPlanned > 0)
                  Text(
                    '${MoneyUtils.format(_totalSpent, currencyCode: budget.currencyCode)} / ${MoneyUtils.format(_totalPlanned, currencyCode: budget.currencyCode)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            if (_totalPlanned > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: isOver
                      ? AppColors.expense
                      : (budget.isIncome ? AppColors.income : color),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    isOver
                        ? '${MoneyUtils.format(-remaining, currencyCode: budget.currencyCode)} over'
                        : '${MoneyUtils.format(remaining, currencyCode: budget.currencyCode)} ${budget.isIncome ? 'left to save' : 'remaining'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOver ? AppColors.expense : cs.onSurfaceVariant,
                      fontWeight: isOver ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
            if (_totalPlanned == 0 && _totalSpent > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  budget.isIncome
                      ? 'Saved ${MoneyUtils.format(_totalSpent, currencyCode: budget.currencyCode)} (no goal set)'
                      : 'Spent ${MoneyUtils.format(_totalSpent, currencyCode: budget.currencyCode)} (no limit set)',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    ThemeData theme,
    ColorScheme cs,
    Budget budget,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ..._limits.map((limit) {
              final spent = _spentByCategory[limit.categoryId] ?? 0;
              final pct = limit.plannedAmountMinor > 0
                  ? (spent / limit.plannedAmountMinor).clamp(0.0, 2.0)
                  : 0.0;
              final over = spent > limit.plannedAmountMinor;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryLimitRow(
                  limit: limit,
                  spent: spent,
                  pct: pct,
                  over: over,
                  currencyCode: budget.currencyCode,
                  onRemove: () => _removeLimit(limit.categoryId),
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addLimit,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Limit', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme, ColorScheme cs, Budget budget) {
    final cats = ref.watch(activeCategoriesProvider).valueOrNull ?? [];
    final catMap = {for (final c in cats) c.id: c};
    final sorted = _spentByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = _spentByCategory.values.fold<int>(0, (s, v) => s + v);

    if (total == 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget.isIncome ? 'Income Breakdown' : 'Spending Breakdown',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: sorted.map((e) {
                          final cat = catMap[e.key];
                          final c = cat == null
                              ? cs.primary
                              : AppColors.fromStored(cat.color, cs.primary);
                          final pct = e.value / total;
                          return PieChartSectionData(
                            value: pct * 100,
                            color: c,
                            radius: 28,
                            title: '${(pct * 100).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sorted.take(5).map((e) {
                        final cat = catMap[e.key];
                        final c = cat == null
                            ? cs.primary
                            : AppColors.fromStored(cat.color, cs.primary);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  cat?.name ?? 'Cat ${e.key}',
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions(ThemeData theme, ColorScheme cs, Budget budget) {
    Widget buildList(List<Transaction> txns) {
      final categoriesById = {
        for (final c
            in ref.watch(activeCategoriesProvider).valueOrNull ?? <Category>[])
          c.id: c,
      };
      final filtered = txns.where((t) {
        if (_limits.isNotEmpty && t.type == 'expense' && t.categoryId != null) {
          return _limits.any((l) => l.categoryId == t.categoryId);
        }
        return true;
      }).toList()..sort((a, b) => b.date.compareTo(a.date));

      if (filtered.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Transactions',
            actionLabel: null,
            onAction: null,
          ),
          ...filtered.take(10).map((t) {
            final category = t.categoryId == null
                ? null
                : categoriesById[t.categoryId];
            return TransactionTile(
              id: t.id,
              type: t.type,
              amountMinor: t.amountMinor,
              title: t.title,
              date: t.date,
              categoryName: category?.name,
              categoryColor: category == null
                  ? null
                  : AppColors.fromStored(category.color, cs.primary),
              categoryIcon: category?.icon,
              currencyCode: t.currencyCode,
              onTap: () => context.push('/transactions/${t.id}'),
            );
          }),
        ],
      );
    }

    if (budget.specificMode) {
      return FutureBuilder<List<Transaction>>(
        future: ref
            .read(transactionRepositoryProvider)
            .getByBudget(
              budgetId: budget.id,
              start: budget.periodStart,
              end: budget.periodEnd,
              type: budget.isIncome ? 'income' : 'expense',
            ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          return buildList(snapshot.data ?? const <Transaction>[]);
        },
      );
    }

    return ref
        .watch(allTransactionsProvider)
        .when(
          data: (txns) {
            final filtered = txns.where((t) {
              final inDateRange =
                  !t.date.isBefore(budget.periodStart) &&
                  !t.date.isAfter(budget.periodEnd);
              final matchesType =
                  t.type == (budget.isIncome ? 'income' : 'expense');
              return inDateRange && matchesType;
            }).toList();
            return buildList(filtered);
          },
          error: (_, _) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        );
  }
}

String _historyChangeLabel({required bool isIncome, required bool increased}) {
  if (isIncome) return increased ? 'more saved' : 'less saved';
  return increased ? 'more spent' : 'less spent';
}

class _CategoryLimitRow extends StatelessWidget {
  final BudgetCategoryLimit limit;
  final int spent;
  final double pct;
  final bool over;
  final String currencyCode;
  final VoidCallback onRemove;

  const _CategoryLimitRow({
    required this.limit,
    required this.spent,
    required this.pct,
    required this.over,
    required this.currencyCode,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.close, size: 14, color: cs.onSurfaceVariant),
                  Consumer(
                    builder: (context, ref, _) {
                      final cats =
                          ref.watch(activeCategoriesProvider).valueOrNull ?? [];
                      final cat = cats
                          .where((c) => c.id == limit.categoryId)
                          .firstOrNull;
                      return Text(
                        cat?.name ?? 'Category ${limit.categoryId}',
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),
                  const Spacer(),
                  Text(
                    '${spent > 0 ? MoneyUtils.format(spent, currencyCode: currencyCode) : ''} / ${MoneyUtils.format(limit.plannedAmountMinor, currencyCode: currencyCode)}',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: over ? AppColors.expense : cs.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            icon: Icon(Icons.close, size: 14, color: cs.onSurfaceVariant),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}

class _LimitDialog extends StatefulWidget {
  final List<Category> categories;
  final bool isIncome;
  final String currencyCode;
  const _LimitDialog({
    required this.categories,
    required this.isIncome,
    required this.currencyCode,
  });

  @override
  State<_LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<_LimitDialog> {
  int? _selectedCatId;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Limit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModernSelectionField<int>(
            label: 'Category',
            value: _selectedCatId,
            leadingIcon: Icons.category_outlined,
            items: widget.categories
                .where(
                  (c) => widget.isIncome
                      ? (c.kind == 'income' || c.kind == 'both')
                      : (c.kind == 'expense' || c.kind == 'both'),
                )
                .map(
                  (c) => ModernSelectionItem(
                    value: c.id,
                    title: c.name,
                    subtitle: c.kind,
                    icon: Icons.category_outlined,
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedCatId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_selectedCatId == null || _amountController.text.isEmpty) {
              return;
            }
            final amt = MoneyUtils.toMinor(
              double.tryParse(_amountController.text) ?? 0,
              currencyCode: widget.currencyCode,
            );
            Navigator.pop(context, {
              'categoryId': _selectedCatId!,
              'amount': amt,
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _AddMoneyDialog extends StatefulWidget {
  final List<Wallet> wallets;
  final Budget budget;
  const _AddMoneyDialog({required this.wallets, required this.budget});

  @override
  State<_AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<_AddMoneyDialog> {
  int? _selectedWalletId;
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Money to Goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModernSelectionField<int>(
            label: 'Account',
            value: _selectedWalletId,
            leadingIcon: Icons.account_balance_wallet_outlined,
            items: widget.wallets
                .map(
                  (w) => ModernSelectionItem(
                    value: w.id,
                    title: w.name,
                    subtitle: w.type.replaceAll('_', ' '),
                    icon: Icons.account_balance_outlined,
                    badge: w.currencyCode,
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedWalletId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                setState(() => _date = picked);
              }
            },
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(MoneyUtils.formatDateShort(_date)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (_selectedWalletId == null || amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please select an account and enter a valid amount.',
                  ),
                ),
              );
              return;
            }
            Navigator.pop(context, {
              'walletId': _selectedWalletId,
              'amount': amount,
              'date': _date,
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

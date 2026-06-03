import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/transaction_tile.dart';

class BudgetDetailScreen extends ConsumerStatefulWidget {
  final int budgetId;
  const BudgetDetailScreen({super.key, required this.budgetId});

  @override
  ConsumerState<BudgetDetailScreen> createState() =>
      _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends ConsumerState<BudgetDetailScreen> {
  Budget? _budget;
  List<BudgetCategoryLimit> _limits = [];
  Map<int, int> _spentByCategory = {};
  int _totalSpent = 0;
  int _totalPlanned = 0;
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
    _currentStart ??= budget.periodStart;
    final limits = await repo.watchLimits(budget.id).first;
    final txRepo = ref.read(transactionRepositoryProvider);
    final totalPlanned =
        limits.fold<int>(0, (s, l) => s + l.plannedAmountMinor);

    Map<int, int> byCategory;
    int totalSpent;
    if (budget.isIncome) {
      byCategory = await txRepo.incomeByCategory(
          _currentStart!, budget.periodEnd);
      totalSpent =
          byCategory.values.fold<int>(0, (s, v) => s + v);
    } else {
      byCategory = await txRepo.spentByCategory(
          _currentStart!, budget.periodEnd);
      totalSpent =
          byCategory.values.fold<int>(0, (s, v) => s + v);
    }

    final filteredSpent = limits.isNotEmpty
        ? Map.fromEntries(byCategory.entries
            .where((e) => limits.any((l) => l.categoryId == e.key)))
        : byCategory;

    if (mounted) {
      setState(() {
        _budget = budget;
        _limits = limits;
        _spentByCategory = filteredSpent;
        _totalSpent = totalSpent;
        _totalPlanned = totalPlanned;
        _loading = false;
      });
    }
  }

  Future<void> _addLimit() async {
    final cats = await ref.read(categoryRepositoryProvider).watchActive().first;
    if (!mounted) return;
    final cat = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _LimitDialog(
        categories: cats,
        isIncome: _budget!.isIncome,
      ),
    );
    if (cat == null) return;
    final repo = ref.read(budgetRepositoryProvider);
    await repo.setLimit(
      widget.budgetId,
      cat['categoryId'] as int,
      cat['amount'] as int,
    );
    _load();
  }

  Future<void> _removeLimit(int categoryId) async {
    final repo = ref.read(budgetRepositoryProvider);
    await repo.removeLimit(widget.budgetId, categoryId);
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
    final color = budget.color != null
        ? Color(budget.color!)
        : cs.primary;
    final pct = _totalPlanned > 0
        ? (_totalSpent / _totalPlanned).clamp(0.0, 2.0)
        : 0.0;
    final remaining = _totalPlanned - _totalSpent;
    final isOver = _totalSpent > _totalPlanned;

    return Scaffold(
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
                        'Delete "${budget.name}" and all its limits?'),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () =>
                              Navigator.pop(ctx, true),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (ok == true && mounted) {
                  final repo =
                      ref.read(budgetRepositoryProvider);
                  await repo.deleteWithLimits(budget.id);
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
                      contentPadding: EdgeInsets.zero)),
              PopupMenuItem(
                  value: 'pin',
                  child: ListTile(
                      leading: Icon(budget.pinned
                          ? Icons.push_pin
                          : Icons.push_pin_outlined),
                      title: Text(
                          budget.pinned ? 'Unpin' : 'Pin to dashboard'),
                      contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                      leading: Icon(Icons.delete,
                          color: AppColors.expense),
                      title: Text('Delete',
                          style: TextStyle(
                              color: AppColors.expense)),
                      contentPadding: EdgeInsets.zero)),
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

  Widget _buildHeader(ThemeData theme, ColorScheme cs,
      Budget budget, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.08),
              cs.surface,
            ],
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
                    budget.isIncome
                        ? Icons.savings
                        : Icons.track_changes,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      budget.isIncome ? 'Savings' : 'Expense',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (budget.pinned)
                  Icon(Icons.push_pin,
                      size: 16, color: cs.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.date_range,
                    size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  '${MoneyUtils.formatDateShort(budget.periodStart)} - ${MoneyUtils.formatDateShort(budget.periodEnd)}',
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant),
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
      bool isOver) {
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
                    '${MoneyUtils.format(_totalSpent)} / ${MoneyUtils.format(_totalPlanned)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
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
                  backgroundColor:
                      cs.surfaceContainerHighest,
                  color: isOver
                      ? AppColors.expense
                      : (budget.isIncome
                          ? AppColors.income
                          : color),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    isOver
                        ? '${MoneyUtils.format(-remaining)} over'
                        : '${MoneyUtils.format(remaining)} ${budget.isIncome ? 'left to save' : 'remaining'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOver
                          ? AppColors.expense
                          : cs.onSurfaceVariant,
                      fontWeight: isOver
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            if (_totalPlanned == 0 && _totalSpent > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  budget.isIncome
                      ? 'Saved ${MoneyUtils.format(_totalSpent)} (no goal set)'
                      : 'Spent ${MoneyUtils.format(_totalSpent)} (no limit set)',
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme, ColorScheme cs,
      Budget budget, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Breakdown',
                style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            )),
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
                  onRemove: () => _removeLimit(limit.categoryId),
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addLimit,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Limit',
                  style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme, ColorScheme cs,
      Budget budget) {
    final cats = ref.watch(activeCategoriesProvider).valueOrNull ?? [];
    final catMap = {for (final c in cats) c.id: c};
    final sorted = _spentByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total =
        _spentByCategory.values.fold<int>(0, (s, v) => s + v);

    if (total == 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(budget.isIncome ? 'Income Breakdown' : 'Spending Breakdown',
                style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            )),
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
                          final c = cat?.color != null
                              ? Color(cat!.color!)
                              : cs.primary;
                          final pct = e.value / total;
                          return PieChartSectionData(
                            value: pct * 100,
                            color: c,
                            radius: 28,
                            title:
                                '${(pct * 100).toStringAsFixed(0)}%',
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: sorted.take(5).map((e) {
                        final cat = catMap[e.key];
                        final c = cat?.color != null
                            ? Color(cat!.color!)
                            : cs.primary;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2),
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
                                  style: const TextStyle(
                                      fontSize: 11),
                                  overflow:
                                      TextOverflow.ellipsis,
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

  Widget _buildTransactions(ThemeData theme, ColorScheme cs,
      Budget budget) {
    return ref.watch(allTransactionsProvider).when(
      data: (txns) {
        final filtered = txns.where((t) {
          final inDateRange = !t.date.isBefore(budget.periodStart) &&
              !t.date.isAfter(budget.periodEnd);
          if (!inDateRange) return false;
          if (_limits.isNotEmpty &&
              t.type == 'expense' &&
              t.categoryId != null) {
            return _limits.any((l) => l.categoryId == t.categoryId);
          }
          return true;
        }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        if (filtered.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Transactions',
              actionLabel: null,
              onAction: null,
            ),
            ...filtered.take(10).map((t) => TransactionTile(
                  id: t.id,
                  type: t.type,
                  amountMinor: t.amountMinor,
                  title: t.title,
                  date: t.date,
                  onTap: () =>
                      context.push('/transactions/${t.id}'),
                )),
          ],
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _CategoryLimitRow extends StatelessWidget {
  final BudgetCategoryLimit limit;
  final int spent;
  final double pct;
  final bool over;
  final VoidCallback onRemove;

  const _CategoryLimitRow({
    required this.limit,
    required this.spent,
    required this.pct,
    required this.over,
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
                  Icon(Icons.close, size: 14,
                      color: cs.onSurfaceVariant),
                  Consumer(builder: (context, ref, _) {
                    final cats = ref
                            .watch(activeCategoriesProvider)
                            .valueOrNull ??
                        [];
                    final cat = cats
                        .where((c) => c.id == limit.categoryId)
                        .firstOrNull;
                    return Text(
                      cat?.name ?? 'Category ${limit.categoryId}',
                      style: const TextStyle(fontSize: 13),
                    );
                  }),
                  const Spacer(),
                  Text(
                    '${spent > 0 ? MoneyUtils.format(spent) : ''} / ${MoneyUtils.format(limit.plannedAmountMinor)}',
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurfaceVariant),
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
                  color: over
                      ? AppColors.expense
                      : cs.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            icon: Icon(Icons.close, size: 14,
                color: cs.onSurfaceVariant),
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
  const _LimitDialog({required this.categories, required this.isIncome});

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
          DropdownButtonFormField<int>(
            initialValue: _selectedCatId,
            decoration: const InputDecoration(
                labelText: 'Category',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            isExpanded: true,
            items: widget.categories
                .where((c) => widget.isIncome ? (c.kind == 'income' || c.kind == 'both') : (c.kind == 'expense' || c.kind == 'both'))
                .map((c) => DropdownMenuItem<int>(
                    value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCatId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_selectedCatId == null ||
                _amountController.text.isEmpty) { return; }
            final amt =
                (double.tryParse(_amountController.text) ?? 0) * 100;
            Navigator.pop(context, {
              'categoryId': _selectedCatId!,
              'amount': amt.round(),
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

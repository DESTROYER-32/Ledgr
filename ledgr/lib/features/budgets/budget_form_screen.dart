import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class BudgetFormScreen extends ConsumerStatefulWidget {
  final int? budgetId;
  const BudgetFormScreen({super.key, this.budgetId});

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isIncome = false;
  int _color = AppColors.categoryColors[0].toARGB32();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int _periodDays = 30;
  Set<int> _selectedCategoryIds = {};

  bool get _isEditing => widget.budgetId != null;

  static const _periodOptions = [7, 14, 30];

  @override
  void initState() {
    super.initState();
    if (_isEditing) _load();
    _updateEndDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateEndDate() {
    _endDate = _startDate.add(Duration(days: _periodDays));
  }

  Future<void> _load() async {
    final repo = ref.read(budgetRepositoryProvider);
    final budget = await repo.getById(widget.budgetId!);
    if (budget != null && mounted) {
      final days = budget.periodEnd.difference(budget.periodStart).inDays;
      setState(() {
        _nameController.text = budget.name;
        _isIncome = budget.isIncome;
        _color = budget.color ?? AppColors.categoryColors[0].toARGB32();
        _startDate = budget.periodStart;
        _endDate = budget.periodEnd;
        _periodDays = days > 0 ? days : 30;
      });
      final limits = await repo.watchLimits(budget.id).first;
      setState(() {
        _selectedCategoryIds = limits.map((l) => l.categoryId).toSet();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(budgetRepositoryProvider);

    final companion = BudgetsCompanion(
      name: Value(_nameController.text.trim()),
      isIncome: Value(_isIncome),
      color: Value(_color),
      periodStart: Value(_startDate),
      periodEnd: Value(_endDate),
      currencyCode: const Value('USD'),
    );

    if (_isEditing) {
      await repo.update(widget.budgetId!, companion);
      if (mounted) context.pop();
    } else {
      await repo.insert(
        BudgetsCompanion.insert(
          name: _nameController.text.trim(),
          periodStart: _startDate,
          periodEnd: _endDate,
          currencyCode: 'USD',
          isIncome: Value(_isIncome),
          color: Value(_color),
        ),
      );
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final catsAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Budget' : 'New Budget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Budget name',
                hintText: 'e.g. Monthly Spending',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
              autofocus: true,
            ),
            const SizedBox(height: 24),
            Text('Budget Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: false,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward)),
                ButtonSegment(
                    value: true,
                    label: Text('Savings'),
                    icon: Icon(Icons.savings)),
              ],
              selected: {_isIncome},
              onSelectionChanged: (v) =>
                  setState(() => _isIncome = v.first),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: _isIncome ? 'Savings goal' : 'Budget amount',
                hintText: '0.00',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            Text('Period', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 days')),
                ButtonSegment(value: 14, label: Text('14 days')),
                ButtonSegment(value: 30, label: Text('30 days')),
              ],
              selected: _periodOptions.contains(_periodDays)
                  ? {_periodDays}
                  : <int>{},
              onSelectionChanged: (v) {
                setState(() {
                  _periodDays = v.first;
                  _updateEndDate();
                });
              },
              emptySelectionAllowed: false,
              showSelectedIcon: false,
            ),
            if (!_periodOptions.contains(_periodDays)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                            _updateEndDate();
                          });
                        }
                      },
                      child: Text(
                        'Start: ${MoneyUtils.formatDateShort(_startDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                            _periodDays =
                                _endDate.difference(_startDate).inDays;
                          });
                        }
                      },
                      child: Text(
                        'End: ${MoneyUtils.formatDateShort(_endDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Text('Color', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.categoryColors.map((c) {
                final selected = _color == c.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _color = c.toARGB32()),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(10),
                      border: selected
                          ? Border.all(
                              color: cs.onSurface, width: 2.5)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Categories (optional)',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              'Select categories to track in this budget. Leave empty to track all.',
              style: TextStyle(
                  fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            catsAsync.when(
              data: (cats) {
                if (cats.isEmpty) {
                  return Text('No categories available.',
                      style: TextStyle(
                          color: cs.onSurfaceVariant));
                }
                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: cats.map((c) {
                    final selected =
                        _selectedCategoryIds.contains(c.id);
                    return FilterChip(
                      label: Text(c.name, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedCategoryIds.add(c.id);
                          } else {
                            _selectedCategoryIds.remove(c.id);
                          }
                        });
                      },
                      visualDensity: VisualDensity.compact,
                      avatar: c.color != null
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(c.color!),
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    );
                  }).toList(),
                );
              },
              error: (e, _) => Text('$e'),
              loading: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}

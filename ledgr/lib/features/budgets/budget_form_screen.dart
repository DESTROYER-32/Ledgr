import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/modern_selection_field.dart';

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
  bool _specificMode = false;
  int _color = AppColors.categoryColors[0].toARGB32();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int _periodDays = 30;
  Set<int> _selectedCategoryIds = {};
  String _currencyCode = '';

  bool get _isEditing => widget.budgetId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _load();
    _updateEndDate();
    if (!_isEditing) {
      _currencyCode =
          ref.read(displayCurrencyProvider).valueOrNull ??
          MoneyUtils.defaultCurrencyCode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _currencyName(String code) {
    for (final currency in CurrencyUtils.currencies) {
      if (currency.code == code) return currency.name;
    }
    return null;
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
        _specificMode = budget.specificMode;
        _color = budget.color ?? AppColors.categoryColors[0].toARGB32();
        _startDate = budget.periodStart;
        _endDate = budget.periodEnd;
        _periodDays = days > 0 ? days : 30;
        _amountController.text = (budget.plannedAmountMinor / 100)
            .toStringAsFixed(2);
      });
      _currencyCode = budget.currencyCode;
      final limits = await repo.watchLimits(budget.id).first;
      setState(() {
        _selectedCategoryIds = limits.map((l) => l.categoryId).toSet();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(budgetRepositoryProvider);
    final currencyCode = _currencyCode;
    final plannedAmountMinor =
        ((double.tryParse(_amountController.text) ?? 0) * 100).round();

    final companion = BudgetsCompanion(
      name: Value(_nameController.text.trim()),
      isIncome: Value(_isIncome),
      specificMode: Value(_specificMode),
      color: Value(_color),
      periodStart: Value(_startDate),
      periodEnd: Value(_endDate),
      currencyCode: Value(currencyCode),
      plannedAmountMinor: Value(plannedAmountMinor),
    );

    int budgetId;
    if (_isEditing) {
      budgetId = widget.budgetId!;
      await repo.update(budgetId, companion);
    } else {
      budgetId = await repo.insert(
        BudgetsCompanion.insert(
          name: _nameController.text.trim(),
          periodStart: _startDate,
          periodEnd: _endDate,
          currencyCode: currencyCode,
          isIncome: Value(_isIncome),
          specificMode: Value(_specificMode),
          color: Value(_color),
          plannedAmountMinor: Value(plannedAmountMinor),
        ),
      );
    }

    final existing = await repo.watchLimits(budgetId).first;
    final existingCats = existing.map((l) => l.categoryId).toSet();
    for (final catId in _selectedCategoryIds) {
      if (!existingCats.contains(catId)) {
        await repo.setLimit(budgetId, catId, amount: 0);
      }
    }
    for (final l in existing) {
      if (!_selectedCategoryIds.contains(l.categoryId)) {
        await repo.removeLimit(budgetId, l.categoryId);
      }
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final catsAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Budget' : 'New Budget')),
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
                  label: Text('Budget'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Goal'),
                  icon: Icon(Icons.savings),
                ),
              ],
              selected: {_isIncome},
              onSelectionChanged: (v) => setState(() => _isIncome = v.first),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: _isIncome ? 'Savings goal' : 'Budget amount',
                hintText: '0.00',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            ModernSelectionField<String>(
              label: 'Currency',
              value: _currencyCode,
              leadingIcon: Icons.monetization_on_outlined,
              items:
                  currencyOptionsWithSelection(
                        ref.watch(favoriteCurrenciesProvider).valueOrNull ??
                            CurrencyUtils.codes,
                        _currencyCode,
                      )
                      .map(
                        (c) => ModernSelectionItem(
                          value: c,
                          title: c,
                          subtitle: _currencyName(c),
                          icon: Icons.monetization_on_outlined,
                          badge: CurrencyUtils.symbolFor(c),
                        ),
                      )
                      .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _currencyCode = v);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Track Mode'),
              subtitle: Text(
                _specificMode
                    ? 'Only transactions you assign to this budget'
                    : 'All transactions in date range',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              value: _specificMode,
              onChanged: (v) => setState(() => _specificMode = v),
            ),
            const SizedBox(height: 24),
            Text('Period', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '7', label: Text('7 days')),
                ButtonSegment(value: '14', label: Text('14 days')),
                ButtonSegment(value: '30', label: Text('30 days')),
                ButtonSegment(value: 'custom', label: Text('Custom')),
              ],
              selected: {
                _periodDays == 7
                    ? '7'
                    : _periodDays == 14
                    ? '14'
                    : _periodDays == 30
                    ? '30'
                    : 'custom',
              },
              onSelectionChanged: (v) {
                final val = v.first;
                if (val == 'custom') {
                  setState(() => _periodDays = 0);
                } else {
                  setState(() {
                    _periodDays = int.parse(val);
                    _updateEndDate();
                  });
                }
              },
              showSelectedIcon: false,
            ),
            const SizedBox(height: 12),
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
                          if (_periodDays > 0) _updateEndDate();
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
                          _periodDays = _endDate.difference(_startDate).inDays;
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
                          ? Border.all(color: cs.onSurface, width: 2.5)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              _specificMode ? 'Categories' : 'Categories (optional)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _specificMode
                  ? 'Select categories. Only transactions matching these will be available.'
                  : 'Select categories to track in this budget. Leave empty to track all.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            catsAsync.when(
              data: (cats) {
                if (cats.isEmpty) {
                  return Text(
                    'No categories available.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cats.map((c) {
                    final selected = _selectedCategoryIds.contains(c.id);
                    return FilterChip(
                      label: Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: selected,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedCategoryIds.add(c.id);
                          } else {
                            _selectedCategoryIds.remove(c.id);
                          }
                        });
                      },
                      avatar: c.color != null
                          ? Container(
                              width: 10,
                              height: 10,
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

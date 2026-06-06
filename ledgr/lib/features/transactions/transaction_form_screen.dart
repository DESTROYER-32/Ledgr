import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/widgets/amount_field.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final int? transactionId;
  final int? preselectedWalletId;
  final String? preselectedType;
  const TransactionFormScreen({
    super.key,
    this.transactionId,
    this.preselectedWalletId,
    this.preselectedType,
  });

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  String _type = 'expense';
  String _specialType = 'none';
  int? _walletId;
  int? _transferWalletId;
  int? _categoryId;
  int? _objectiveId;
  Set<int> _budgetIds = {};
  String? _currencyCode;
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _walletId = widget.preselectedWalletId;
    if (widget.preselectedType != null) {
      _type = widget.preselectedType!;
    }
    _isEditing = widget.transactionId != null;
    if (_isEditing) {
      _loadTransaction();
    } else if (_walletId == null) {
      _loadDefaultWallet();
    }
  }

  Future<void> _loadDefaultWallet() async {
    final defaultWalletId = await ref.read(defaultWalletIdProvider.future);
    if (defaultWalletId != null && mounted && _walletId == null) {
      final wallet = await ref
          .read(walletRepositoryProvider)
          .getById(defaultWalletId);
      if (wallet != null && !wallet.archived && mounted) {
        setState(() => _walletId = defaultWalletId);
      }
    }
  }

  Future<void> _loadTransaction() async {
    final repo = ref.read(transactionRepositoryProvider);
    final t = await repo.getById(widget.transactionId!);
    if (t != null && mounted) {
      setState(() {
        _type = t.type;
        _specialType = t.specialType;
        _walletId = t.walletId;
        _transferWalletId = t.transferWalletId;
        _categoryId = t.categoryId;
        _objectiveId = t.objectiveFk;
        _currencyCode = t.currencyCode;
        if (t.budgetFks != null && t.budgetFks!.isNotEmpty) {
          _budgetIds = t.budgetFks!
              .split(',')
              .map((s) => int.tryParse(s.trim()))
              .where((n) => n != null)
              .cast<int>()
              .toSet();
        }
        _date = t.date;
        _titleController.text = t.title ?? '';
        _noteController.text = t.note ?? '';
        _tagsController.text = t.tags ?? '';
        _amountController.text = (t.amountMinor / 100).toStringAsFixed(2);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _duplicate() {
    setState(() => _isEditing = false);
  }

  Future<void> _autoCategorize(String title) async {
    if (title.isEmpty) return;
    final repo = ref.read(associatedTitleRepositoryProvider);
    final catId = await repo.findCategoryIdForTitle(title);
    if (catId != null && mounted) {
      setState(() => _categoryId = catId);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_walletId == null) return;
    setState(() => _isLoading = true);

    final repo = ref.read(transactionRepositoryProvider);
    final amount = (double.tryParse(_amountController.text) ?? 0) * 100;
    final wallet = await ref.read(walletRepositoryProvider).getById(_walletId!);
    final walletCurrency =
        wallet?.currencyCode ?? MoneyUtils.defaultCurrencyCode;
    final currencyCode = _currencyCode ?? walletCurrency;

    final companion = TransactionsCompanion(
      type: Value(_type),
      specialType: Value(_specialType),
      amountMinor: Value(amount.round()),
      currencyCode: Value(currencyCode),
      date: Value(_date),
      walletId: Value(_walletId!),
      transferWalletId: Value(_transferWalletId),
      categoryId: Value(_categoryId),
      title: Value(
        _titleController.text.isEmpty ? null : _titleController.text,
      ),
      note: Value(_noteController.text.isEmpty ? null : _noteController.text),
      tags: Value(_tagsController.text.isEmpty ? null : _tagsController.text),
      budgetFks: _budgetIds.isNotEmpty
          ? Value(_budgetIds.join(','))
          : const Value(null),
      objectiveFk: _objectiveId != null
          ? Value(_objectiveId!)
          : const Value(null),
    );

    if (_isEditing) {
      await repo.update(widget.transactionId!, companion);
    } else {
      await repo.insert(
        TransactionsCompanion.insert(
          type: _type,
          specialType: Value(_specialType),
          amountMinor: amount.round(),
          currencyCode: currencyCode,
          date: _date,
          walletId: _walletId!,
          transferWalletId: Value(_transferWalletId),
          categoryId: Value(_categoryId),
          title: Value(
            _titleController.text.isEmpty ? null : _titleController.text,
          ),
          note: Value(
            _noteController.text.isEmpty ? null : _noteController.text,
          ),
          tags: Value(
            _tagsController.text.isEmpty ? null : _tagsController.text,
          ),
          budgetFks: _budgetIds.isNotEmpty
              ? Value(_budgetIds.join(','))
              : const Value(null),
          objectiveFk: _objectiveId != null
              ? Value(_objectiveId!)
              : const Value(null),
        ),
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(activeWalletsProvider);
    final catsAsync = ref.watch(expenseCategoriesProvider);
    final objectivesAsync = ref.watch(allObjectivesProvider);
    final theme = Theme.of(context);
    final wallets = walletsAsync.valueOrNull ?? [];
    final selectedWallet = wallets.where((w) => w.id == _walletId).firstOrNull;
    final walletCurrency =
        selectedWallet?.currencyCode ?? MoneyUtils.defaultCurrencyCode;
    final displayCurrency = _currencyCode ?? walletCurrency;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'New Transaction'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Duplicate',
              onPressed: () => _duplicate(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: 'transfer',
                  label: Text('Transfer'),
                  icon: Icon(Icons.swap_horiz),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() {
                _type = v.first;
                if (_type == 'transfer') _categoryId = null;
              }),
            ),
            const SizedBox(height: 12),
            Text('Type', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _specialChip('none', 'Standard'),
                  _specialChip('upcoming', 'Upcoming'),
                  _specialChip('subscription', 'Subscription'),
                  _specialChip('repetitive', 'Repetitive'),
                  if (_type == 'expense') _specialChip('debt', 'Debt'),
                  if (_type == 'income') _specialChip('credit', 'Credit'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AmountField(
              controller: _amountController,
              currencySymbol: displayCurrency,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title / Payee',
                hintText: 'Optional',
              ),
              onChanged: _autoCategorize,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Optional',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Comma-separated (e.g. food, work)',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(AppDateUtils.formatDate(_date)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            walletsAsync.when(
              data: (wallets) => DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _walletId,
                decoration: const InputDecoration(labelText: 'Account'),
                items: wallets
                    .map(
                      (w) => DropdownMenuItem(value: w.id, child: Text(w.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _walletId = v;
                    _currencyCode = null;
                  });
                },
                validator: (v) => v == null ? 'Required' : null,
              ),
              error: (e, _) => Text('$e'),
              loading: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: displayCurrency,
              decoration: const InputDecoration(labelText: 'Currency'),
              items: CurrencyUtils.codes
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text('$c  ${CurrencyUtils.symbolFor(c)}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) async {
                if (v != null) {
                  final oldCurrency = displayCurrency;
                  final amountText = _amountController.text;
                  final amount = double.tryParse(amountText) ?? 0;
                  if (amount > 0 && oldCurrency != v) {
                    final service = ref.read(exchangeRateServiceProvider);
                    final converted = await service.convert(
                      (amount * 100).round(),
                      oldCurrency,
                      v,
                    );
                    _amountController.text = (converted / 100).toStringAsFixed(
                      2,
                    );
                  }
                  setState(() => _currencyCode = v);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_type == 'expense' || _type == 'income')
              catsAsync.when(
                data: (cats) => DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...cats.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                error: (e, _) => Text('$e'),
                loading: () => const LinearProgressIndicator(),
              ),
            if (_type == 'transfer')
              walletsAsync.when(
                data: (wallets) => DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _transferWalletId,
                  decoration: const InputDecoration(labelText: 'Transfer to'),
                  items: wallets
                      .where((w) => w.id != _walletId)
                      .map(
                        (w) =>
                            DropdownMenuItem(value: w.id, child: Text(w.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _transferWalletId = v),
                ),
                error: (e, _) => Text('$e'),
                loading: () => const LinearProgressIndicator(),
              ),
            const SizedBox(height: 16),
            objectivesAsync.when(
              data: (objectives) => DropdownButtonFormField<int?>(
                isExpanded: true,
                initialValue: _objectiveId,
                decoration: const InputDecoration(
                  labelText: 'Link to Goal/Loan (optional)',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...objectives.map(
                    (o) => DropdownMenuItem(
                      value: o.id,
                      child: Text(
                        '${o.name} (${o.type == 'loan' ? 'Loan' : 'Goal'})',
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _objectiveId = v),
              ),
              error: (e, _) => Text('$e'),
              loading: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 16),
            ref
                .watch(allBudgetsProvider)
                .when(
                  data: (allBudgets) {
                    final active = allBudgets
                        .where(
                          (b) =>
                              b.specificMode &&
                              b.periodEnd.isAfter(DateTime.now()),
                        )
                        .toList();
                    if (active.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign to Budgets',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select budgets in tracking mode',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: active.map((b) {
                            final selected = _budgetIds.contains(b.id);
                            return FilterChip(
                              label: Text(
                                b.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _budgetIds.add(b.id);
                                  } else {
                                    _budgetIds.remove(b.id);
                                  }
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                  error: (_, _) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child: Text(_isEditing ? 'Update' : 'Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specialChip(String value, String label) {
    final selected = _specialType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => setState(() => _specialType = value),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/widgets/amount_field.dart';
import '../../core/widgets/modern_selection_field.dart';

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
  String? _recurrenceRule;
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
        _specialType = t.specialType == 'repetitive'
            ? 'scheduled'
            : t.specialType;
        _recurrenceRule = t.recurrenceRule;
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
    final objectives = await ref.read(allObjectivesProvider.future);
    final normalizedTitle = title.toLowerCase();
    final objectiveId = objectives
        .where((o) => normalizedTitle.contains(o.name.toLowerCase()))
        .map((o) => o.id)
        .firstOrNull;
    if ((catId != null || objectiveId != null) && mounted) {
      setState(() {
        if (catId != null) _categoryId = catId;
        if (_objectiveId == null && objectiveId != null) {
          _objectiveId = objectiveId;
        }
      });
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
      recurrenceRule: Value(_isRecurringSpecial ? _recurrenceRule : null),
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
          recurrenceRule: Value(_isRecurringSpecial ? _recurrenceRule : null),
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
    final walletBalances = ref.watch(walletBalancesProvider).valueOrNull ?? {};
    final catsAsync = ref.watch(expenseCategoriesProvider);
    final objectivesAsync = ref.watch(allObjectivesProvider);
    final theme = Theme.of(context);
    final wallets = walletsAsync.valueOrNull ?? [];
    final selectedWallet = wallets.where((w) => w.id == _walletId).firstOrNull;
    final defaultCurrency =
        ref.watch(displayCurrencyProvider).valueOrNull ??
        MoneyUtils.defaultCurrencyCode;
    final walletCurrency = selectedWallet?.currencyCode ?? defaultCurrency;
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
                  _specialChip('scheduled', 'Scheduled'),
                  if (_type == 'expense') _specialChip('debt', 'Debt'),
                  if (_type == 'income') _specialChip('credit', 'Credit'),
                ],
              ),
            ),
            if (_isRecurringSpecial) ...[
              const SizedBox(height: 12),
              ModernSelectionField<String>(
                label: 'Repeat frequency',
                value: _recurrenceRule,
                placeholder: 'Select frequency',
                leadingIcon: Icons.repeat,
                items: const [
                  ModernSelectionItem(
                    value: 'monthly',
                    title: 'Monthly',
                    icon: Icons.calendar_view_month_outlined,
                  ),
                  ModernSelectionItem(
                    value: 'quarterly',
                    title: 'Quarterly',
                    icon: Icons.calendar_view_week_outlined,
                  ),
                  ModernSelectionItem(
                    value: 'yearly',
                    title: 'Yearly',
                    icon: Icons.event_repeat_outlined,
                  ),
                ],
                onChanged: (v) => setState(() => _recurrenceRule = v),
                validator: (_) => _isRecurringSpecial && _recurrenceRule == null
                    ? 'Required for subscriptions and scheduled transactions'
                    : null,
              ),
            ],
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
              data: (wallets) => ModernSelectionField<int>(
                label: 'Account',
                value: _walletId,
                leadingIcon: Icons.account_balance_wallet_outlined,
                items: wallets
                    .map(
                      (w) => ModernSelectionItem(
                        value: w.id,
                        title: w.name,
                        subtitle:
                            '${_walletTypeLabel(w.type)} • ${MoneyUtils.format(walletBalances[w.id] ?? w.initialBalanceMinor, currencyCode: w.currencyCode)}',
                        icon: _walletIcon(w.type),
                        badge: w.currencyCode,
                      ),
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
            ModernSelectionField<String>(
              label: 'Currency',
              value: displayCurrency,
              leadingIcon: Icons.payments_outlined,
              items:
                  currencyOptionsWithSelection(
                        ref.watch(favoriteCurrenciesProvider).valueOrNull ??
                            CurrencyUtils.codes,
                        displayCurrency,
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
                data: (cats) => ModernSelectionField<int>(
                  label: 'Category',
                  value: _categoryId,
                  placeholder: 'None',
                  allowClear: true,
                  leadingIcon: Icons.category_outlined,
                  items: cats
                      .map(
                        (c) => ModernSelectionItem(
                          value: c.id,
                          title: c.name,
                          icon: Icons.category_outlined,
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                error: (e, _) => Text('$e'),
                loading: () => const LinearProgressIndicator(),
              ),
            if (_type == 'transfer')
              walletsAsync.when(
                data: (wallets) => ModernSelectionField<int>(
                  label: 'Transfer to',
                  value: _transferWalletId,
                  leadingIcon: Icons.swap_horiz_rounded,
                  items: wallets
                      .where((w) => w.id != _walletId)
                      .map(
                        (w) => ModernSelectionItem(
                          value: w.id,
                          title: w.name,
                          subtitle:
                              '${_walletTypeLabel(w.type)} • ${MoneyUtils.format(walletBalances[w.id] ?? w.initialBalanceMinor, currencyCode: w.currencyCode)}',
                          icon: _walletIcon(w.type),
                          badge: w.currencyCode,
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _transferWalletId = v),
                ),
                error: (e, _) => Text('$e'),
                loading: () => const LinearProgressIndicator(),
              ),
            const SizedBox(height: 16),
            objectivesAsync.when(
              data: (objectives) => ModernSelectionField<int>(
                label: 'Link to Goal/Loan',
                value: _objectiveId,
                placeholder: 'None',
                allowClear: true,
                leadingIcon: Icons.flag_outlined,
                items: objectives
                    .map(
                      (o) => ModernSelectionItem(
                        value: o.id,
                        title: o.name,
                        subtitle: o.type == 'loan' ? 'Loan' : 'Goal',
                        icon: o.type == 'loan'
                            ? Icons.account_balance_outlined
                            : Icons.flag_outlined,
                        badge: o.currencyCode,
                      ),
                    )
                    .toList(),
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

  IconData _walletIcon(String type) => switch (type) {
    'savings' => Icons.savings_outlined,
    'cash' => Icons.payments_outlined,
    'credit_card' => Icons.credit_card_outlined,
    'loan' => Icons.account_balance_wallet_outlined,
    _ => Icons.account_balance_outlined,
  };

  String _walletTypeLabel(String type) => switch (type) {
    'credit_card' => 'Credit card',
    'loan' => 'Loan account',
    _ => '${type[0].toUpperCase()}${type.substring(1)} account',
  };

  String? _currencyName(String code) {
    for (final currency in CurrencyUtils.currencies) {
      if (currency.code == code) return currency.name;
    }
    return null;
  }

  bool get _isRecurringSpecial =>
      _specialType == 'subscription' || _specialType == 'scheduled';

  Widget _specialChip(String value, String label) {
    final selected = _specialType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => setState(() {
          _specialType = value;
          if (!_isRecurringSpecial) _recurrenceRule = null;
          if (_specialType == 'subscription') _type = 'expense';
        }),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

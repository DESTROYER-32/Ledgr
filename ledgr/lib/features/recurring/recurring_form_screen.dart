import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/utils/recurring_utils.dart';
import '../../core/widgets/modern_selection_field.dart';

class RecurringFormScreen extends ConsumerStatefulWidget {
  final int? recurringId;
  const RecurringFormScreen({super.key, this.recurringId});

  @override
  ConsumerState<RecurringFormScreen> createState() =>
      _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _repeatMonthsController = TextEditingController(text: '1');
  String _type = 'expense';
  String _schedule = 'monthly';
  int? _walletId;
  int? _categoryId;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isEditing = false;

  String _selectedCurrency(List<Wallet> wallets, String fallbackCurrency) {
    for (final wallet in wallets) {
      if (wallet.id == _walletId) return wallet.currencyCode;
    }
    return fallbackCurrency;
  }

  final _schedules = [
    ('daily', 'Daily'),
    ('weekly', 'Weekly'),
    ('monthly', 'Monthly'),
    ('quarterly', 'Every 3 months'),
    ('yearly', 'Every 12 months'),
    ('custom_months', 'Custom'),
  ];

  String get _effectiveSchedule => _schedule == 'custom_months'
      ? RecurringUtils.buildEveryMonthsRule(
          int.tryParse(_repeatMonthsController.text) ?? 1,
          until: _endDate,
        )
      : _schedule;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.recurringId != null) {
      _isEditing = true;
      _load();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  DateTime? _existingNextDueDate;

  Future<void> _load() async {
    final r = await ref
        .read(recurringRepositoryProvider)
        .getById(widget.recurringId!);
    if (r != null && mounted) {
      setState(() {
        _type = r.transactionType;
        _schedule = r.scheduleRule;
        _endDate = r.endDate;
        _existingNextDueDate = r.nextDueDate;
        final months = RecurringUtils.monthIntervalForRule(r.scheduleRule);
        if (months != null &&
            r.scheduleRule != 'monthly' &&
            r.scheduleRule != 'quarterly' &&
            r.scheduleRule != 'yearly') {
          _schedule = 'custom_months';
          _repeatMonthsController.text = '$months';
          _endDate =
              RecurringUtils.untilDateForRule(r.scheduleRule) ?? r.endDate;
        }
        _walletId = r.walletId;
        _categoryId = r.categoryId;
        _startDate = r.startDate;
        _titleController.text = r.title ?? '';
        _noteController.text = r.note ?? '';
        _amountController.text = MoneyUtils.toMajorText(
          r.amountMinor,
          currencyCode: r.currencyCode,
        );
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _repeatMonthsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_walletId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }
    setState(() => _isLoading = true);

    final repo = ref.read(recurringRepositoryProvider);
    final wallet = await ref.read(walletRepositoryProvider).getById(_walletId!);
    final amount = MoneyUtils.toMinor(
      double.tryParse(_amountController.text) ?? 0,
      currencyCode: wallet?.currencyCode ?? MoneyUtils.defaultCurrencyCode,
    );

    final companion = RecurringTransactionsCompanion(
      transactionType: Value(_type),
      amountMinor: Value(amount),
      currencyCode: Value(
        wallet?.currencyCode ?? MoneyUtils.defaultCurrencyCode,
      ),
      walletId: Value(_walletId!),
      transferWalletId: const Value(null),
      categoryId: Value(_categoryId),
      title: Value(
        _titleController.text.isEmpty ? null : _titleController.text,
      ),
      note: Value(_noteController.text.isEmpty ? null : _noteController.text),
      scheduleRule: Value(_effectiveSchedule),
      startDate: Value(_startDate),
      endDate: Value(_endDate),
      nextDueDate: Value(
        (_isEditing && _existingNextDueDate != null)
            ? _existingNextDueDate!
            : _startDate,
      ),
    );

    if (_isEditing) {
      await repo.update(widget.recurringId!, companion);
    } else {
      await repo.insert(companion);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(activeWalletsProvider);
    final catsAsync = ref.watch(expenseCategoriesProvider);
    final theme = Theme.of(context);
    final wallets = walletsAsync.valueOrNull ?? const <Wallet>[];
    final displayCurrency =
        ref.watch(displayCurrencyProvider).valueOrNull ??
        MoneyUtils.defaultCurrencyCode;
    final selectedCurrency = _selectedCurrency(wallets, displayCurrency);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recurring' : 'New Recurring'),
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
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '$selectedCurrency ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title / Payee',
                hintText: 'e.g. Netflix, Rent, Salary',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Text('Schedule', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _schedules.map((s) {
                final sel = _schedule == s.$1;
                return ChoiceChip(
                  label: Text(s.$2),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    _schedule = s.$1;
                    if (s.$1 == 'monthly') _repeatMonthsController.text = '1';
                    if (s.$1 == 'quarterly') _repeatMonthsController.text = '3';
                    if (s.$1 == 'yearly') _repeatMonthsController.text = '12';
                  }),
                );
              }).toList(),
            ),
            if (_schedule == 'custom_months') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _repeatMonthsController,
                decoration: const InputDecoration(
                  labelText: 'Repeat every _ months',
                  prefixText: 'Every ',
                  suffixText: ' months',
                ),
                keyboardType: TextInputType.number,
                validator: (_) {
                  if (_schedule != 'custom_months') return null;
                  final value = int.tryParse(_repeatMonthsController.text);
                  return value == null || value < 1
                      ? 'Enter at least 1 month'
                      : null;
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_busy_outlined),
                title: Text(
                  _endDate == null
                      ? 'Repeat until: no end date'
                      : 'Repeat until: ${AppDateUtils.formatDate(_endDate!)}',
                ),
                trailing: _endDate == null
                    ? null
                    : IconButton(
                        tooltip: 'Clear until date',
                        onPressed: () => setState(() => _endDate = null),
                        icon: const Icon(Icons.close),
                      ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        _endDate ??
                        DateTime(
                          _startDate.year + 1,
                          _startDate.month,
                          _startDate.day,
                        ),
                    firstDate: _startDate,
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
              ),
            ],
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
                        subtitle: w.type.replaceAll('_', ' '),
                        icon: Icons.account_balance_outlined,
                        badge: w.currencyCode,
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _walletId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              error: (e, _) => Text('$e'),
              loading: () => const LinearProgressIndicator(),
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
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text('Start: ${AppDateUtils.formatDate(_startDate)}'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _startDate = picked);
                }
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}

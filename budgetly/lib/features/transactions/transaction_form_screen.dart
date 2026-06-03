import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final int? transactionId;
  final int? preselectedWalletId;
  const TransactionFormScreen(
      {super.key, this.transactionId, this.preselectedWalletId});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  int? _walletId;
  int? _transferWalletId;
  int? _categoryId;
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _walletId = widget.preselectedWalletId;
    _isEditing = widget.transactionId != null;
    if (_isEditing) _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final repo = ref.read(transactionRepositoryProvider);
    final t = await repo.getById(widget.transactionId!);
    if (t != null && mounted) {
      _type = t.type;
      _walletId = t.walletId;
      _transferWalletId = t.transferWalletId;
      _categoryId = t.categoryId;
      _date = t.date;
      _titleController.text = t.title ?? '';
      _noteController.text = t.note ?? '';
      _amountController.text = (t.amountMinor / 100).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_walletId == null) return;
    setState(() => _isLoading = true);

    final repo = ref.read(transactionRepositoryProvider);
    final amount = (double.tryParse(_amountController.text) ?? 0) * 100;

    if (_isEditing) {
      await repo.update(
        widget.transactionId!,
        TransactionsCompanion(
          type: Value(_type),
          amountMinor: Value(amount.round()),
          currencyCode: const Value('USD'),
          date: Value(_date),
          walletId: Value(_walletId!),
          transferWalletId: Value(_transferWalletId),
          categoryId: Value(_categoryId),
          title: Value(_titleController.text.isEmpty
              ? null
              : _titleController.text),
          note: Value(
              _noteController.text.isEmpty ? null : _noteController.text),
        ),
      );
    } else {
      await repo.insert(TransactionsCompanion.insert(
        type: _type,
        amountMinor: amount.round(),
        currencyCode: 'USD',
        date: _date,
        walletId: _walletId!,
        transferWalletId: Value(_transferWalletId),
        categoryId: Value(_categoryId),
        title: Value(_titleController.text.isEmpty ? null : _titleController.text),
        note: Value(_noteController.text.isEmpty ? null : _noteController.text),
      ));
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(activeWalletsProvider);
    final catsAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditing ? 'Edit Transaction' : 'New Transaction')),
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
                    icon: Icon(Icons.arrow_upward)),
                ButtonSegment(
                    value: 'income',
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward)),
                ButtonSegment(
                    value: 'transfer',
                    label: Text('Transfer'),
                    icon: Icon(Icons.swap_horiz)),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title / Payee',
                hintText: 'Optional',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                  labelText: 'Note', hintText: 'Optional'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(MoneyUtils.formatDate(_date)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 16),
            walletsAsync.when(
              data: (wallets) => DropdownButtonFormField<int>(
                initialValue: _walletId,
                decoration: const InputDecoration(labelText: 'Account'),
                items: wallets
                    .map((w) =>
                        DropdownMenuItem(value: w.id, child: Text(w.name)))
                    .toList(),
                onChanged: (v) => setState(() => _walletId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              error: (e, _) => Text('$e'),
              loading: () => const LinearProgressIndicator(),
            ),
            if (_type == 'expense' || _type == 'income')
              catsAsync.when(
                data: (cats) => DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration:
                      const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...cats.map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                error: (e, _) => Text('$e'),
                loading: () => const LinearProgressIndicator(),
              ),
            if (_type == 'transfer')
              walletsAsync.when(
                data: (wallets) => DropdownButtonFormField<int>(
                  initialValue: _transferWalletId,
                  decoration:
                      const InputDecoration(labelText: 'Transfer to'),
                  items: wallets
                      .where((w) => w.id != _walletId)
                      .map((w) => DropdownMenuItem(
                          value: w.id, child: Text(w.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _transferWalletId = v),
                ),
                error: (e, _) => Text('$e'),
                loading: () => const LinearProgressIndicator(),
              ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child:
                  Text(_isEditing ? 'Update' : 'Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}

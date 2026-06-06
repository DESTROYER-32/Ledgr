import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/currency_utils.dart';

class WalletFormScreen extends ConsumerStatefulWidget {
  final int? walletId;
  const WalletFormScreen({super.key, this.walletId});

  @override
  ConsumerState<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends ConsumerState<WalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _type = 'checking';
  final _balanceController = TextEditingController();
  String _currencyCode = '';
  bool _isLoading = false;

  final _types = [
    ('checking', 'Checking', Icons.account_balance),
    ('savings', 'Savings', Icons.savings),
    ('cash', 'Cash', Icons.money),
    ('credit_card', 'Credit Card', Icons.credit_card),
    ('loan', 'Loan', Icons.account_balance_wallet),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.walletId != null) {
      _loadWallet();
    } else {
      _currencyCode = 'USD';
    }
  }

  Future<void> _loadWallet() async {
    final wallet = await ref
        .read(walletRepositoryProvider)
        .getById(widget.walletId!);
    if (wallet != null && mounted) {
      _nameController.text = wallet.name;
      _type = wallet.type;
      _currencyCode = wallet.currencyCode;
      _balanceController.text = (wallet.initialBalanceMinor / 100)
          .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final repo = ref.read(walletRepositoryProvider);
    final balance = (double.tryParse(_balanceController.text) ?? 0) * 100;

    if (widget.walletId != null) {
      await repo.update(
        widget.walletId!,
        WalletsCompanion(
          name: Value(_nameController.text),
          type: Value(_type),
          currencyCode: Value(_currencyCode),
          initialBalanceMinor: Value(balance.round()),
        ),
      );
    } else {
      await repo.insert(
        WalletsCompanion.insert(
          name: _nameController.text,
          type: _type,
          currencyCode: _currencyCode,
          initialBalanceMinor: balance.round(),
        ),
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.walletId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Account' : 'New Account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account name',
                hintText: 'e.g. Main Checking',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Text('Account type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _types.map((t) {
                final selected = _type == t.$1;
                return ChoiceChip(
                  label: Text(t.$2),
                  selected: selected,
                  avatar: Icon(t.$3, size: 18),
                  onSelected: (_) => setState(() => _type = t.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _currencyCode,
              decoration: const InputDecoration(labelText: 'Currency'),
              items: CurrencyUtils.codes
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text('$c  ${CurrencyUtils.symbolFor(c) ?? ''}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _currencyCode = v);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _balanceController,
              decoration: InputDecoration(
                labelText: 'Current balance',
                prefixText:
                    '${CurrencyUtils.symbolFor(_currencyCode) ?? _currencyCode} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child: Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}

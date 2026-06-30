import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/amount_field.dart';
import '../../core/widgets/modern_selection_field.dart';

class TransferFormScreen extends ConsumerStatefulWidget {
  final int? fromWalletId;
  const TransferFormScreen({super.key, this.fromWalletId});

  @override
  ConsumerState<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends ConsumerState<TransferFormScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? _fromWalletId;
  int? _toWalletId;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fromWalletId = widget.fromWalletId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save(List<Wallet> wallets) async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_fromWalletId == null || _toWalletId == null) {
      _snack('Choose both accounts.');
      return;
    }
    if (_fromWalletId == _toWalletId) {
      _snack('Choose two different accounts.');
      return;
    }
    final from = wallets.where((w) => w.id == _fromWalletId).firstOrNull;
    if (from == null) {
      _snack('Choose a valid source account.');
      return;
    }
    final amountValue = double.tryParse(_amountController.text.trim());
    if (amountValue == null || amountValue <= 0) {
      _snack('Enter an amount greater than zero.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(transactionRepositoryProvider)
          .insert(
            TransactionsCompanion.insert(
              type: 'transfer',
              specialType: const Value('none'),
              amountMinor: MoneyUtils.toMinor(
                amountValue,
                currencyCode: from.currencyCode,
              ),
              currencyCode: from.currencyCode,
              date: _date,
              walletId: _fromWalletId!,
              transferWalletId: Value(_toWalletId),
              categoryId: const Value(null),
              title: const Value('Transfer'),
              note: Value(
                _noteController.text.trim().isEmpty
                    ? null
                    : _noteController.text.trim(),
              ),
            ),
          );
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) _snack('Could not save transfer.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(activeWalletsProvider);
    final balances = ref.watch(walletBalancesProvider).valueOrNull ?? {};
    final wallets = walletsAsync.valueOrNull ?? [];
    final fromWallet = wallets.where((w) => w.id == _fromWalletId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Money')),
      body: walletsAsync.when(
        data: (wallets) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ModernSelectionField<int>(
                label: 'Transfer from',
                value: _fromWalletId,
                leadingIcon: Icons.call_made_rounded,
                items: wallets.map((w) => _walletItem(w, balances)).toList(),
                onChanged: (v) => setState(() {
                  _fromWalletId = v;
                  if (_toWalletId == v) _toWalletId = null;
                }),
              ),
              const SizedBox(height: 16),
              ModernSelectionField<int>(
                label: 'Transfer to',
                value: _toWalletId,
                leadingIcon: Icons.call_received_rounded,
                items: wallets
                    .where((w) => w.id != _fromWalletId)
                    .map((w) => _walletItem(w, balances))
                    .toList(),
                onChanged: (v) => setState(() => _toWalletId = v),
              ),
              const SizedBox(height: 20),
              AmountField(
                controller: _amountController,
                currencySymbol:
                    fromWallet?.currencyCode ?? MoneyUtils.defaultCurrencyCode,
                autofocus: true,
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Enter an amount greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Optional',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(AppDateUtils.formatDate(_date)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 36500)),
                  );
                  if (picked != null && mounted) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : () => _save(wallets),
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.swap_horiz_rounded),
                label: const Text('Transfer'),
              ),
            ],
          ),
        ),
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  ModernSelectionItem<int> _walletItem(Wallet w, Map<int, int> balances) {
    return ModernSelectionItem(
      value: w.id,
      title: w.name,
      subtitle:
          '${w.type.replaceAll('_', ' ')} • ${MoneyUtils.format(balances[w.id] ?? w.initialBalanceMinor, currencyCode: w.currencyCode)}',
      icon: Icons.account_balance_wallet_outlined,
      badge: w.currencyCode,
    );
  }
}

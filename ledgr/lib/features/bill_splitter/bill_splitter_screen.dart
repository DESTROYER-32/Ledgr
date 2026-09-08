import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';

class BillSplitterScreen extends ConsumerStatefulWidget {
  const BillSplitterScreen({super.key});

  @override
  ConsumerState<BillSplitterScreen> createState() => _BillSplitterScreenState();
}

class _BillSplitterScreenState extends ConsumerState<BillSplitterScreen> {
  final _items = <_SplitItem>[];
  final _people = <String>['You'];
  final _itemNameCtrl = TextEditingController();
  final _itemAmountCtrl = TextEditingController();
  final _personCtrl = TextEditingController();

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _itemAmountCtrl.dispose();
    _personCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallets = ref.watch(activeWalletsProvider).valueOrNull;
    final displayCurrency =
        ref.watch(displayCurrencyProvider).valueOrNull ??
        MoneyUtils.defaultCurrencyCode;
    final splitCurrency = wallets != null && wallets.isNotEmpty
        ? wallets.first.currencyCode
        : displayCurrency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Splitter'),
        actions: [
          if (_items.isNotEmpty && _people.length > 1)
            IconButton(
              icon: const Icon(Icons.done),
              tooltip: 'Create Transactions',
              onPressed: _createTransactions,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // People section
          Text('People', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _people.asMap().entries.map((e) {
              return Chip(
                label: Text(e.value),
                onDeleted: e.value != 'You'
                    ? () => setState(() => _people.removeAt(e.key))
                    : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _personCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Add person...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () {
                  if (_personCtrl.text.isNotEmpty) {
                    setState(() {
                      _people.add(_personCtrl.text);
                      _personCtrl.clear();
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Items section
          Text('Items', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._items.asMap().entries.map((e) {
            final item = e.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(
                  '${MoneyUtils.format(MoneyUtils.toMinor(item.amount, currencyCode: splitCurrency), currencyCode: splitCurrency)} per person',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _items.removeAt(e.key)),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _itemNameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Item name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _itemAmountCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () {
                  final name = _itemNameCtrl.text;
                  final amount = double.tryParse(_itemAmountCtrl.text) ?? 0;
                  if (name.isNotEmpty && amount > 0) {
                    setState(() {
                      _items.add(_SplitItem(name, amount));
                      _itemNameCtrl.clear();
                      _itemAmountCtrl.clear();
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${MoneyUtils.format(MoneyUtils.toMinor(_items.fold<double>(0, (s, i) => s + i.amount * _people.length), currencyCode: splitCurrency), currencyCode: splitCurrency)}',
                  ),
                  const SizedBox(height: 8),
                  ..._people.map((person) {
                    final perPerson = _items.fold<double>(
                      0,
                      (s, i) => s + i.amount,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(person),
                          Text(
                            MoneyUtils.format(
                              MoneyUtils.toMinor(
                                perPerson,
                                currencyCode: splitCurrency,
                              ),
                              currencyCode: splitCurrency,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createTransactions() async {
    final repo = ref.read(transactionRepositoryProvider);
    final wallets = await ref
        .read(walletRepositoryProvider)
        .watchActive()
        .first;
    if (wallets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No wallets available')));
      }
      return;
    }
    final wallet = wallets.first;
    final title = 'Bill split: ${_items.map((i) => i.name).join(', ')}';
    final perPerson = _items.fold<int>(
      0,
      (s, i) =>
          s + MoneyUtils.toMinor(i.amount, currencyCode: wallet.currencyCode),
    );

    await repo.insert(
      TransactionsCompanion.insert(
        type: 'expense',
        amountMinor: perPerson,
        currencyCode: wallet.currencyCode,
        date: DateTime.now(),
        walletId: wallet.id,
        title: Value('$title (My share)'),
        specialType: const Value('none'),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Created transaction for your share of the bill')),
      );
      context.pop();
    }
  }
}

class _SplitItem {
  final String name;
  final double amount;
  _SplitItem(this.name, this.amount);
}

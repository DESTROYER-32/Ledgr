import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/modern_selection_field.dart';

class HoldingFormScreen extends ConsumerStatefulWidget {
  const HoldingFormScreen({super.key, this.holdingId});

  final int? holdingId;

  @override
  ConsumerState<HoldingFormScreen> createState() => _HoldingFormScreenState();
}

class _HoldingFormScreenState extends ConsumerState<HoldingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tickerController = TextEditingController();
  final _nameController = TextEditingController();
  final _sharesController = TextEditingController();
  final _costController = TextEditingController();
  final _priceController = TextEditingController();
  String _assetType = 'stock';
  int? _walletId;
  String _currencyCode = MoneyUtils.defaultCurrencyCode;

  static const _assetTypeItems = [
    ModernSelectionItem(
      value: 'stock',
      title: 'Stock',
      icon: Icons.trending_up,
    ),
    ModernSelectionItem(value: 'etf', title: 'ETF', icon: Icons.pie_chart),
    ModernSelectionItem(
      value: 'crypto',
      title: 'Crypto',
      icon: Icons.currency_bitcoin,
    ),
    ModernSelectionItem(value: 'bond', title: 'Bond', icon: Icons.receipt_long),
    ModernSelectionItem(
      value: 'mutual_fund',
      title: 'Mutual fund',
      icon: Icons.account_balance,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.holdingId == null) return;
    final holding = await ref
        .read(portfolioRepositoryProvider)
        .getHolding(widget.holdingId!);
    if (holding == null || !mounted) return;
    setState(() {
      _walletId = holding.walletId;
      _tickerController.text = holding.tickerSymbol;
      _nameController.text = holding.assetName;
      _assetType = holding.assetType;
      _sharesController.text = holding.shares.toString();
      _currencyCode = holding.currencyCode;
      _costController.text = MoneyUtils.toMajorText(
        holding.avgCostBasisMinor,
        currencyCode: holding.currencyCode,
      );
      _priceController.text = holding.currentPriceMinor == null
          ? ''
          : MoneyUtils.toMajorText(
              holding.currentPriceMinor!,
              currencyCode: holding.currencyCode,
            );
    });
  }

  @override
  void dispose() {
    _tickerController.dispose();
    _nameController.dispose();
    _sharesController.dispose();
    _costController.dispose();
    _priceController.dispose();
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
    final now = DateTime.now();
    final companion = InvestmentHoldingsCompanion(
      walletId: Value(_walletId!),
      tickerSymbol: Value(_tickerController.text.trim().toUpperCase()),
      assetName: Value(_nameController.text.trim()),
      assetType: Value(_assetType),
      shares: Value(double.tryParse(_sharesController.text) ?? 0),
      avgCostBasisMinor: Value(
        MoneyUtils.toMinor(
          double.tryParse(_costController.text) ?? 0,
          currencyCode: _currencyCode,
        ),
      ),
      currencyCode: Value(_currencyCode),
      currentPriceMinor: Value(
        _priceController.text.trim().isEmpty
            ? null
            : MoneyUtils.toMinor(
                double.tryParse(_priceController.text) ?? 0,
                currencyCode: _currencyCode,
              ),
      ),
      lastPriceUpdate: Value(_priceController.text.trim().isEmpty ? null : now),
    );
    final repo = ref.read(portfolioRepositoryProvider);
    if (widget.holdingId == null) {
      await repo.insertHolding(companion);
    } else {
      await repo.updateHolding(widget.holdingId!, companion);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(activeWalletsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.holdingId == null ? 'Add Holding' : 'Edit Holding'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            walletsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('$error'),
              data: (wallets) => ModernSelectionField<int>(
                label: 'Account',
                value: _walletId,
                leadingIcon: Icons.account_balance_wallet_outlined,
                items: [
                  for (final wallet in wallets)
                    ModernSelectionItem(
                      value: wallet.id,
                      title: wallet.name,
                      subtitle: wallet.type.replaceAll('_', ' '),
                      icon: Icons.account_balance_outlined,
                      badge: wallet.currencyCode,
                    ),
                ],
                onChanged: (value) {
                  Wallet? selected;
                  for (final wallet in wallets) {
                    if (wallet.id == value) selected = wallet;
                  }
                  setState(() {
                    _walletId = value;
                    _currencyCode =
                        selected?.currencyCode ??
                        MoneyUtils.defaultCurrencyCode;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tickerController,
              decoration: const InputDecoration(labelText: 'Ticker'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Asset name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            ModernSelectionField<String>(
              label: 'Asset type',
              value: _assetType,
              leadingIcon: Icons.category_outlined,
              searchEnabled: false,
              items: _assetTypeItems,
              onChanged: (value) =>
                  setState(() => _assetType = value ?? 'stock'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sharesController,
              decoration: const InputDecoration(labelText: 'Shares'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter shares' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costController,
              decoration: InputDecoration(
                labelText: 'Average cost basis',
                prefixText: '$_currencyCode ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Current price (manual)',
                prefixText: '$_currencyCode ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}

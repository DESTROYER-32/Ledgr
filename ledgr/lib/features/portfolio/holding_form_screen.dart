import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';

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
    if (!_formKey.currentState!.validate() || _walletId == null) return;
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
              data: (wallets) => DropdownButtonFormField<int>(
                initialValue: _walletId,
                decoration: const InputDecoration(labelText: 'Account'),
                items: [
                  for (final wallet in wallets)
                    DropdownMenuItem(
                      value: wallet.id,
                      child: Text('${wallet.name} (${wallet.currencyCode})'),
                    ),
                ],
                onChanged: (value) {
                  final wallet = wallets.where((w) => w.id == value).first;
                  setState(() {
                    _walletId = value;
                    _currencyCode = wallet.currencyCode;
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
            DropdownButtonFormField<String>(
              initialValue: _assetType,
              decoration: const InputDecoration(labelText: 'Asset type'),
              items: const [
                DropdownMenuItem(value: 'stock', child: Text('Stock')),
                DropdownMenuItem(value: 'etf', child: Text('ETF')),
                DropdownMenuItem(value: 'crypto', child: Text('Crypto')),
                DropdownMenuItem(value: 'bond', child: Text('Bond')),
                DropdownMenuItem(
                  value: 'mutual_fund',
                  child: Text('Mutual fund'),
                ),
              ],
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

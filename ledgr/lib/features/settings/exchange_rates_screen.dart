import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/utils/currency_utils.dart';

class ExchangeRatesScreen extends ConsumerStatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  ConsumerState<ExchangeRatesScreen> createState() =>
      _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends ConsumerState<ExchangeRatesScreen> {
  String _search = '';
  List<String> _customCurrencies = [];
  @override
  void initState() {
    super.initState();
    _loadCustom();
  }

  Future<void> _loadCustom() async {
    final raw = await ref
        .read(settingsRepositoryProvider)
        .get('custom_currencies');
    if (raw != null) {
      try {
        final list = raw.split(',').where((s) => s.isNotEmpty).toList();
        setState(() => _customCurrencies = list);
      } catch (_) {}
    }
  }

  Future<void> _addCustomCurrency(String code) async {
    if (_customCurrencies.contains(code.toUpperCase())) return;
    _customCurrencies.add(code.toUpperCase());
    await ref
        .read(settingsRepositoryProvider)
        .set('custom_currencies', _customCurrencies.join(','));
    setState(() {});
  }

  Future<void> _removeCustomCurrency(String code) async {
    _customCurrencies.remove(code);
    await ref
        .read(settingsRepositoryProvider)
        .set('custom_currencies', _customCurrencies.join(','));
    await ref.read(exchangeRateServiceProvider).removeCustomRate(code);
    setState(() {});
  }

  Future<void> _setCustomRate(String currency, double? currentRate) async {
    final controller = TextEditingController(
      text: currentRate != null ? currentRate.toString() : '',
    );
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('1 USD = ? $currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a custom exchange rate:'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Rate',
                prefixText: '1 USD = ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final rate = double.tryParse(controller.text);
              if (rate != null && rate > 0) {
                Navigator.pop(ctx, rate);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
    if (result != null) {
      await ref
          .read(exchangeRateServiceProvider)
          .setCustomRate(currency, result);
      ref.invalidate(exchangeRatesProvider);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratesAsync = ref.watch(exchangeRatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh rates',
            onPressed: () {
              ref.invalidate(exchangeRatesProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Exchange rates are fetched from fawazahmed0/currency-api',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Exchange Rates'),
                  content: const Text(
                    'Exchange rates are provided by the fawazahmed0 exchange rate API.\n\n'
                    'All rates are relative to 1 USD.\n\n'
                    'Tap any currency to set a custom rate override.',
                  ),
                  actions: [
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ratesAsync.when(
        data: (rates) {
          final allCodes = <String>{
            ...CurrencyUtils.codes,
            ..._customCurrencies,
          };
          final filtered = allCodes.where((code) {
            if (_search.isEmpty) return true;
            final q = _search.toLowerCase();
            final info = CurrencyUtils.currencies
                .where((c) => c.code == code)
                .firstOrNull;
            return code.toLowerCase().contains(q) ||
                (info?.name.toLowerCase().contains(q) ?? false);
          }).toList()..sort();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No currencies found',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search currencies...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      '1 USD = ?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: () => _showAddCurrencyDialog(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(exchangeRatesProvider);
                    await ref.read(exchangeRatesProvider.future);
                  },
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final code = filtered[index];
                      final rate = rates[code.toLowerCase()];
                      final isCustom = _customCurrencies.contains(code);
                      final symbol = CurrencyUtils.symbolFor(code) ?? code;

                      return ListTile(
                        key: ValueKey('$code-$rate'),
                        leading: CircleAvatar(
                          backgroundColor: isCustom
                              ? theme.colorScheme.secondaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          radius: 18,
                          child: Text(
                            symbol.length <= 2 ? symbol : code.substring(0, 2),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCustom
                                  ? theme.colorScheme.onSecondaryContainer
                                  : null,
                            ),
                          ),
                        ),
                        title: Text(code),
                        subtitle: Text(
                          rate != null
                              ? '1 USD = $rate $code'
                              : 'No rate available',
                        ),
                        trailing: isCustom
                            ? IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () => _removeCustomCurrency(code),
                              )
                            : null,
                        onTap: () => _setCustomRate(code, rate),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 8),
              Text('Failed to load rates: $err'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(exchangeRatesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCurrencyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Currency'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Currency code',
            hintText: 'e.g. BTC',
            helperText: 'Enter a 3-letter currency code',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                Navigator.pop(ctx);
                _addCustomCurrency(code);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

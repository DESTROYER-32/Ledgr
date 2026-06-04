import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';

class ExchangeRatesScreen extends ConsumerStatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  ConsumerState<ExchangeRatesScreen> createState() => _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends ConsumerState<ExchangeRatesScreen> {
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveRate() async {
    final from = _fromCtrl.text.trim().toUpperCase();
    final to = _toCtrl.text.trim().toUpperCase();
    final rate = double.tryParse(_rateCtrl.text);
    if (from.isEmpty || to.isEmpty || rate == null || rate <= 0) return;

    setState(() => _isLoading = true);
    await ref.read(exchangeRateRepositoryProvider).setRate(from, to, rate);
    setState(() => _isLoading = false);

    _fromCtrl.clear();
    _toCtrl.clear();
    _rateCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Exchange Rates')),
      body: FutureBuilder<List<dynamic>>(
        future: ref.read(exchangeRateRepositoryProvider).getAll(),
        builder: (context, snapshot) {
          final rates = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Rate', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _fromCtrl,
                              decoration: const InputDecoration(
                                labelText: 'From',
                                hintText: 'USD',
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _toCtrl,
                              decoration: const InputDecoration(
                                labelText: 'To',
                                hintText: 'EUR',
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _rateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Rate',
                          hintText: '0.85',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _isLoading ? null : _saveRate,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (rates.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No exchange rates configured.',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                )
              else
                ...rates.map((r) => ListTile(
                      title: Text('${r.fromCurrency} → ${r.toCurrency}'),
                      subtitle: Text('${r.rate}'),
                    )),
            ],
          );
        },
      ),
    );
  }
}

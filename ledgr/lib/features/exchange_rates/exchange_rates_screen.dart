import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/empty_state.dart';

class ExchangeRatesScreen extends ConsumerWidget {
  const ExchangeRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesFuture = ref.watch(exchangeRateRepositoryProvider).getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rates'),
      ),
      body: FutureBuilder<List<ExchangeRate>>(
        future: ratesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rates = snapshot.data!;
          if (rates.isEmpty) {
            return const EmptyState(
              icon: Icons.currency_exchange,
              title: 'No Exchange Rates',
              subtitle: 'Add currency conversion rates.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rates.length,
            itemBuilder: (context, index) {
              final r = rates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title:
                      Text('${r.fromCurrency} \u2192 ${r.toCurrency}'),
                  subtitle: Text('Rate: ${r.rate.toStringAsFixed(6)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import 'cash_flow_projector.dart';

final cashFlowProjectorProvider = Provider<CashFlowProjector>((ref) {
  return CashFlowProjector(ref.watch(exchangeRateServiceProvider));
});

final overallCashFlowProvider = FutureProvider<CashFlowProjection>((ref) async {
  ref.watch(activeWalletsProvider);
  ref.watch(allTransactionsProvider);
  ref.watch(activeRecurringProvider);
  ref.watch(walletBalancesProvider);
  ref.watch(exchangeRatesProvider);

  return ref
      .watch(cashFlowProjectorProvider)
      .project(
        wallets: await ref.watch(activeWalletsProvider.future),
        walletBalances: await ref.watch(walletBalancesProvider.future),
        transactions: await ref.watch(allTransactionsProvider.future),
        recurringTransactions: await ref.watch(activeRecurringProvider.future),
        displayCurrency: await ref.watch(displayCurrencyProvider.future),
      );
});

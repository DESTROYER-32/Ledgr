import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import 'net_worth_calculator.dart';

final netWorthCalculatorProvider = Provider<NetWorthCalculator>((ref) {
  return NetWorthCalculator(ref.watch(exchangeRateServiceProvider));
});

final currentNetWorthProvider = FutureProvider<NetWorthSummary>((ref) async {
  ref.watch(activeWalletsProvider);
  ref.watch(allObjectivesProvider);
  ref.watch(walletBalancesProvider);
  ref.watch(exchangeRatesProvider);

  final wallets = await ref.watch(activeWalletsProvider.future);
  final objectives = await ref.watch(allObjectivesProvider.future);
  final balances = await ref.watch(walletBalancesProvider.future);
  final displayCurrency = await ref.watch(displayCurrencyProvider.future);

  return ref
      .watch(netWorthCalculatorProvider)
      .calculate(
        wallets: wallets,
        walletBalances: balances,
        objectives: objectives,
        displayCurrency: displayCurrency,
      );
});

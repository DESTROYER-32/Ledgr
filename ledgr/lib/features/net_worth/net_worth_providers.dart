import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import 'net_worth_calculator.dart';

class NetWorthDelta {
  const NetWorthDelta({required this.amountMinor, required this.percent});

  final int amountMinor;
  final double? percent;
}

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

  final summary = await ref.watch(netWorthCalculatorProvider).calculate(
        wallets: wallets,
        walletBalances: balances,
        objectives: objectives,
        displayCurrency: displayCurrency,
      );

  final snapshotRepo = ref.read(netWorthSnapshotRepositoryProvider);
  final now = DateTime.now();
  Future.microtask(() async {
    try {
      await snapshotRepo.upsertForDay(
        date: now,
        assetsMinor: summary.assetsMinor,
        liabilitiesMinor: summary.liabilitiesMinor,
        netWorthMinor: summary.netWorthMinor,
        currencyCode: summary.currencyCode,
        details: {
          'assets': [
            for (final item in summary.assetWallets)
              {'name': item.name, 'amountMinor': item.amountMinor},
          ],
          'liabilities': [
            for (final item in summary.liabilityItems)
              {'name': item.name, 'amountMinor': item.amountMinor},
          ],
        },
      );
    } catch (_) {}
  });

  return summary;
});

final netWorthHistoryProvider = StreamProvider<List<NetWorthSnapshot>>((ref) {
  ref.watch(currentNetWorthProvider);
  return ref.watch(netWorthSnapshotRepositoryProvider).watchRecent();
});

final netWorthMonthlyDeltaProvider = FutureProvider<NetWorthDelta?>((
  ref,
) async {
  final summary = await ref.watch(currentNetWorthProvider.future);
  final previous = await ref
      .watch(netWorthSnapshotRepositoryProvider)
      .latestBefore(DateTime.now().subtract(const Duration(days: 30)));
  if (previous == null || previous.currencyCode != summary.currencyCode) {
    return null;
  }
  final amount = summary.netWorthMinor - previous.netWorthMinor;
  final percent = previous.netWorthMinor == 0
      ? null
      : amount / previous.netWorthMinor.abs() * 100;
  return NetWorthDelta(amountMinor: amount, percent: percent);
});

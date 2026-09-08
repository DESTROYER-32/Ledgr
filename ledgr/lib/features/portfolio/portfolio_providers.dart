import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';

class PortfolioSummary {
  const PortfolioSummary({
    required this.currencyCode,
    required this.totalValueMinor,
    required this.totalCostBasisMinor,
    required this.totalGainLossMinor,
    required this.gainLossPercent,
    required this.allocationByType,
  });

  final String currencyCode;
  final int totalValueMinor;
  final int totalCostBasisMinor;
  final int totalGainLossMinor;
  final double? gainLossPercent;
  final Map<String, int> allocationByType;
}

final portfolioHoldingsProvider = StreamProvider<List<InvestmentHolding>>((
  ref,
) {
  return ref.watch(portfolioRepositoryProvider).watchHoldings();
});

final holdingsByWalletProvider =
    StreamProvider.family<List<InvestmentHolding>, int>((ref, walletId) {
      return ref.watch(portfolioRepositoryProvider).watchByWallet(walletId);
    });

final portfolioSummaryProvider = FutureProvider<PortfolioSummary>((ref) async {
  final holdings = await ref.watch(portfolioHoldingsProvider.future);
  ref.watch(exchangeRatesProvider);
  final displayCurrency = await ref.watch(displayCurrencyProvider.future);

  var totalValue = 0;
  var totalCost = 0;
  final allocation = <String, int>{};

  for (final holding in holdings) {
    final price = holding.currentPriceMinor ?? holding.avgCostBasisMinor;
    final value = (holding.shares * price).round();
    final cost = (holding.shares * holding.avgCostBasisMinor).round();
    final convertedValue = holding.currencyCode == displayCurrency
        ? value
        : (await ref
              .watch(exchangeRateServiceProvider)
              .convert(value, holding.currencyCode, displayCurrency));
    final convertedCost = holding.currencyCode == displayCurrency
        ? cost
        : (await ref
              .watch(exchangeRateServiceProvider)
              .convert(cost, holding.currencyCode, displayCurrency));
    totalValue += convertedValue;
    totalCost += convertedCost;
    allocation[holding.assetType] =
        (allocation[holding.assetType] ?? 0) + convertedValue;
  }

  final gainLoss = totalValue - totalCost;
  return PortfolioSummary(
    currencyCode: displayCurrency,
    totalValueMinor: totalValue,
    totalCostBasisMinor: totalCost,
    totalGainLossMinor: gainLoss,
    gainLossPercent: totalCost == 0 ? null : gainLoss / totalCost.abs() * 100,
    allocationByType: allocation,
  );
});

import '../../core/database/app_database.dart';
import '../../core/services/exchange_rate_service.dart';

class NetWorthSummary {
  const NetWorthSummary({
    required this.assetsMinor,
    required this.liabilitiesMinor,
    required this.netWorthMinor,
    required this.currencyCode,
    required this.assetWallets,
    required this.liabilityItems,
  });

  final int assetsMinor;
  final int liabilitiesMinor;
  final int netWorthMinor;
  final String currencyCode;
  final List<NetWorthBreakdownItem> assetWallets;
  final List<NetWorthBreakdownItem> liabilityItems;
}

class NetWorthBreakdownItem {
  const NetWorthBreakdownItem({
    required this.name,
    required this.amountMinor,
    required this.currencyCode,
  });

  final String name;
  final int amountMinor;
  final String currencyCode;
}

class NetWorthCalculator {
  NetWorthCalculator(this._exchangeRates);

  final ExchangeRateService _exchangeRates;

  Future<NetWorthSummary> calculate({
    required List<Wallet> wallets,
    required Map<int, int> walletBalances,
    required List<Objective> objectives,
    required String displayCurrency,
  }) async {
    var assets = 0;
    var liabilities = 0;
    final assetItems = <NetWorthBreakdownItem>[];
    final liabilityItems = <NetWorthBreakdownItem>[];

    for (final wallet in wallets.where((wallet) => !wallet.archived)) {
      final balance = walletBalances[wallet.id] ?? wallet.initialBalanceMinor;
      final converted = await _exchangeRates.convert(
        balance.abs(),
        wallet.currencyCode,
        displayCurrency,
      );
      final normalizedType = wallet.type.toLowerCase().replaceAll(' ', '_');
      final isCredit = normalizedType == 'credit_card' ||
          normalizedType == 'credit' ||
          normalizedType == 'loan';

      final isLiability = isCredit ? balance >= 0 : balance < 0;

      if (isLiability) {
        liabilities += converted;
        liabilityItems.add(
          NetWorthBreakdownItem(
            name: wallet.name,
            amountMinor: converted,
            currencyCode: displayCurrency,
          ),
        );
      } else {
        assets += converted;
        assetItems.add(
          NetWorthBreakdownItem(
            name: wallet.name,
            amountMinor: converted,
            currencyCode: displayCurrency,
          ),
        );
      }
    }

    for (final objective in objectives.where(
      (objective) =>
          objective.type.toLowerCase() == 'loan' && !objective.archived,
    )) {
      final converted = await _exchangeRates.convert(
        objective.amountMinor.abs(),
        objective.currencyCode,
        displayCurrency,
      );
      liabilities += converted;
      liabilityItems.add(
        NetWorthBreakdownItem(
          name: objective.name,
          amountMinor: converted,
          currencyCode: displayCurrency,
        ),
      );
    }

    return NetWorthSummary(
      assetsMinor: assets,
      liabilitiesMinor: liabilities,
      netWorthMinor: assets - liabilities,
      currencyCode: displayCurrency,
      assetWallets: assetItems,
      liabilityItems: liabilityItems,
    );
  }
}

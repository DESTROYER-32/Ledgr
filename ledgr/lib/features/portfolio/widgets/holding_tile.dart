import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/money_utils.dart';

class HoldingTile extends StatelessWidget {
  const HoldingTile({super.key, required this.holding, this.onTap});

  final InvestmentHolding holding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final price = holding.currentPriceMinor ?? holding.avgCostBasisMinor;
    final value = (holding.shares * price).round();
    final cost = (holding.shares * holding.avgCostBasisMinor).round();
    final gain = value - cost;
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(holding.tickerSymbol.toUpperCase()),
        subtitle: Text(
          '${holding.assetName} • ${holding.shares.toStringAsFixed(4)} shares',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(MoneyUtils.format(value, currencyCode: holding.currencyCode)),
            Text(
              '${gain >= 0 ? '+' : ''}${MoneyUtils.format(gain, currencyCode: holding.currencyCode)}',
              style: TextStyle(
                color: gain >= 0
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

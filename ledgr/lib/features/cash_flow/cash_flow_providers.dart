import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import 'cash_flow_projector.dart';

class CashFlowRequest {
  const CashFlowRequest({this.walletId, this.days = 90});

  final int? walletId;
  final int days;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashFlowRequest &&
          other.walletId == walletId &&
          other.days == days;

  @override
  int get hashCode => Object.hash(walletId, days);
}

final cashFlowProjectorProvider = Provider<CashFlowProjector>((ref) {
  return CashFlowProjector(ref.watch(exchangeRateServiceProvider));
});

final cashFlowProjectionProvider =
    FutureProvider.family<CashFlowProjection, CashFlowRequest>((
  ref,
  request,
) async {
  ref.watch(activeWalletsProvider);
  ref.watch(allTransactionsProvider);
  ref.watch(activeRecurringProvider);
  ref.watch(walletBalancesProvider);
  ref.watch(exchangeRatesProvider);

  return ref.watch(cashFlowProjectorProvider).project(
        wallets: await ref.watch(activeWalletsProvider.future),
        walletBalances: await ref.watch(walletBalancesProvider.future),
        transactions: await ref.watch(allTransactionsProvider.future),
        recurringTransactions: await ref.watch(
          activeRecurringProvider.future,
        ),
        displayCurrency: await ref.watch(displayCurrencyProvider.future),
        days: request.days,
        walletId: request.walletId,
      );
});

final overallCashFlowProvider = FutureProvider<CashFlowProjection>((ref) {
  return ref.watch(cashFlowProjectionProvider(const CashFlowRequest()).future);
});

final walletCashFlowProvider = FutureProvider.family<CashFlowProjection, int>((
  ref,
  walletId,
) {
  return ref.watch(
    cashFlowProjectionProvider(CashFlowRequest(walletId: walletId)).future,
  );
});

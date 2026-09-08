import '../../core/database/app_database.dart';
import '../../core/services/exchange_rate_service.dart';
import '../../core/utils/recurring_utils.dart';

class CashFlowPoint {
  const CashFlowPoint({required this.date, required this.balanceMinor});
  final DateTime date;
  final int balanceMinor;
}

class CashFlowEvent {
  const CashFlowEvent({
    required this.date,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    required this.type,
  });

  final DateTime date;
  final String title;
  final int amountMinor;
  final String currencyCode;
  final String type;
}

class CashFlowProjection {
  const CashFlowProjection({
    required this.currencyCode,
    required this.points,
    required this.events,
    required this.lowestPoint,
  });

  final String currencyCode;
  final List<CashFlowPoint> points;
  final List<CashFlowEvent> events;
  final CashFlowPoint lowestPoint;
}

class CashFlowProjector {
  CashFlowProjector(this._exchangeRates);

  final ExchangeRateService _exchangeRates;

  Future<CashFlowProjection> project({
    required List<Wallet> wallets,
    required Map<int, int> walletBalances,
    required List<Transaction> transactions,
    required List<RecurringTransaction> recurringTransactions,
    required String displayCurrency,
    int days = 90,
    int? walletId,
  }) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: days));
    var runningBalance = 0;

    final includedWallets = wallets
        .where(
          (wallet) =>
              !wallet.archived && (walletId == null || wallet.id == walletId),
        )
        .toList();
    final includedWalletIds = includedWallets
        .map((wallet) => wallet.id)
        .toSet();

    for (final wallet in includedWallets) {
      runningBalance += await _exchangeRates.convert(
        walletBalances[wallet.id] ?? wallet.initialBalanceMinor,
        wallet.currencyCode,
        displayCurrency,
      );
    }

    final eventsByDay = <DateTime, List<CashFlowEvent>>{};
    void addEvent(CashFlowEvent event) {
      final key = DateTime(event.date.year, event.date.month, event.date.day);
      eventsByDay.putIfAbsent(key, () => []).add(event);
    }

    for (final transaction in transactions.where((t) {
      final isInWindow = !t.date.isBefore(start) && !t.date.isAfter(end);
      if (!isInWindow) return false;
      if (walletId == null) return true;
      return t.walletId == walletId || t.transferWalletId == walletId;
    })) {
      final amountMinor = await _signedConvertedTransactionAmount(
        transaction.type,
        transaction.amountMinor,
        transaction.currencyCode,
        displayCurrency,
        sourceIncluded: includedWalletIds.contains(transaction.walletId),
        destinationIncluded:
            transaction.transferWalletId != null &&
            includedWalletIds.contains(transaction.transferWalletId),
      );
      if (amountMinor == 0) continue;
      addEvent(
        CashFlowEvent(
          date: transaction.date,
          title: transaction.title ?? transaction.type,
          amountMinor: amountMinor,
          currencyCode: displayCurrency,
          type: transaction.type,
        ),
      );
    }

    for (final recurring in recurringTransactions.where((r) {
      if (!r.active) return false;
      if (walletId == null) return true;
      return r.walletId == walletId || r.transferWalletId == walletId;
    })) {
      final firstDue = recurring.nextDueDate ?? recurring.startDate;
      var occurrenceStart = firstDue;
      while (occurrenceStart.isBefore(start)) {
        final next = RecurringUtils.computeNextDueDate(
          recurring.scheduleRule,
          occurrenceStart,
        );
        if (!next.isAfter(occurrenceStart)) break;
        occurrenceStart = next;
      }
      final instances = RecurringUtils.generateInstances(
        recurring.scheduleRule,
        occurrenceStart,
        recurring.endDate,
        days + 1,
      ).where((date) => !date.isBefore(start) && !date.isAfter(end));

      for (final date in instances) {
        final amountMinor = await _signedConvertedTransactionAmount(
          recurring.transactionType,
          recurring.amountMinor,
          recurring.currencyCode,
          displayCurrency,
          sourceIncluded: includedWalletIds.contains(recurring.walletId),
          destinationIncluded:
              recurring.transferWalletId != null &&
              includedWalletIds.contains(recurring.transferWalletId),
        );
        if (amountMinor == 0) continue;
        addEvent(
          CashFlowEvent(
            date: date,
            title: recurring.title ?? recurring.transactionType,
            amountMinor: amountMinor,
            currencyCode: displayCurrency,
            type: recurring.transactionType,
          ),
        );
      }
    }

    final points = <CashFlowPoint>[];
    for (var offset = 0; offset <= days; offset++) {
      final day = start.add(Duration(days: offset));
      for (final event in eventsByDay[day] ?? const <CashFlowEvent>[]) {
        runningBalance += event.amountMinor;
      }
      points.add(CashFlowPoint(date: day, balanceMinor: runningBalance));
    }

    final lowest = points.reduce(
      (a, b) => a.balanceMinor <= b.balanceMinor ? a : b,
    );
    final events = eventsByDay.values.expand((items) => items).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return CashFlowProjection(
      currencyCode: displayCurrency,
      points: points,
      events: events,
      lowestPoint: lowest,
    );
  }

  Future<int> _signedConvertedTransactionAmount(
    String type,
    int amountMinor,
    String fromCurrency,
    String toCurrency, {
    required bool sourceIncluded,
    required bool destinationIncluded,
  }) async {
    final converted = await _exchangeRates.convert(
      amountMinor.abs(),
      fromCurrency,
      toCurrency,
    );
    if (type == 'transfer') {
      if (sourceIncluded && destinationIncluded) return 0;
      if (destinationIncluded) return converted;
      return -converted;
    }
    return type == 'income' ? converted : -converted;
  }
}

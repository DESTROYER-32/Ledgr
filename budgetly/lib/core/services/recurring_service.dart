import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/repositories/recurring_repository.dart';
import '../database/repositories/transaction_repository.dart';
import '../database/repositories/wallet_repository.dart';
import '../utils/money_utils.dart';
import '../utils/recurring_utils.dart';

class RecurringService {
  final RecurringRepository _recurringRepo;
  final TransactionRepository _transactionRepo;
  final WalletRepository _walletRepo;

  RecurringService(
    this._recurringRepo,
    this._transactionRepo,
    this._walletRepo,
  );

  Future<int> processDueRecurrings() async {
    final now = DateTime.now();
    final all = await _recurringRepo.getActive();
    final due = all
        .where((r) => r.nextDueDate != null && !r.nextDueDate!.isAfter(now))
        .toList();

    if (due.isEmpty) return 0;

    var count = 0;
    for (final r in due) {
      final wallet = await _walletRepo.getById(r.walletId);

      await _transactionRepo.insert(
        TransactionsCompanion(
          type: Value(r.transactionType),
          specialType: Value(r.specialType),
          amountMinor: Value(r.amountMinor),
          currencyCode: Value(
            wallet?.currencyCode ?? MoneyUtils.defaultCurrencyCode,
          ),
          date: Value(r.nextDueDate!),
          walletId: Value(r.walletId),
          transferWalletId: Value(r.transferWalletId),
          categoryId: Value(r.categoryId),
          title: Value(r.title),
          note: Value(r.note),
        ),
      );

      final nextDate = _nextDate(r.nextDueDate!, r.scheduleRule);
      if (nextDate != null &&
          (r.endDate == null || !nextDate.isAfter(r.endDate!))) {
        await _recurringRepo.update(
          r.id,
          RecurringTransactionsCompanion(nextDueDate: Value(nextDate)),
        );
      } else {
        await _recurringRepo.update(
          r.id,
          const RecurringTransactionsCompanion(active: Value(false)),
        );
      }

      count++;
    }

    return count;
  }

  DateTime? _nextDate(DateTime from, String rule) {
    if (!RecurringUtils.isSupportedRule(rule)) return null;
    return RecurringUtils.computeNextDueDate(rule, from);
  }
}

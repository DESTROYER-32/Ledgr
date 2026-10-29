import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/repositories/recurring_repository.dart';
import '../database/repositories/transaction_repository.dart';
import '../utils/recurring_utils.dart';

class RecurringService {
  final AppDatabase _db;
  final RecurringRepository _recurringRepo;
  final TransactionRepository _transactionRepo;

  RecurringService(this._db, this._recurringRepo, this._transactionRepo);

  Future<int> processDueRecurrings({
    DateTime? asOf,
    int maxCatchUpPerRule = 50,
  }) async {
    final now = asOf ?? DateTime.now();
    final all = await _recurringRepo.getActive();
    final due = all
        .where((r) => r.nextDueDate != null && !r.nextDueDate!.isAfter(now))
        .toList();

    if (due.isEmpty) return 0;

    var count = 0;
    for (final r in due) {
      var currentDueDate = r.nextDueDate!;
      var iterations = 0;

      while (!currentDueDate.isAfter(now) && iterations < maxCatchUpPerRule) {
        iterations++;
        final dateToInsert = currentDueDate;
        final nextDate = _nextDate(currentDueDate, r.scheduleRule);

        await _db.transaction(() async {
          await _transactionRepo.insert(
            TransactionsCompanion(
              type: Value(r.transactionType),
              specialType: Value(r.specialType),
              amountMinor: Value(r.amountMinor),
              currencyCode: Value(r.currencyCode),
              date: Value(dateToInsert),
              walletId: Value(r.walletId),
              transferWalletId: Value(r.transferWalletId),
              categoryId: Value(r.categoryId),
              title: Value(r.title),
              note: Value(r.note),
            ),
          );

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
        });

        count++;

        if (nextDate == null ||
            (r.endDate != null && nextDate.isAfter(r.endDate!)) ||
            !nextDate.isAfter(currentDueDate)) {
          break;
        }
        currentDueDate = nextDate;
      }
    }

    return count;
  }

  DateTime? _nextDate(DateTime from, String rule) {
    if (!RecurringUtils.isSupportedRule(rule)) return null;
    return RecurringUtils.computeNextDueDate(rule, from);
  }
}

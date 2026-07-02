import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ledgr/core/database/app_database.dart';
import 'package:ledgr/core/database/repositories/recurring_repository.dart';
import 'package:ledgr/core/database/repositories/transaction_repository.dart';
import 'package:ledgr/core/database/repositories/wallet_repository.dart';
import 'package:ledgr/core/services/exchange_rate_service.dart';
import 'package:ledgr/core/services/recurring_service.dart';
import 'package:ledgr/core/database/repositories/settings_repository.dart';

void main() {
  test(
    'processDueRecurrings preserves source wallet currency and metadata',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final settingsRepo = SettingsRepository(db);
      final exchangeRates = ExchangeRateService(settingsRepo);
      final walletRepo = WalletRepository(db, exchangeRates);
      final recurringRepo = RecurringRepository(db);
      final transactionRepo = TransactionRepository(db);
      final service = RecurringService(db, recurringRepo, transactionRepo);

      final sourceWalletId = await walletRepo.insert(
        WalletsCompanion.insert(
          name: 'Euro checking',
          type: 'checking',
          currencyCode: 'EUR',
          initialBalanceMinor: 0,
        ),
      );
      final transferWalletId = await walletRepo.insert(
        WalletsCompanion.insert(
          name: 'Savings',
          type: 'savings',
          currencyCode: 'EUR',
          initialBalanceMinor: 0,
        ),
      );

      await recurringRepo.insert(
        RecurringTransactionsCompanion.insert(
          transactionType: 'transfer',
          specialType: const Value('scheduled'),
          amountMinor: 4250,
          currencyCode: const Value('EUR'),
          walletId: sourceWalletId,
          transferWalletId: Value(transferWalletId),
          title: const Value('Monthly savings'),
          scheduleRule: 'monthly',
          startDate: DateTime(2024),
          nextDueDate: Value(DateTime(2024)),
        ),
      );

      final processed = await service.processDueRecurrings();
      final transactions = await transactionRepo.search();

      expect(processed, 1);
      expect(transactions, hasLength(1));
      expect(transactions.single.currencyCode, 'EUR');
      expect(transactions.single.specialType, 'scheduled');
      expect(transactions.single.transferWalletId, transferWalletId);
    },
  );
}

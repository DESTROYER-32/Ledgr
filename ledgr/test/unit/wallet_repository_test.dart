import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ledgr/core/database/app_database.dart';
import 'package:ledgr/core/database/repositories/settings_repository.dart';
import 'package:ledgr/core/database/repositories/transaction_repository.dart';
import 'package:ledgr/core/database/repositories/wallet_repository.dart';
import 'package:ledgr/core/services/exchange_rate_service.dart';

void main() {
  test('balanceForWallet excludes future scheduled transactions', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final settingsRepo = SettingsRepository(db);
    final exchangeRates = ExchangeRateService(settingsRepo);
    final walletRepo = WalletRepository(db, exchangeRates);
    final transactionRepo = TransactionRepository(db);

    final walletId = await walletRepo.insert(
      WalletsCompanion.insert(
        name: 'Checking',
        type: 'checking',
        currencyCode: 'INR',
        initialBalanceMinor: 100000,
      ),
    );

    await transactionRepo.insert(
      TransactionsCompanion.insert(
        type: 'expense',
        specialType: const Value('scheduled'),
        recurrenceRule: const Value('monthly'),
        amountMinor: 25000,
        currencyCode: 'INR',
        date: DateTime.now().add(const Duration(days: 2)),
        walletId: walletId,
        title: const Value('Future SIP'),
      ),
    );

    await transactionRepo.insert(
      TransactionsCompanion.insert(
        type: 'expense',
        amountMinor: 10000,
        currencyCode: 'INR',
        date: DateTime.now().subtract(const Duration(days: 1)),
        walletId: walletId,
        title: const Value('Posted expense'),
      ),
    );

    final balance = await walletRepo.balanceForWallet(walletId);

    expect(balance, 90000);
  });
}

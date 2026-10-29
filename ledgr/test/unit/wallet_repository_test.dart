import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';

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

  test('balancesForWallets accurately sums multiple wallets', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final settingsRepo = SettingsRepository(db);
    final exchangeRates = ExchangeRateService(settingsRepo);
    final walletRepo = WalletRepository(db, exchangeRates);
    final transactionRepo = TransactionRepository(db);

    final w1 = await walletRepo.insert(
      WalletsCompanion.insert(
        name: 'Wallet 1',
        type: 'cash',
        currencyCode: 'USD',
        initialBalanceMinor: 5000,
      ),
    );
    final w2 = await walletRepo.insert(
      WalletsCompanion.insert(
        name: 'Wallet 2',
        type: 'bank',
        currencyCode: 'USD',
        initialBalanceMinor: 10000,
      ),
    );

    await transactionRepo.insert(
      TransactionsCompanion.insert(
        type: 'income',
        amountMinor: 2000,
        currencyCode: 'USD',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        walletId: w1,
      ),
    );
    await transactionRepo.insert(
      TransactionsCompanion.insert(
        type: 'transfer',
        amountMinor: 1500,
        currencyCode: 'USD',
        date: DateTime.now().subtract(const Duration(minutes: 30)),
        walletId: w2,
        transferWalletId: Value(w1),
      ),
    );

    final wallets = await walletRepo.getAll();
    final balances = await walletRepo.balancesForWallets(wallets);

    expect(balances[w1], 5000 + 2000 + 1500); // 8500
    expect(balances[w2], 10000 - 1500); // 8500
  });

  test(
    'totalBalance falls back gracefully when offline and rates missing',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final settingsRepo = SettingsRepository(db);
      final exchangeRates = ExchangeRateService(
        settingsRepo,
        client: MockClient((_) async => throw Exception('offline')),
      );
      final walletRepo = WalletRepository(db, exchangeRates);

      await walletRepo.insert(
        WalletsCompanion.insert(
          name: 'EUR Account',
          type: 'cash',
          currencyCode: 'EUR',
          initialBalanceMinor: 5000,
        ),
      );

      // Rate is missing and network is offline. Must not throw!
      final total = await walletRepo.totalBalance(currencyCode: 'USD');
      expect(total, 5000);
    },
  );

  test(
    'wallet delete archives if references exist, deletes if no references',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final settingsRepo = SettingsRepository(db);
      final exchangeRates = ExchangeRateService(settingsRepo);
      final walletRepo = WalletRepository(db, exchangeRates);
      final transactionRepo = TransactionRepository(db);

      final w1 = await walletRepo.insert(
        WalletsCompanion.insert(
          name: 'Active Account with Transactions',
          type: 'checking',
          currencyCode: 'USD',
          initialBalanceMinor: 0,
        ),
      );
      final w2 = await walletRepo.insert(
        WalletsCompanion.insert(
          name: 'Empty Account',
          type: 'cash',
          currencyCode: 'USD',
          initialBalanceMinor: 0,
        ),
      );

      await transactionRepo.insert(
        TransactionsCompanion.insert(
          type: 'expense',
          amountMinor: 500,
          currencyCode: 'USD',
          date: DateTime.now(),
          walletId: w1,
        ),
      );

      // Deleting w1 should archive it because it has transactions
      await walletRepo.delete(w1);
      final w1After = await walletRepo.getById(w1);
      expect(w1After, isNotNull);
      expect(w1After!.archived, isTrue);

      // Deleting w2 should delete it completely
      await walletRepo.delete(w2);
      final w2After = await walletRepo.getById(w2);
      expect(w2After, isNull);
    },
  );
}

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ledgr/core/database/app_database.dart';
import 'package:ledgr/core/database/repositories/delete_log_repository.dart';

void main() {
  test('restoreTransaction handles deleted category gracefully', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = DeleteLogRepository(db);

    final walletId = await db
        .into(db.wallets)
        .insert(
          WalletsCompanion.insert(
            name: 'Checking',
            type: 'checking',
            currencyCode: 'USD',
            initialBalanceMinor: 100000,
          ),
        );

    // Insert a delete log whose category ID does not exist in Categories table
    final logId = await db
        .into(db.deleteLogs)
        .insert(
          DeleteLogsCompanion.insert(
            type: 'transaction',
            jsonData: jsonEncode({
              'type': 'expense',
              'specialType': 'none',
              'amountMinor': 4500,
              'currencyCode': 'USD',
              'date': DateTime(2024, 2, 1).toIso8601String(),
              'walletId': walletId,
              'categoryId': 999999, // Non-existent category
              'title': 'Dinner out',
            }),
          ),
        );

    await repo.restoreTransaction(logId);

    final transactions = await db.select(db.transactions).get();
    expect(transactions, hasLength(1));
    expect(transactions.first.title, 'Dinner out');
    expect(transactions.first.amountMinor, 4500);
    // categoryId should be null because category 999999 does not exist
    expect(transactions.first.categoryId, isNull);

    // Delete log should be removed after restore
    final remainingLogs = await db.select(db.deleteLogs).get();
    expect(remainingLogs, isEmpty);
  });

  test(
    'restoreTransaction falls back to available active wallet if original wallet was deleted',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final repo = DeleteLogRepository(db);

      final fallbackWalletId = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Savings',
              type: 'savings',
              currencyCode: 'USD',
              initialBalanceMinor: 50000,
            ),
          );

      final logId = await db
          .into(db.deleteLogs)
          .insert(
            DeleteLogsCompanion.insert(
              type: 'transaction',
              jsonData: jsonEncode({
                'type': 'expense',
                'specialType': 'none',
                'amountMinor': 1200,
                'currencyCode': 'USD',
                'date': DateTime(2024, 3, 1).toIso8601String(),
                'walletId': 888888, // Non-existent wallet
                'title': 'Coffee',
              }),
            ),
          );

      await repo.restoreTransaction(logId);

      final transactions = await db.select(db.transactions).get();
      expect(transactions, hasLength(1));
      expect(transactions.first.title, 'Coffee');
      expect(transactions.first.walletId, fallbackWalletId);
    },
  );
}

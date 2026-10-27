import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ledgr/core/database/app_database.dart';
import 'package:ledgr/core/database/repositories/settings_repository.dart';
import 'package:ledgr/core/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('BackupService includes all 13 tables including net worth', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final settingsRepo = SettingsRepository(db);
    final service = BackupService(db, settingsRepo);

    // Verify all 13 database tables are covered in BackupService.tables
    expect(
      BackupService.tables,
      containsAll([
        'wallets',
        'categories',
        'budgets',
        'objectives',
        'settings',
        'transactions',
        'transaction_budgets',
        'budget_category_limits',
        'budget_wallets',
        'recurring_transactions',
        'associated_titles',
        'delete_logs',
        'net_worth_snapshots',
      ]),
    );
    expect(BackupService.tables.length, 13);

    // Insert wallet
    await db
        .into(db.wallets)
        .insert(
          WalletsCompanion.insert(
            name: 'Investment Wallet',
            type: 'investment',
            currencyCode: 'USD',
            initialBalanceMinor: 500000,
          ),
        );

    // Insert net worth snapshot
    await db
        .into(db.netWorthSnapshots)
        .insert(
          NetWorthSnapshotsCompanion.insert(
            date: DateTime(2024, 1, 15),
            assetsMinor: 500000,
            liabilitiesMinor: 0,
            netWorthMinor: 500000,
            currencyCode: 'USD',
          ),
        );

    final backupData = await service.buildBackupData();
    final tablesData = backupData['tables'] as Map<String, dynamic>;

    expect(tablesData['wallets'], hasLength(1));
    expect(tablesData['net_worth_snapshots'], hasLength(1));

    // Test write and restore into fresh DB
    final tempDir = await Directory.systemTemp.createTemp('ledgr_backup_test');
    addTearDown(() => tempDir.delete(recursive: true));
    final backupFile = File('${tempDir.path}/backup.json');

    await service.writeBackupFile(backupFile);
    expect(await backupFile.exists(), isTrue);

    // Fresh target DB
    final targetDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(targetDb.close);
    final targetSettings = SettingsRepository(targetDb);
    final targetService = BackupService(targetDb, targetSettings);

    await targetService.restoreFromFile(backupFile);

    final restoredWallets = await targetDb.select(targetDb.wallets).get();
    expect(restoredWallets, hasLength(1));
    expect(restoredWallets.first.name, 'Investment Wallet');
    expect(restoredWallets.first.type, 'investment');

    final restoredSnapshots = await targetDb
        .select(targetDb.netWorthSnapshots)
        .get();
    expect(restoredSnapshots, hasLength(1));
    expect(restoredSnapshots.first.netWorthMinor, 500000);
  });
}

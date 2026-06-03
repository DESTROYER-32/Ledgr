import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export Backup'),
                  subtitle: const Text('Save all data to a .db file'),
                  onTap: () => _exportBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Restore Backup'),
                  subtitle: const Text('Restore from a .db file'),
                  onTap: () => _importBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: const Text('Export CSV'),
                  subtitle: const Text('Export transactions to CSV'),
                  onTap: () => _exportCsv(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Import CSV'),
                  subtitle: const Text('Import transactions from CSV'),
                  onTap: () => _importCsv(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/budgetly.db');
      if (!dbFile.existsSync()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No data to export')));
        }
        return;
      }
      final backupDir = await getTemporaryDirectory();
      final backupFile = File('${backupDir.path}/budgetly_backup.db');
      await dbFile.copy(backupFile.path);
      await Share.shareXFiles([XFile(backupFile.path)], text: 'Budgetly Backup');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.single.path == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/budgetly.db');
      final sourceFile = File(result.files.single.path!);
      await sourceFile.copy(dbFile.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restore complete. Restart app.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final transactions = await repo.search();
      final rows = [
        ['Date', 'Type', 'Amount', 'Title', 'Note'],
        for (final t in transactions)
          [
            t.date.toIso8601String(),
            t.type,
            (t.amountMinor / 100).toStringAsFixed(2),
            t.title ?? '',
            t.note ?? '',
          ],
      ];
      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/budgetly_transactions.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Budgetly Transactions');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('CSV export failed: $e')));
      }
    }
  }

  Future<void> _importCsv(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final rows = const CsvToListConverter().convert(content);
      if (rows.length < 2) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('CSV file is empty')));
        }
        return;
      }
      final repo = ref.read(transactionRepositoryProvider);
      final wallets = await ref.read(walletRepositoryProvider).watchActive().first;
      var count = 0;
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 4) continue;
        try {
          final date = DateTime.parse(row[0].toString());
          final type = row[1].toString().toLowerCase();
          final amount = (double.tryParse(row[2].toString()) ?? 0) * 100;
          final title = row.length > 3 ? row[3].toString() : null;
          if (wallets.isEmpty) break;
          await repo.insert(TransactionsCompanion.insert(
            type: type,
            amountMinor: amount.round(),
            currencyCode: 'USD',
            date: date,
            walletId: wallets.first.id,
            title: Value(title),
          ));
          count++;
        } catch (_) {}
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported $count transactions')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('CSV import failed: $e')));
      }
    }
  }
}

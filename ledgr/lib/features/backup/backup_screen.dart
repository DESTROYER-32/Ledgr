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
                  onTap: () => _importBackup(context, ref),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No data to export')));
        }
        return;
      }
      final backupDir = await getTemporaryDirectory();
      final backupFile = File('${backupDir.path}/budgetly_backup.db');
      await dbFile.copy(backupFile.path);
      await Share.shareXFiles([
        XFile(backupFile.path),
      ], text: 'Budgetly Backup');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.single.path == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/budgetly.db');
      final sourceFile = File(result.files.single.path!);

      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Restore backup?'),
            content: const Text(
              'This will replace the current Budgetly database. A safety copy of the current database will be created first.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Restore'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }

      if (dbFile.existsSync()) {
        final safetyFile = File(
          '${dir.path}/budgetly_pre_restore_${DateTime.now().millisecondsSinceEpoch}.db',
        );
        await dbFile.copy(safetyFile.path);
      }

      final db = ref.read(appDatabaseProvider);
      await db.close();
      ref.invalidate(appDatabaseProvider);

      await sourceFile.copy(dbFile.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore complete. Restart app.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final transactions = await repo.search();
      final rows = [
        [
          'Date',
          'Type',
          'Amount',
          'Currency',
          'WalletId',
          'CategoryId',
          'Title',
          'Note',
        ],
        for (final t in transactions)
          [
            t.date.toIso8601String(),
            t.type,
            (t.amountMinor / 100).toStringAsFixed(2),
            t.currencyCode,
            t.walletId,
            t.categoryId ?? '',
            t.title ?? '',
            t.note ?? '',
          ],
      ];
      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/budgetly_transactions.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Budgetly Transactions');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('CSV export failed: $e')));
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('CSV file is empty')));
        }
        return;
      }
      final repo = ref.read(transactionRepositoryProvider);
      final labelRepo = ref.read(associatedTitleRepositoryProvider);
      final wallets = await ref
          .read(walletRepositoryProvider)
          .watchActive()
          .first;
      final walletIds = wallets.map((w) => w.id).toSet();
      final header = rows.first
          .map((cell) => cell.toString().toLowerCase().trim())
          .toList();
      final dateIndex = _columnIndex(header, [
        'date',
        'posted date',
        'transaction date',
      ]);
      final typeIndex = _columnIndex(header, ['type', 'transaction type']);
      final amountIndex = _columnIndex(header, ['amount', 'value']);
      final currencyIndex = _columnIndex(header, ['currency', 'currency code']);
      final walletIndex = _columnIndex(header, [
        'walletid',
        'wallet id',
        'account id',
      ]);
      final categoryIndex = _columnIndex(header, ['categoryid', 'category id']);
      final titleIndex = _columnIndex(header, [
        'title',
        'description',
        'merchant',
        'payee',
      ]);
      final noteIndex = _columnIndex(header, ['note', 'notes', 'memo']);
      var count = 0;
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (wallets.isEmpty || dateIndex == null || amountIndex == null) break;
        try {
          final date = DateTime.parse(_cell(row, dateIndex));
          final rawAmount = double.tryParse(_cell(row, amountIndex)) ?? 0;
          final rawType = typeIndex == null
              ? ''
              : _cell(row, typeIndex).toLowerCase();
          final type = rawType == 'income' || rawAmount > 0
              ? 'income'
              : 'expense';
          final amountMinor = (rawAmount.abs() * 100).round();
          final title = titleIndex == null
              ? null
              : _emptyToNull(_cell(row, titleIndex));
          final note = noteIndex == null
              ? null
              : _emptyToNull(_cell(row, noteIndex));
          final currency = currencyIndex == null
              ? wallets.first.currencyCode
              : (_emptyToNull(_cell(row, currencyIndex)) ??
                        wallets.first.currencyCode)
                    .toUpperCase();
          final parsedWalletId = walletIndex == null
              ? null
              : int.tryParse(_cell(row, walletIndex));
          final walletId =
              parsedWalletId != null && walletIds.contains(parsedWalletId)
              ? parsedWalletId
              : wallets.first.id;
          final parsedCategoryId = categoryIndex == null
              ? null
              : int.tryParse(_cell(row, categoryIndex));
          final categoryId =
              parsedCategoryId ??
              (title == null
                  ? null
                  : await labelRepo.findCategoryIdForTitle(title));
          await repo.insert(
            TransactionsCompanion.insert(
              type: type,
              amountMinor: amountMinor,
              currencyCode: currency,
              date: date,
              walletId: walletId,
              title: Value(title),
              note: Value(note),
              categoryId: categoryId == null
                  ? const Value.absent()
                  : Value(categoryId),
            ),
          );
          count++;
        } catch (_) {}
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Imported $count transactions')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('CSV import failed: $e')));
      }
    }
  }

  int? _columnIndex(List<String> header, List<String> names) {
    for (final name in names) {
      final index = header.indexOf(name);
      if (index != -1) return index;
    }
    return null;
  }

  String _cell(List<dynamic> row, int index) =>
      index < row.length ? row[index].toString().trim() : '';

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();
}

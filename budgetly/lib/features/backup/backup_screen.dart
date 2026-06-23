import 'dart:convert';
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

  static const _backupVersion = 1;
  static const _tables = [
    'wallets',
    'categories',
    'budgets',
    'objectives',
    'settings',
    'transactions',
    'budget_category_limits',
    'budget_wallets',
    'recurring_transactions',
    'associated_titles',
    'delete_logs',
  ];

  static const _dateColumnsByTable = <String, Set<String>>{
    'wallets': {'created_at', 'updated_at'},
    'categories': {'created_at', 'updated_at'},
    'budgets': {'period_start', 'period_end', 'created_at', 'updated_at'},
    'objectives': {'deadline', 'created_at', 'updated_at'},
    'transactions': {'date', 'created_at', 'updated_at'},
    'recurring_transactions': {
      'start_date',
      'end_date',
      'next_due_date',
      'created_at',
    },
    'associated_titles': {'created_at'},
    'delete_logs': {'deleted_at'},
  };

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
                  title: const Text('Export Full Backup'),
                  subtitle: const Text(
                    'Save accounts, categories, budgets, goals, settings, and transactions',
                  ),
                  onTap: () => _exportBackup(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Restore Full Backup'),
                  subtitle: const Text(
                    'Restore all data from a Budgetly backup file',
                  ),
                  onTap: () => _importBackup(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: const Text('Export Transactions CSV'),
                  subtitle: const Text('Export transactions to CSV'),
                  onTap: () => _exportCsv(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Import Transactions CSV'),
                  subtitle: const Text(
                    'Import transactions only. Requires accounts to already exist.',
                  ),
                  onTap: () => _importCsv(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final data = <String, dynamic>{
        'app': 'budgetly',
        'version': _backupVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'tables': <String, dynamic>{},
      };
      final tables = data['tables'] as Map<String, dynamic>;
      for (final table in _tables) {
        final rows = await db.customSelect('SELECT * FROM $table').get();
        tables[table] = rows.map((row) => _jsonSafeMap(row.data)).toList();
      }

      final backupDir = await getTemporaryDirectory();
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFile = File(
        '${backupDir.path}/budgetly_full_backup_$stamp.json',
      );
      await backupFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );
      await Share.shareXFiles([
        XFile(backupFile.path),
      ], text: 'Budgetly Full Backup');
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
      final sourceFile = File(result.files.single.path!);
      final decoded = jsonDecode(await sourceFile.readAsString());
      if (decoded is! Map<String, dynamic> ||
          decoded['app'] != 'budgetly' ||
          decoded['tables'] is! Map<String, dynamic>) {
        throw const FormatException(
          'This is not a valid Budgetly full backup file.',
        );
      }

      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Restore backup?'),
            content: const Text(
              'This will replace all current Budgetly data with the backup contents. This action cannot be undone from inside the app.',
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

      final db = ref.read(appDatabaseProvider);
      final tables = decoded['tables'] as Map<String, dynamic>;
      await db.transaction(() async {
        await db.customStatement('PRAGMA foreign_keys = OFF');
        for (final table in _tables.reversed) {
          await db.customStatement('DELETE FROM $table');
        }
        for (final table in _tables) {
          final rows = tables[table];
          if (rows is! List) continue;
          for (final row in rows) {
            if (row is Map<String, dynamic>) {
              await db.customStatement(
                _insertSql(table, _normalizeRow(table, row)),
              );
            } else if (row is Map) {
              await db.customStatement(
                _insertSql(
                  table,
                  _normalizeRow(table, Map<String, dynamic>.from(row)),
                ),
              );
            }
          }
        }
        await db.customStatement('PRAGMA foreign_keys = ON');
      });
      _invalidateDataProviders(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Full restore complete')));
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

  Map<String, dynamic> _jsonSafeMap(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is DateTime) return MapEntry(key, value.toIso8601String());
      return MapEntry(key, value);
    });
  }

  String _insertSql(String table, Map<String, dynamic> row) {
    final columns = row.keys.map((column) => '"$column"').join(', ');
    final values = row.values.map(_sqlLiteral).join(', ');
    return 'INSERT OR REPLACE INTO $table ($columns) VALUES ($values)';
  }

  Map<String, dynamic> _normalizeRow(String table, Map<String, dynamic> row) {
    final dateColumns = _dateColumnsByTable[table];
    if (dateColumns == null) return row;
    final normalized = Map<String, dynamic>.from(row);
    for (final column in dateColumns) {
      final value = normalized[column];
      if (value is String && value.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          normalized[column] = parsed.millisecondsSinceEpoch ~/ 1000;
        }
      }
    }
    return normalized;
  }

  String _sqlLiteral(Object? value) {
    if (value == null) return 'NULL';
    if (value is bool) return value ? '1' : '0';
    if (value is num) return value.toString();
    final escaped = value.toString().replaceAll("'", "''");
    return "'$escaped'";
  }

  void _invalidateDataProviders(WidgetRef ref) {
    ref.invalidate(activeWalletsProvider);
    ref.invalidate(allWalletsProvider);
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(activeCategoriesProvider);
    ref.invalidate(parentCategoriesProvider);
    ref.invalidate(expenseCategoriesProvider);
    ref.invalidate(allBudgetsProvider);
    ref.invalidate(activeRecurringProvider);
    ref.invalidate(defaultWalletIdProvider);
    ref.invalidate(displayCurrencyProvider);
    ref.invalidate(favoriteCurrenciesProvider);
    ref.invalidate(themeConfigProvider);
    ref.invalidate(totalBalanceProvider);
    ref.invalidate(walletBalancesProvider);
    ref.invalidate(allObjectivesProvider);
  }
}

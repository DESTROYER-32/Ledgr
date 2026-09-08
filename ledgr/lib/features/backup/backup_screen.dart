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
import '../../core/services/backup_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/modern_selection_field.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  int _reloadToken = 0;

  void _reload() => setState(() => _reloadToken++);

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(backupServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: FutureBuilder<
          ({BackupScheduleConfig config, List<BackupSlot> slots})>(
        key: ValueKey(_reloadToken),
        future: _loadBackupState(service),
        builder: (context, snapshot) {
          final config = snapshot.data?.config ?? BackupScheduleConfig.defaults;
          final slots = snapshot.data?.slots ?? const <BackupSlot>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _manualBackupCard(context),
              const SizedBox(height: 16),
              _automaticBackupCard(context, config),
              const SizedBox(height: 16),
              _slotCard(context, slots, config),
            ],
          );
        },
      ),
    );
  }

  Future<({BackupScheduleConfig config, List<BackupSlot> slots})>
      _loadBackupState(BackupService service) async {
    final config = await service.scheduleConfig();
    final slots = await service.slots();
    return (config: config, slots: slots);
  }

  Widget _manualBackupCard(BuildContext context) => Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Export Full Backup'),
              subtitle: const Text('Share a full JSON backup file'),
              onTap: () => _exportBackup(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Restore Full Backup'),
              subtitle: const Text('Restore all data from a Ledgr backup file'),
              onTap: () => _importBackup(context),
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
      );

  Widget _automaticBackupCard(
    BuildContext context,
    BackupScheduleConfig config,
  ) =>
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Automatic backup schedule'),
              subtitle: Text(
                config.lastRunAt == null
                    ? 'No automatic backup has run yet'
                    : 'Last run: ${_formatDate(config.lastRunAt!)}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ModernSelectionField<AutoBackupFrequency>(
                label: 'Frequency',
                value: config.frequency,
                leadingIcon: Icons.schedule_outlined,
                searchEnabled: false,
                items: AutoBackupFrequency.values
                    .map(
                      (f) => ModernSelectionItem(
                        value: f,
                        title: f.label,
                        subtitle: f == AutoBackupFrequency.off
                            ? 'Automatic backups disabled'
                            : 'Run ${f.label.toLowerCase()} and rotate through saved slots',
                        icon: f == AutoBackupFrequency.off
                            ? Icons.pause_circle_outline
                            : Icons.event_repeat_outlined,
                      ),
                    )
                    .toList(),
                onChanged: (frequency) async {
                  if (frequency == null) return;
                  try {
                    await ref.read(backupServiceProvider).saveScheduleConfig(
                          frequency: frequency,
                          slotCount: config.slotCount,
                        );
                    _reload();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Failed to save backup schedule: $e')),
                    );
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: Text('Backup slots: ${config.slotCount}'),
              subtitle: const Text('Oldest slots are overwritten in rotation'),
              trailing: SizedBox(
                width: 140,
                child: Slider(
                  value: config.slotCount.toDouble(),
                  min: BackupService.minSlots.toDouble(),
                  max: BackupService.maxSlots.toDouble(),
                  divisions: BackupService.maxSlots - BackupService.minSlots,
                  label: config.slotCount.toString(),
                  onChanged: (value) async {
                    try {
                      await ref.read(backupServiceProvider).saveScheduleConfig(
                            frequency: config.frequency,
                            slotCount: value.round(),
                          );
                      _reload();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to save backup slots: $e')),
                      );
                    }
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Run automatic backup now'),
              subtitle: const Text('Writes the next rotating slot immediately'),
              onTap: () => _runAutoBackupNow(context),
            ),
          ],
        ),
      );

  Widget _slotCard(
    BuildContext context,
    List<BackupSlot> slots,
    BackupScheduleConfig config,
  ) =>
      Card(
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.inventory_2_outlined),
              title: Text('Backup slots'),
              subtitle: Text('Restore or share any saved automatic backup'),
            ),
            if (slots.isEmpty)
              const ListTile(title: Text('Loading slots...'))
            else
              for (final slot in slots) ...[
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(child: Text('${slot.index + 1}')),
                  title: Text(
                    slot.exists ? _formatDate(slot.createdAt!) : 'Empty slot',
                  ),
                  subtitle: Text(_slotSubtitle(slot, config.nextSlotIndex)),
                  trailing: slot.exists
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'restore') _restoreSlot(context, slot);
                            if (value == 'share') _shareSlot(context, slot);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'restore', child: Text('Restore')),
                            PopupMenuItem(value: 'share', child: Text('Share')),
                          ],
                        )
                      : null,
                ),
              ],
          ],
        ),
      );

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final backupFile =
          await ref.read(backupServiceProvider).writeTemporaryShareBackup();
      await Share.shareXFiles([
        XFile(backupFile.path),
      ], text: 'Ledgr Full Backup');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null ||
          result.files.single.path == null ||
          !context.mounted) {
        return;
      }
      await _restoreFile(context, File(result.files.single.path!));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    }
  }

  Future<void> _runAutoBackupNow(BuildContext context) async {
    try {
      final slot = await ref.read(backupServiceProvider).runAutoBackupNow();
      _reload();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved backup to slot ${slot.index + 1}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    }
  }

  Future<void> _restoreSlot(BuildContext context, BackupSlot slot) =>
      _restoreFile(context, slot.file, label: 'slot ${slot.index + 1}');

  Future<void> _shareSlot(BuildContext context, BackupSlot slot) async {
    await Share.shareXFiles([
      XFile(slot.file.path),
    ], text: 'Ledgr Backup Slot ${slot.index + 1}');
  }

  Future<void> _restoreFile(
    BuildContext context,
    File file, {
    String label = 'backup',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restore $label?'),
        content: const Text(
          'This will replace all current Ledgr data with the backup contents. This action cannot be undone from inside the app.',
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
    await ref.read(backupServiceProvider).restoreFromFile(file);
    _invalidateDataProviders(ref);
    _reload();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Full restore complete')));
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
            MoneyUtils.toMajorText(t.amountMinor, currencyCode: t.currencyCode),
            t.currencyCode,
            t.walletId,
            t.categoryId ?? '',
            t.title ?? '',
            t.note ?? '',
          ],
      ];
      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ledgr_transactions.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Ledgr Transactions');
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
      final wallets =
          await ref.read(walletRepositoryProvider).watchActive().first;
      if (wallets.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Create a wallet before importing CSV transactions.',
              ),
            ),
          );
        }
        return;
      }
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
        if (dateIndex == null || amountIndex == null) break;
        try {
          final date = DateTime.parse(_cell(row, dateIndex));
          final rawAmount = double.tryParse(_cell(row, amountIndex)) ?? 0;
          final rawType =
              typeIndex == null ? '' : _cell(row, typeIndex).toLowerCase();
          final type =
              rawType == 'income' || rawAmount > 0 ? 'income' : 'expense';
          final rowCurrency = currencyIndex == null
              ? wallets.first.currencyCode
              : (_emptyToNull(_cell(row, currencyIndex)) ??
                      wallets.first.currencyCode)
                  .toUpperCase();
          final amountMinor = MoneyUtils.toMinor(
            rawAmount.abs(),
            currencyCode: rowCurrency,
          );
          final title =
              titleIndex == null ? null : _emptyToNull(_cell(row, titleIndex));
          final note =
              noteIndex == null ? null : _emptyToNull(_cell(row, noteIndex));
          final currency = rowCurrency;
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
          final categoryId = parsedCategoryId ??
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
              categoryId:
                  categoryId == null ? const Value.absent() : Value(categoryId),
            ),
          );
          count++;
        } catch (error, stackTrace) {
          AppLogger.warning(
            'Skipped invalid CSV transaction row during import',
            error: error,
            stackTrace: stackTrace,
          );
        }
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

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  String _slotSubtitle(BackupSlot slot, int nextSlotIndex) {
    if (slot.exists) {
      final overwriteLabel =
          slot.index == nextSlotIndex ? ' • next overwrite' : '';
      return '${_formatBytes(slot.sizeBytes)}$overwriteLabel';
    }
    if (slot.index == nextSlotIndex) return 'Next backup will be saved here';
    return 'No backup yet';
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

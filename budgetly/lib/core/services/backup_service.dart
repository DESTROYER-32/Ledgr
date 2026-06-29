import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../database/repositories/settings_repository.dart';

class BackupSlot {
  final int index;
  final File file;
  final DateTime? createdAt;
  final int sizeBytes;

  const BackupSlot({
    required this.index,
    required this.file,
    required this.createdAt,
    required this.sizeBytes,
  });

  bool get exists => createdAt != null;
}

enum AutoBackupFrequency {
  off,
  daily,
  weekly,
  monthly;

  String get label => switch (this) {
    AutoBackupFrequency.off => 'Off',
    AutoBackupFrequency.daily => 'Daily',
    AutoBackupFrequency.weekly => 'Weekly',
    AutoBackupFrequency.monthly => 'Monthly',
  };

  Duration? get interval => switch (this) {
    AutoBackupFrequency.off => null,
    AutoBackupFrequency.daily => const Duration(days: 1),
    AutoBackupFrequency.weekly => const Duration(days: 7),
    AutoBackupFrequency.monthly => const Duration(days: 30),
  };
}

class BackupScheduleConfig {
  final AutoBackupFrequency frequency;
  final int slotCount;
  final DateTime? lastRunAt;
  final int nextSlotIndex;

  const BackupScheduleConfig({
    required this.frequency,
    required this.slotCount,
    required this.lastRunAt,
    required this.nextSlotIndex,
  });

  static const defaults = BackupScheduleConfig(
    frequency: AutoBackupFrequency.off,
    slotCount: 5,
    lastRunAt: null,
    nextSlotIndex: 0,
  );
}

class BackupService {
  BackupService(this._db, this._settings);

  static const backupVersion = 1;
  static const minSlots = 1;
  static const maxSlots = 5;
  static const _frequencyKey = 'auto_backup_frequency';
  static const _slotCountKey = 'auto_backup_slot_count';
  static const _lastRunKey = 'auto_backup_last_run_at';
  static const _nextSlotKey = 'auto_backup_next_slot_index';

  static const tables = [
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

  static const dateColumnsByTable = <String, Set<String>>{
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

  final AppDatabase _db;
  final SettingsRepository _settings;

  Future<Map<String, dynamic>> buildBackupData() async {
    final data = <String, dynamic>{
      'app': 'budgetly',
      'version': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': <String, dynamic>{},
    };
    final tableData = data['tables'] as Map<String, dynamic>;
    for (final table in tables) {
      final rows = await _db.customSelect('SELECT * FROM $table').get();
      tableData[table] = rows.map((row) => _jsonSafeMap(row.data)).toList();
    }
    return data;
  }

  Future<File> writeBackupFile(File file) async {
    await file.parent.create(recursive: true);
    final data = await buildBackupData();
    return file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<File> writeTemporaryShareBackup() async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return writeBackupFile(
      File('${dir.path}/budgetly_full_backup_$stamp.json'),
    );
  }

  Future<Directory> slotsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory(p.join(dir.path, 'budgetly_backups'));
  }

  Future<File> slotFile(int index) async {
    final dir = await slotsDirectory();
    return File(
      p.join(dir.path, 'budgetly_auto_backup_slot_${index + 1}.json'),
    );
  }

  Future<List<BackupSlot>> slots() async {
    final config = await scheduleConfig();
    final result = <BackupSlot>[];
    for (var i = 0; i < config.slotCount; i++) {
      final file = await slotFile(i);
      if (await file.exists()) {
        DateTime? createdAt;
        try {
          final decoded = jsonDecode(await file.readAsString());
          if (decoded is Map && decoded['exportedAt'] is String) {
            createdAt = DateTime.tryParse(decoded['exportedAt'] as String);
          }
        } catch (_) {}
        final stat = await file.stat();
        result.add(
          BackupSlot(
            index: i,
            file: file,
            createdAt: createdAt ?? stat.modified,
            sizeBytes: stat.size,
          ),
        );
      } else {
        result.add(
          BackupSlot(index: i, file: file, createdAt: null, sizeBytes: 0),
        );
      }
    }
    return result;
  }

  Future<BackupScheduleConfig> scheduleConfig() async {
    final rawFrequency = await _settings.get(_frequencyKey);
    final frequency = AutoBackupFrequency.values.firstWhere(
      (value) => value.name == rawFrequency,
      orElse: () => BackupScheduleConfig.defaults.frequency,
    );
    final slotCount =
        (int.tryParse(await _settings.get(_slotCountKey) ?? '') ??
                BackupScheduleConfig.defaults.slotCount)
            .clamp(minSlots, maxSlots);
    final lastRunRaw = await _settings.get(_lastRunKey);
    final nextSlotIndex =
        (int.tryParse(await _settings.get(_nextSlotKey) ?? '') ??
                BackupScheduleConfig.defaults.nextSlotIndex)
            .clamp(0, slotCount - 1);
    return BackupScheduleConfig(
      frequency: frequency,
      slotCount: slotCount,
      lastRunAt: lastRunRaw == null ? null : DateTime.tryParse(lastRunRaw),
      nextSlotIndex: nextSlotIndex,
    );
  }

  Future<void> saveScheduleConfig({
    required AutoBackupFrequency frequency,
    required int slotCount,
  }) async {
    final clampedSlots = slotCount.clamp(minSlots, maxSlots);
    await _settings.set(_frequencyKey, frequency.name);
    await _settings.set(_slotCountKey, clampedSlots.toString());
    final currentNext =
        int.tryParse(await _settings.get(_nextSlotKey) ?? '') ?? 0;
    if (currentNext >= clampedSlots) {
      await _settings.set(_nextSlotKey, '0');
    }
  }

  Future<BackupSlot> runAutoBackupNow() async {
    final config = await scheduleConfig();
    final slotIndex = config.nextSlotIndex.clamp(0, config.slotCount - 1);
    final file = await slotFile(slotIndex);
    await writeBackupFile(file);
    final now = DateTime.now();
    await _settings.set(_lastRunKey, now.toIso8601String());
    await _settings.set(
      _nextSlotKey,
      ((slotIndex + 1) % config.slotCount).toString(),
    );
    final stat = await file.stat();
    return BackupSlot(
      index: slotIndex,
      file: file,
      createdAt: now,
      sizeBytes: stat.size,
    );
  }

  Future<bool> runScheduledBackupIfDue() async {
    final config = await scheduleConfig();
    final interval = config.frequency.interval;
    if (interval == null) return false;
    final lastRun = config.lastRunAt;
    if (lastRun != null && DateTime.now().difference(lastRun) < interval) {
      return false;
    }
    await runAutoBackupNow();
    return true;
  }

  Future<void> restoreFromFile(File sourceFile) async {
    final decoded = jsonDecode(await sourceFile.readAsString());
    if (decoded is! Map<String, dynamic> ||
        decoded['app'] != 'budgetly' ||
        decoded['tables'] is! Map<String, dynamic>) {
      throw const FormatException(
        'This is not a valid Budgetly full backup file.',
      );
    }
    final tableData = decoded['tables'] as Map<String, dynamic>;
    await _db.transaction(() async {
      await _db.customStatement('PRAGMA foreign_keys = OFF');
      try {
        for (final table in tables.reversed) {
          await _db.customStatement('DELETE FROM $table');
        }
        for (final table in tables) {
          final rows = tableData[table];
          if (rows is! List) continue;
          for (final row in rows) {
            if (row is Map<String, dynamic>) {
              await _db.customStatement(
                _insertSql(table, _normalizeRow(table, row)),
              );
            } else if (row is Map) {
              await _db.customStatement(
                _insertSql(
                  table,
                  _normalizeRow(table, Map<String, dynamic>.from(row)),
                ),
              );
            }
          }
        }
      } finally {
        await _db.customStatement('PRAGMA foreign_keys = ON');
      }
    });
  }

  Map<String, dynamic> _jsonSafeMap(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is DateTime) return MapEntry(key, value.toIso8601String());
      return MapEntry(key, value);
    });
  }

  String _insertSql(String table, Map<String, dynamic> row) {
    final columns = row.keys.map(_quoteIdentifier).join(', ');
    final values = row.values.map(_sqlLiteral).join(', ');
    return 'INSERT OR REPLACE INTO ${_quoteIdentifier(table)} ($columns) VALUES ($values)';
  }

  String _quoteIdentifier(String identifier) {
    final valid = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(identifier);
    if (!valid) {
      throw FormatException('Invalid backup column or table name: $identifier');
    }
    return '"$identifier"';
  }

  Map<String, dynamic> _normalizeRow(String table, Map<String, dynamic> row) {
    final dateColumns = dateColumnsByTable[table];
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
}

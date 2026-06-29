import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../utils/money_utils.dart';

class DeleteLogRepository {
  final AppDatabase _db;
  DeleteLogRepository(this._db);

  Stream<List<DeleteLog>> watchAll() =>
      (_db.deleteLogs.select()..orderBy([
            (d) =>
                OrderingTerm(expression: d.deletedAt, mode: OrderingMode.desc),
          ]))
          .watch();

  Future<void> logDelete(String type, Map<String, dynamic> data) => _db
      .into(_db.deleteLogs)
      .insert(
        DeleteLogsCompanion.insert(type: type, jsonData: jsonEncode(data)),
      );

  Future<void> restoreTransaction(int deleteLogId) async {
    final log =
        await (_db.deleteLogs.select()..where((d) => d.id.equals(deleteLogId)))
            .getSingle();
    final data = jsonDecode(log.jsonData) as Map<String, dynamic>;
    await _db
        .into(_db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: data['type'] as String,
            amountMinor: data['amountMinor'] as int,
            currencyCode:
                data['currencyCode'] as String? ??
                MoneyUtils.defaultCurrencyCode,
            date: DateTime.parse(data['date'] as String),
            walletId: data['walletId'] as int,
            transferWalletId: data['transferWalletId'] != null
                ? Value(data['transferWalletId'] as int)
                : const Value(null),
            categoryId: data['categoryId'] != null
                ? Value(data['categoryId'] as int)
                : const Value(null),
            title: data['title'] != null
                ? Value(data['title'] as String)
                : const Value(null),
            note: data['note'] != null
                ? Value(data['note'] as String)
                : const Value(null),
            tags: data['tags'] != null
                ? Value(data['tags'] as String)
                : const Value(null),
            specialType: Value(data['specialType'] as String? ?? 'none'),
          ),
        );
    await (_db.deleteLogs.delete()..where((d) => d.id.equals(deleteLogId)))
        .go();
  }

  Future<void> clearAll() async {
    await _db.deleteLogs.delete().go();
  }
}

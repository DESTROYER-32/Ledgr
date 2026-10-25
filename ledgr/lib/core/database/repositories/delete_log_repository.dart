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
    final walletId = data['walletId'] as int;
    final wallet =
        await (_db.wallets.select()..where((w) => w.id.equals(walletId)))
            .getSingleOrNull();

    int effectiveWalletId = walletId;
    if (wallet == null) {
      final fallbackWallet =
          await (_db.wallets.select()
                ..where((w) => w.archived.equals(false))
                ..limit(1))
              .getSingleOrNull() ??
          await (_db.wallets.select()..limit(1)).getSingleOrNull();
      if (fallbackWallet == null) {
        throw StateError(
          'Cannot restore transaction: no account exists. Please create an account first.',
        );
      }
      effectiveWalletId = fallbackWallet.id;
    }

    int? effectiveTransferWalletId;
    if (data['transferWalletId'] != null) {
      final transferId = data['transferWalletId'] as int;
      final transferWallet =
          await (_db.wallets.select()..where((w) => w.id.equals(transferId)))
              .getSingleOrNull();
      if (transferWallet != null) {
        effectiveTransferWalletId = transferId;
      }
    }

    int? effectiveCategoryId;
    if (data['categoryId'] != null) {
      final catId = data['categoryId'] as int;
      final cat =
          await (_db.categories.select()..where((c) => c.id.equals(catId)))
              .getSingleOrNull();
      if (cat != null) {
        effectiveCategoryId = catId;
      }
    }

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
            walletId: effectiveWalletId,
            transferWalletId: effectiveTransferWalletId != null
                ? Value(effectiveTransferWalletId)
                : const Value(null),
            categoryId: effectiveCategoryId != null
                ? Value(effectiveCategoryId)
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

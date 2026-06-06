import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

class TransactionRepository {
  final AppDatabase _db;
  TransactionRepository(this._db);

  Stream<List<Transaction>> watchAll() => _db.transactions.select().watch();

  Stream<List<Transaction>> watchRecent({int limit = 10}) =>
      (_db.transactions.select()
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ])
            ..limit(limit))
          .watch();

  Stream<List<Transaction>> watchBySpecialType(String specialType) =>
      (_db.transactions.select()
            ..where((t) => t.specialType.equals(specialType))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .watch();

  Stream<List<Transaction>> watchUpcoming() =>
      (_db.transactions.select()
            ..where((t) => t.specialType.equals('upcoming'))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc),
            ]))
          .watch();

  Stream<List<Transaction>> watchByWallet(int walletId) =>
      (_db.transactions.select()
            ..where(
              (t) =>
                  t.walletId.equals(walletId) |
                  t.transferWalletId.equals(walletId),
            )
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .watch();

  Future<Transaction?> getById(int id) =>
      (_db.transactions.select()..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> insert(TransactionsCompanion entry) =>
      _db.into(_db.transactions).insert(entry);

  Future<void> update(int id, TransactionsCompanion entry) =>
      (_db.transactions.update()..where((t) => t.id.equals(id))).write(entry);

  Future<void> delete(int id) async {
    final t = await getById(id);
    if (t != null) {
      await _db
          .into(_db.deleteLogs)
          .insert(
            DeleteLogsCompanion.insert(
              type: 'transaction',
              jsonData: jsonEncode({
                'type': t.type,
                'specialType': t.specialType,
                'amountMinor': t.amountMinor,
                'currencyCode': t.currencyCode,
                'date': t.date.toIso8601String(),
                'walletId': t.walletId,
                'transferWalletId': t.transferWalletId,
                'categoryId': t.categoryId,
                'title': t.title,
                'note': t.note,
                'tags': t.tags,
              }),
            ),
          );
    }
    await (_db.transactions.delete()..where((t) => t.id.equals(id))).go();
  }

  Future<List<Transaction>> search({
    DateTime? startDate,
    DateTime? endDate,
    int? walletId,
    int? categoryId,
    String? type,
    String? specialType,
    String? query,
    int? minAmount,
    int? maxAmount,
  }) async {
    final q = _db.transactions.select();
    if (startDate != null)
      q.where((t) => t.date.isBiggerOrEqualValue(startDate));
    if (endDate != null) q.where((t) => t.date.isSmallerOrEqualValue(endDate));
    if (walletId != null) {
      q.where(
        (t) =>
            t.walletId.equals(walletId) | t.transferWalletId.equals(walletId),
      );
    }
    if (categoryId != null) q.where((t) => t.categoryId.equals(categoryId));
    if (type != null) q.where((t) => t.type.equals(type));
    if (specialType != null) q.where((t) => t.specialType.equals(specialType));
    if (query != null && query.isNotEmpty) {
      q.where((t) => t.title.like('%$query%') | t.note.like('%$query%'));
    }
    if (minAmount != null) {
      q.where((t) => t.amountMinor.isBiggerOrEqualValue(minAmount));
    }
    if (maxAmount != null) {
      q.where((t) => t.amountMinor.isSmallerOrEqualValue(maxAmount));
    }
    q.orderBy([
      (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
    ]);
    return q.get();
  }

  Future<Map<int, int>> spentByCategory(DateTime start, DateTime end) async {
    final rows =
        await (_db.transactions.select()
              ..where(
                (t) =>
                    t.type.equals('expense') &
                    t.specialType.equals('none') &
                    t.date.isBiggerOrEqualValue(start) &
                    t.date.isSmallerOrEqualValue(end),
              )
              ..orderBy([]))
            .get();

    final map = <int, int>{};
    for (final t in rows) {
      if (t.categoryId != null) {
        map.update(
          t.categoryId!,
          (v) => v + t.amountMinor,
          ifAbsent: () => t.amountMinor,
        );
      }
    }
    return map;
  }

  Future<Map<int, int>> incomeByCategory(DateTime start, DateTime end) async {
    final rows =
        await (_db.transactions.select()
              ..where(
                (t) =>
                    t.type.equals('income') &
                    t.date.isBiggerOrEqualValue(start) &
                    t.date.isSmallerOrEqualValue(end),
              )
              ..orderBy([]))
            .get();

    final map = <int, int>{};
    for (final t in rows) {
      if (t.categoryId != null) {
        map.update(
          t.categoryId!,
          (v) => v + t.amountMinor,
          ifAbsent: () => t.amountMinor,
        );
      }
    }
    return map;
  }

  Future<int> totalIncome(DateTime start, DateTime end) async {
    final rows =
        await (_db.transactions.select()..where(
              (t) =>
                  t.type.equals('income') &
                  t.date.isBiggerOrEqualValue(start) &
                  t.date.isSmallerOrEqualValue(end),
            ))
            .get();
    var total = 0;
    for (final t in rows) {
      total += t.amountMinor;
    }
    return total;
  }

  Future<int> totalExpenses(DateTime start, DateTime end) async {
    final rows =
        await (_db.transactions.select()..where(
              (t) =>
                  t.type.equals('expense') &
                  t.specialType.equals('none') &
                  t.date.isBiggerOrEqualValue(start) &
                  t.date.isSmallerOrEqualValue(end),
            ))
            .get();
    var total = 0;
    for (final t in rows) {
      total += t.amountMinor;
    }
    return total;
  }

  Future<List<Transaction>> getByObjective(int objectiveId) =>
      (_db.transactions.select()
            ..where((t) => t.objectiveFk.equals(objectiveId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .get();
}

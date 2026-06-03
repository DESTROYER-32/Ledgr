import 'package:drift/drift.dart';

import '../app_database.dart';

class TransactionRepository {
  final AppDatabase _db;
  TransactionRepository(this._db);

  Stream<List<Transaction>> watchAll() => _db.transactions.select().watch();

  Stream<List<Transaction>> watchRecent({int limit = 10}) =>
      (_db.transactions.select()
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
            ])
            ..limit(limit))
          .watch();

  Stream<List<Transaction>> watchByWallet(int walletId) =>
      (_db.transactions.select()
            ..where((t) =>
                t.walletId.equals(walletId) |
                t.transferWalletId.equals(walletId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
            ]))
          .watch();

  Future<Transaction?> getById(int id) => (_db.transactions.select()
        ..where((t) => t.id.equals(id)))
      .getSingleOrNull();

  Future<void> insert(TransactionsCompanion entry) =>
      _db.into(_db.transactions).insert(entry);

  Future<void> update(int id, TransactionsCompanion entry) =>
      (_db.transactions.update()..where((t) => t.id.equals(id))).write(entry);

  Future<void> delete(int id) =>
      (_db.transactions.delete()..where((t) => t.id.equals(id))).go();

  Future<List<Transaction>> search({
    DateTime? startDate,
    DateTime? endDate,
    int? walletId,
    int? categoryId,
    String? type,
    String? query,
    int? minAmount,
    int? maxAmount,
  }) async {
    final q = _db.transactions.select();
    if (startDate != null) q.where((t) => t.date.isBiggerOrEqualValue(startDate));
    if (endDate != null) q.where((t) => t.date.isSmallerOrEqualValue(endDate));
    if (walletId != null) {
      q.where((t) =>
          t.walletId.equals(walletId) | t.transferWalletId.equals(walletId));
    }
    if (categoryId != null) q.where((t) => t.categoryId.equals(categoryId));
    if (type != null) q.where((t) => t.type.equals(type));
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
      (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
    ]);
    return q.get();
  }

  Future<Map<int, int>> spentByCategory(DateTime start, DateTime end) async {
    final rows = await (_db.transactions.select()
          ..where((t) =>
              t.type.equals('expense') &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([]))
        .get();

    final map = <int, int>{};
    for (final t in rows) {
      if (t.categoryId != null) {
        map.update(t.categoryId!, (v) => v + t.amountMinor,
            ifAbsent: () => t.amountMinor);
      }
    }
    return map;
  }

  Future<int> totalIncome(DateTime start, DateTime end) async {
    final rows = await (_db.transactions.select()
          ..where((t) =>
              t.type.equals('income') &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end)))
        .get();
    return rows.fold<int>(0, (sum, t) => sum + t.amountMinor);
  }

  Future<int> totalExpenses(DateTime start, DateTime end) async {
    final rows = await (_db.transactions.select()
          ..where((t) =>
              t.type.equals('expense') &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end)))
        .get();
    return rows.fold<int>(0, (sum, t) => sum + t.amountMinor);
  }
}

import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

class TransactionRepository {
  static const uncategorizedCategoryId = -1;

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

  Future<int> insert(TransactionsCompanion entry) =>
      _db.into(_db.transactions).insert(entry);

  Future<int> insertWithBudgets(
    TransactionsCompanion entry,
    Iterable<int> budgetIds,
  ) async {
    return _db.transaction(() async {
      final id = await insert(entry);
      await setTransactionBudgets(id, budgetIds);
      return id;
    });
  }

  Future<void> update(int id, TransactionsCompanion entry) =>
      (_db.transactions.update()..where((t) => t.id.equals(id))).write(
        entry.copyWith(updatedAt: Value(DateTime.now())),
      );

  Future<void> updateWithBudgets(
    int id,
    TransactionsCompanion entry,
    Iterable<int> budgetIds,
  ) async {
    await _db.transaction(() async {
      await update(id, entry);
      await setTransactionBudgets(id, budgetIds);
    });
  }

  Future<Set<int>> getBudgetIdsForTransaction(int transactionId) async {
    final rows =
        await (_db.transactionBudgets.select()
              ..where((tb) => tb.transactionId.equals(transactionId)))
            .get();
    return rows.map((row) => row.budgetId).toSet();
  }

  Future<void> setTransactionBudgets(
    int transactionId,
    Iterable<int> budgetIds,
  ) async {
    final uniqueIds = budgetIds.toSet();
    await (_db.transactionBudgets.delete()
          ..where((tb) => tb.transactionId.equals(transactionId)))
        .go();
    for (final budgetId in uniqueIds) {
      await _db
          .into(_db.transactionBudgets)
          .insert(
            TransactionBudgetsCompanion.insert(
              transactionId: transactionId,
              budgetId: budgetId,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<void> delete(int id) async {
    await _db.transaction(() async {
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
      await (_db.transactionBudgets.delete()
            ..where((tb) => tb.transactionId.equals(id)))
          .go();
      await (_db.transactions.delete()..where((t) => t.id.equals(id))).go();
    });
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
    if (startDate != null) {
      q.where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
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
      final pattern = _containsLikePattern(query);
      q.where(
        (t) =>
            t.title.like(pattern, escapeChar: '\\') |
            t.note.like(pattern, escapeChar: '\\'),
      );
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

  Future<List<Transaction>> searchByCategoriesPaged({
    required List<int> categoryIds,
    String? query,
    int limit = 30,
    int offset = 0,
  }) async {
    if (categoryIds.isEmpty) return [];
    final q = _db.transactions.select()
      ..where((t) => t.categoryId.isIn(categoryIds));
    final trimmed = query?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      final pattern = _containsLikePattern(trimmed);
      q.where(
        (t) =>
            t.title.like(pattern, escapeChar: '\\') |
            t.note.like(pattern, escapeChar: '\\'),
      );
    }
    q
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      ])
      ..limit(limit, offset: offset);
    return q.get();
  }

  Future<Map<int, int>> spentByCategory(DateTime start, DateTime end) async {
    return _sumByCategory(start, end, type: 'expense', specialType: 'none');
  }

  Future<Map<int, int>> incomeByCategory(DateTime start, DateTime end) async {
    return _sumByCategory(start, end, type: 'income');
  }

  Future<int> totalIncome(DateTime start, DateTime end) async {
    return _sumTotal(start, end, type: 'income');
  }

  Future<int> totalExpenses(DateTime start, DateTime end) async {
    return _sumTotal(start, end, type: 'expense', specialType: 'none');
  }

  Future<List<Transaction>> getByObjective(int objectiveId) =>
      (_db.transactions.select()
            ..where((t) => t.objectiveFk.equals(objectiveId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .get();

  Future<List<Transaction>> getByBudget({
    required int budgetId,
    required DateTime start,
    required DateTime end,
    required String type,
  }) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT t.*
          FROM transactions t
          INNER JOIN transaction_budgets tb ON tb.transaction_id = t.id
          WHERE tb.budget_id = ?
            AND t.date >= ?
            AND t.date <= ?
            AND t.type = ?
          ORDER BY t.date DESC
          ''',
          readsFrom: {_db.transactions, _db.transactionBudgets},
          variables: [
            Variable.withInt(budgetId),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
            Variable.withString(type),
          ],
        )
        .get();
    return rows.map((row) => _db.transactions.map(row.data)).toList();
  }

  Future<int> totalByBudget({
    required int budgetId,
    required DateTime start,
    required DateTime end,
    required String type,
  }) async {
    final row = await _db
        .customSelect(
          '''
          SELECT COALESCE(SUM(t.amount_minor), 0) AS total
          FROM transactions t
          INNER JOIN transaction_budgets tb ON tb.transaction_id = t.id
          WHERE tb.budget_id = ?
            AND t.date >= ?
            AND t.date <= ?
            AND t.type = ?
          ''',
          readsFrom: {_db.transactions, _db.transactionBudgets},
          variables: [
            Variable.withInt(budgetId),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
            Variable.withString(type),
          ],
        )
        .getSingle();
    return (row.data['total'] as num).toInt();
  }

  Future<int> totalByObjective(int objectiveId) async {
    final row = await _db
        .customSelect(
          '''
          SELECT COALESCE(SUM(amount_minor), 0) AS total
          FROM transactions
          WHERE objective_fk = ?
          ''',
          variables: [Variable.withInt(objectiveId)],
        )
        .getSingle();
    return (row.data['total'] as num).toInt();
  }

  Future<Map<int, int>> totalsByObjectives(Iterable<int> objectiveIds) async {
    final ids = objectiveIds.toSet().toList();
    if (ids.isEmpty) return {};
    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await _db.customSelect('''
          SELECT objective_fk, SUM(amount_minor) AS total
          FROM transactions
          WHERE objective_fk IN ($placeholders)
          GROUP BY objective_fk
          ''', variables: ids.map(Variable.withInt).toList()).get();
    return {
      for (final row in rows)
        row.data['objective_fk'] as int: (row.data['total'] as num).toInt(),
    };
  }

  String _containsLikePattern(String value) =>
      '%${value.replaceAll('\\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';

  Future<Map<int, int>> _sumByCategory(
    DateTime start,
    DateTime end, {
    required String type,
    String? specialType,
  }) async {
    final specialTypeFilter = specialType == null ? '' : 'AND special_type = ?';
    final variables = [
      Variable.withDateTime(start),
      Variable.withDateTime(end),
      Variable.withString(type),
      if (specialType != null) Variable.withString(specialType),
    ];
    final rows = await _db.customSelect('''
          SELECT category_id, SUM(amount_minor) AS total
          FROM transactions
          WHERE date >= ?
            AND date <= ?
            AND type = ?
            $specialTypeFilter
          GROUP BY category_id
          ''', variables: variables).get();
    return {
      for (final row in rows)
        (row.data['category_id'] as int?) ?? uncategorizedCategoryId:
            (row.data['total'] as num).toInt(),
    };
  }

  Future<int> _sumTotal(
    DateTime start,
    DateTime end, {
    required String type,
    String? specialType,
  }) async {
    final specialTypeFilter = specialType == null ? '' : 'AND special_type = ?';
    final variables = [
      Variable.withDateTime(start),
      Variable.withDateTime(end),
      Variable.withString(type),
      if (specialType != null) Variable.withString(specialType),
    ];
    final row = await _db.customSelect('''
          SELECT COALESCE(SUM(amount_minor), 0) AS total
          FROM transactions
          WHERE date >= ?
            AND date <= ?
            AND type = ?
            $specialTypeFilter
          ''', variables: variables).getSingle();
    return (row.data['total'] as num).toInt();
  }
}

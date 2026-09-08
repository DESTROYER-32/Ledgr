import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

class NetWorthSnapshotRepository {
  NetWorthSnapshotRepository(this._db);

  final AppDatabase _db;

  Stream<List<NetWorthSnapshot>> watchRecent({int limit = 36}) =>
      (_db.netWorthSnapshots.select()
            ..orderBy([
              (snapshot) => OrderingTerm(
                    expression: snapshot.date,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(limit))
          .watch()
          .map((rows) => rows.reversed.toList());

  Future<List<NetWorthSnapshot>> getRecent({int limit = 36}) async {
    final rows = await (_db.netWorthSnapshots.select()
          ..orderBy([
            (snapshot) => OrderingTerm(
                  expression: snapshot.date,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .get();
    return rows.reversed.toList();
  }

  Future<NetWorthSnapshot?> latestBefore(DateTime date) =>
      (_db.netWorthSnapshots.select()
            ..where((snapshot) => snapshot.date.isSmallerThanValue(date))
            ..orderBy([
              (snapshot) => OrderingTerm(
                    expression: snapshot.date,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsertForDay({
    required DateTime date,
    required int assetsMinor,
    required int liabilitiesMinor,
    required int netWorthMinor,
    required String currencyCode,
    required Map<String, Object?> details,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final existing = await (_db.netWorthSnapshots.select()
          ..where(
            (snapshot) =>
                snapshot.date.isBiggerOrEqualValue(start) &
                snapshot.date.isSmallerThanValue(end),
          )
          ..limit(1))
        .getSingleOrNull();

    final companion = NetWorthSnapshotsCompanion(
      date: Value(date),
      assetsMinor: Value(assetsMinor),
      liabilitiesMinor: Value(liabilitiesMinor),
      netWorthMinor: Value(netWorthMinor),
      currencyCode: Value(currencyCode),
      detailsJson: Value(jsonEncode(details)),
    );

    if (existing == null) {
      await _db.into(_db.netWorthSnapshots).insert(companion);
      return;
    }

    await (_db.netWorthSnapshots.update()
          ..where((snapshot) => snapshot.id.equals(existing.id)))
        .write(companion);
  }
}

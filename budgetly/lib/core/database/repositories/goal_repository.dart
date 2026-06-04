import 'package:drift/drift.dart';

import '../app_database.dart';

class GoalRepository {
  final AppDatabase _db;
  GoalRepository(this._db);

  Stream<List<Goal>> watchAll() => (_db.goals.select()
        ..where((g) => g.archived.equals(false))
        ..orderBy([(g) => OrderingTerm(expression: g.createdAt, mode: OrderingMode.desc)]))
      .watch();

  Future<Goal?> getById(int id) => (_db.goals.select()
        ..where((g) => g.id.equals(id)))
      .getSingleOrNull();

  Future<int> insert(GoalsCompanion entry) =>
      _db.into(_db.goals).insert(entry);

  Future<void> update(int id, GoalsCompanion entry) =>
      (_db.goals.update()..where((g) => g.id.equals(id))).write(entry);

  Future<void> archive(int id) =>
      (_db.goals.update()..where((g) => g.id.equals(id))).write(
        const GoalsCompanion(archived: Value(true)),
      );

  Future<void> delete(int id) =>
      (_db.goals.delete()..where((g) => g.id.equals(id))).go();
}

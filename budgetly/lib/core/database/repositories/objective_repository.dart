import 'package:drift/drift.dart';

import '../app_database.dart';

class ObjectiveRepository {
  final AppDatabase _db;
  ObjectiveRepository(this._db);

  Stream<List<Objective>> watchAll() => (_db.objectives.select()
        ..where((o) => o.archived.equals(false))
        ..orderBy([(o) => OrderingTerm(expression: o.sortOrder)]))
      .watch();

  Stream<List<Objective>> watchPinned() => (_db.objectives.select()
        ..where((o) => o.pinned.equals(true) & o.archived.equals(false))
        ..orderBy([(o) => OrderingTerm(expression: o.sortOrder)]))
      .watch();

  Stream<List<Objective>> watchByType(String type) =>
      (_db.objectives.select()
            ..where((o) =>
                o.type.equals(type) & o.archived.equals(false))
            ..orderBy([(o) => OrderingTerm(expression: o.sortOrder)]))
          .watch();

  Future<Objective?> getById(int id) => (_db.objectives.select()
        ..where((o) => o.id.equals(id)))
      .getSingleOrNull();

  Future<int> insert(ObjectivesCompanion entry) =>
      _db.into(_db.objectives).insert(entry);

  Future<void> update(int id, ObjectivesCompanion entry) =>
      (_db.objectives.update()..where((o) => o.id.equals(id))).write(entry);

  Future<void> archive(int id) =>
      (_db.objectives.update()..where((o) => o.id.equals(id))).write(
        const ObjectivesCompanion(archived: Value(true)),
      );

  Future<void> delete(int id) =>
      (_db.objectives.delete()..where((o) => o.id.equals(id))).go();
}

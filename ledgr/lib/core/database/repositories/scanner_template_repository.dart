import 'package:drift/drift.dart';

import '../app_database.dart';

class ScannerTemplateRepository {
  final AppDatabase _db;
  ScannerTemplateRepository(this._db);

  Stream<List<ScannerTemplate>> watchAll() =>
      _db.scannerTemplates.select().watch();

  Future<ScannerTemplate?> getById(int id) => (_db.scannerTemplates.select()
        ..where((s) => s.id.equals(id)))
      .getSingleOrNull();

  Future<int> insert(ScannerTemplatesCompanion entry) =>
      _db.into(_db.scannerTemplates).insert(entry);

  Future<void> update(int id, ScannerTemplatesCompanion entry) =>
      (_db.scannerTemplates.update()..where((s) => s.id.equals(id)))
          .write(entry);

  Future<void> delete(int id) =>
      (_db.scannerTemplates.delete()..where((s) => s.id.equals(id))).go();
}

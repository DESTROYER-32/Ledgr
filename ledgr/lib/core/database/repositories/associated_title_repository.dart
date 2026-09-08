import 'package:drift/drift.dart';

import '../app_database.dart';

class AssociatedTitleRepository {
  final AppDatabase _db;
  AssociatedTitleRepository(this._db);

  Stream<List<AssociatedTitle>> watchAll() =>
      _db.associatedTitles.select().watch();

  Future<AssociatedTitle?> getById(int id) =>
      (_db.associatedTitles.select()..where((a) => a.id.equals(id)))
          .getSingleOrNull();

  Future<int?> findCategoryIdForTitle(String title) async {
    final all = await _db.associatedTitles.select().get();
    for (final a in all) {
      if (a.exactMatch) {
        if (a.title == title) return a.categoryId;
      } else {
        if (title.toLowerCase().contains(a.title.toLowerCase())) {
          return a.categoryId;
        }
      }
    }
    return null;
  }

  Future<int> insert(AssociatedTitlesCompanion entry) =>
      _db.into(_db.associatedTitles).insert(entry);

  Future<void> update(int id, AssociatedTitlesCompanion entry) =>
      (_db.associatedTitles.update()..where((a) => a.id.equals(id)))
          .write(entry);

  Future<void> delete(int id) =>
      (_db.associatedTitles.delete()..where((a) => a.id.equals(id))).go();
}

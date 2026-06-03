import 'package:drift/drift.dart';

import '../app_database.dart';

class RecurringRepository {
  final AppDatabase _db;
  RecurringRepository(this._db);

  Stream<List<RecurringTransaction>> watchAll() =>
      _db.recurringTransactions.select().watch();

  Stream<List<RecurringTransaction>> watchActive() =>
      (_db.recurringTransactions.select()
            ..where((r) => r.active.equals(true))
            ..orderBy([(r) => OrderingTerm(expression: r.nextDueDate)]))
          .watch();

  Future<RecurringTransaction?> getById(int id) =>
      (_db.recurringTransactions.select()
            ..where((r) => r.id.equals(id)))
          .getSingleOrNull();

  Future<void> insert(RecurringTransactionsCompanion entry) =>
      _db.into(_db.recurringTransactions).insert(entry);

  Future<void> update(int id, RecurringTransactionsCompanion entry) =>
      (_db.recurringTransactions.update()
            ..where((r) => r.id.equals(id)))
          .write(entry);

  Future<void> delete(int id) =>
      (_db.recurringTransactions.delete()
            ..where((r) => r.id.equals(id)))
          .go();
}

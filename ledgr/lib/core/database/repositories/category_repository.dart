import 'package:drift/drift.dart';

import '../app_database.dart';

class CategoryRepository {
  final AppDatabase _db;
  CategoryRepository(this._db);

  Stream<List<Category>> watchAll() => _db.categories.select().watch();

  Stream<List<Category>> watchActive() => (_db.categories.select()
        ..where((c) => c.archived.equals(false))
        ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
      .watch();

  Stream<List<Category>> watchByKind(String kind) =>
      (_db.categories.select()
            ..where((c) =>
                c.archived.equals(false) & c.kind.isIn([kind, 'both']))
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .watch();

  Future<Category?> getById(int id) => (_db.categories.select()
        ..where((c) => c.id.equals(id)))
      .getSingleOrNull();

  Future<void> insert(CategoriesCompanion entry) =>
      _db.into(_db.categories).insert(entry);

  Future<void> update(int id, CategoriesCompanion entry) =>
      (_db.categories.update()..where((c) => c.id.equals(id))).write(entry);

  Future<void> archive(int id) =>
      (_db.categories.update()..where((c) => c.id.equals(id))).write(
        const CategoriesCompanion(archived: Value(true)),
      );

  Future<void> delete(int id) =>
      (_db.categories.delete()..where((c) => c.id.equals(id))).go();

  Future<void> seedDefaults() async {
    final count = await _db.categories.select().get().then((l) => l.length);
    if (count > 0) return;

    final defaults = [
      (name: 'Salary', icon: 'work', kind: 'income', color: 0xFF43A047),
      (name: 'Freelance', icon: 'code', kind: 'income', color: 0xFF00ACC1),
      (name: 'Investments', icon: 'trending_up', kind: 'income', color: 0xFF1E88E5),
      (name: 'Groceries', icon: 'shopping_cart', kind: 'expense', color: 0xFFE53935),
      (name: 'Rent', icon: 'home', kind: 'expense', color: 0xFFFF8F00),
      (name: 'Utilities', icon: 'bolt', kind: 'expense', color: 0xFFFDD835),
      (name: 'Transport', icon: 'directions_car', kind: 'expense', color: 0xFFFF7043),
      (name: 'Dining Out', icon: 'restaurant', kind: 'expense', color: 0xFFD81B60),
      (name: 'Shopping', icon: 'shopping_bag', kind: 'expense', color: 0xFF5E35B1),
      (name: 'Entertainment', icon: 'movie', kind: 'expense', color: 0xFF8BC34A),
      (name: 'Health', icon: 'local_hospital', kind: 'expense', color: 0xFFE53935),
      (name: 'Subscriptions', icon: 'subscriptions', kind: 'expense', color: 0xFF546E7A),
      (name: 'Insurance', icon: 'security', kind: 'expense', color: 0xFF6D4C41),
      (name: 'Education', icon: 'school', kind: 'expense', color: 0xFF00ACC1),
      (name: 'Gifts', icon: 'card_giftcard', kind: 'expense', color: 0xFFD81B60),
      (name: 'Other Income', icon: 'attach_money', kind: 'income', color: 0xFF43A047),
      (name: 'Other Expense', icon: 'money_off', kind: 'expense', color: 0xFFE53935),
    ];

    for (var i = 0; i < defaults.length; i++) {
      await _db.into(_db.categories).insert(CategoriesCompanion.insert(
        name: defaults[i].name,
        icon: Value(defaults[i].icon),
        color: Value(defaults[i].color),
        kind: defaults[i].kind,
        sortOrder: Value(i),
      ));
    }
  }
}

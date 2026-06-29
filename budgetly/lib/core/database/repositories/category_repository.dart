import 'package:drift/drift.dart';

import '../app_database.dart';

class CategoryRepository {
  final AppDatabase _db;
  CategoryRepository(this._db);

  Stream<List<Category>> watchAll() => _db.categories.select().watch();

  Stream<List<Category>> watchActive() =>
      (_db.categories.select()
            ..where((c) => c.archived.equals(false))
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .watch();

  Future<List<Category>> getActive() =>
      (_db.categories.select()
            ..where((c) => c.archived.equals(false))
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .get();

  Stream<List<Category>> watchParents() =>
      (_db.categories.select()
            ..where((c) => c.archived.equals(false) & c.mainCategoryPk.isNull())
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .watch();

  Stream<List<Category>> watchSubcategories(int parentId) =>
      (_db.categories.select()
            ..where(
              (c) =>
                  c.archived.equals(false) & c.mainCategoryPk.equals(parentId),
            )
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .watch();

  Stream<List<Category>> watchByKind(String kind) =>
      (_db.categories.select()
            ..where(
              (c) => c.archived.equals(false) & c.kind.isIn([kind, 'both']),
            )
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .watch();

  Future<Category?> getById(int id) =>
      (_db.categories.select()..where((c) => c.id.equals(id)))
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
      (
        name: 'Salary',
        icon: 'work',
        kind: 'income',
        color: 0xFF43A047,
        parent: null,
      ),
      (
        name: 'Freelance',
        icon: 'code',
        kind: 'income',
        color: 0xFF00ACC1,
        parent: null,
      ),
      (
        name: 'Investments',
        icon: 'trending_up',
        kind: 'income',
        color: 0xFF1E88E5,
        parent: null,
      ),
      (
        name: 'Groceries',
        icon: 'shopping_cart',
        kind: 'expense',
        color: 0xFFE53935,
        parent: null,
      ),
      (
        name: 'Rent',
        icon: 'home',
        kind: 'expense',
        color: 0xFFFF8F00,
        parent: null,
      ),
      (
        name: 'Utilities',
        icon: 'bolt',
        kind: 'expense',
        color: 0xFFFDD835,
        parent: null,
      ),
      (
        name: 'Transport',
        icon: 'directions_car',
        kind: 'expense',
        color: 0xFFFF7043,
        parent: null,
      ),
      (
        name: 'Dining Out',
        icon: 'restaurant',
        kind: 'expense',
        color: 0xFFD81B60,
        parent: null,
      ),
      (
        name: 'Shopping',
        icon: 'shopping_bag',
        kind: 'expense',
        color: 0xFF5E35B1,
        parent: null,
      ),
      (
        name: 'Entertainment',
        icon: 'movie',
        kind: 'expense',
        color: 0xFF8BC34A,
        parent: null,
      ),
      (
        name: 'Health',
        icon: 'local_hospital',
        kind: 'expense',
        color: 0xFFE53935,
        parent: null,
      ),
      (
        name: 'Subscriptions',
        icon: 'subscriptions',
        kind: 'expense',
        color: 0xFF546E7A,
        parent: null,
      ),
      (
        name: 'Insurance',
        icon: 'security',
        kind: 'expense',
        color: 0xFF6D4C41,
        parent: null,
      ),
      (
        name: 'Education',
        icon: 'school',
        kind: 'expense',
        color: 0xFF00ACC1,
        parent: null,
      ),
      (
        name: 'Gifts',
        icon: 'card_giftcard',
        kind: 'expense',
        color: 0xFFD81B60,
        parent: null,
      ),
      (
        name: 'Other Income',
        icon: 'attach_money',
        kind: 'income',
        color: 0xFF43A047,
        parent: null,
      ),
      (
        name: 'Other Expense',
        icon: 'money_off',
        kind: 'expense',
        color: 0xFFE53935,
        parent: null,
      ),
    ];

    for (var i = 0; i < defaults.length; i++) {
      await _db
          .into(_db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: defaults[i].name,
              icon: Value(defaults[i].icon),
              color: Value(defaults[i].color),
              kind: defaults[i].kind,
              sortOrder: Value(i),
            ),
          );
    }
  }
}

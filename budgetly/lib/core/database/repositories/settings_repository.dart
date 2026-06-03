import 'package:drift/drift.dart';

import '../app_database.dart';

class SettingsRepository {
  final AppDatabase _db;
  SettingsRepository(this._db);

  Future<String?> get(String key) async {
    final row = await (_db.settings.select()
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    final existing = await (_db.settings.select()
          ..where((s) => s.key.equals(key)))
        .get();
    if (existing.isNotEmpty) {
      await (_db.settings.update()..where((s) => s.key.equals(key)))
          .write(SettingsCompanion(value: Value(value)));
    } else {
      await _db.into(_db.settings).insert(
            SettingsCompanion.insert(key: key, value: value),
          );
    }
  }

  Future<void> remove(String key) async {
    await (_db.settings.delete()..where((s) => s.key.equals(key))).go();
  }

  Future<bool> isOnboardingComplete() async {
    final val = await get('onboarding_complete');
    return val == 'true';
  }

  Future<void> completeOnboarding() =>
      set('onboarding_complete', 'true');
}

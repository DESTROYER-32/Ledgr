import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ledgr/core/database/app_database.dart';
import 'package:ledgr/core/database/repositories/settings_repository.dart';
import 'package:ledgr/core/providers/providers.dart';

void main() {
  test(
    'themeConfigProvider falls back when persisted theme seed is invalid',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(db.close);
            return db;
          }),
        ],
      );
      addTearDown(container.dispose);

      await SettingsRepository(db).set('theme_seed', 'not-an-int');

      final config = await container.read(themeConfigProvider.future);

      expect(config.seedColor, const Color(0xFF1A6D4A));
    },
  );
}

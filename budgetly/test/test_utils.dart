import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budgetly/core/database/app_database.dart';
import 'package:budgetly/core/providers/providers.dart';

ProviderScope testProviderScope({required Widget child}) {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        ref.onDispose(db.close);
        return db;
      }),
    ],
    child: child,
  );
}

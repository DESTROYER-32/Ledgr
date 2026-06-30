import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:budgetly/core/database/app_database.dart';
import 'package:budgetly/core/providers/providers.dart';
import 'package:budgetly/main.dart';

void main() {
  testWidgets('App renders dashboard', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(db.close);
            return db;
          }),
        ],
        child: const BudgetlyApp(initialRoute: '/'),
      ),
    );
    await tester.pump();
    expect(find.text('Budgetly'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

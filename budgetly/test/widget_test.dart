import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: BudgetlyApp(initialRoute: '/', database: db),
      ),
    );
    await tester.pump();
    expect(find.text('Budgetly'), findsOneWidget);
  });
}

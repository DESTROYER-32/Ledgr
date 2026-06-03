import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budgetly/main.dart';

void main() {
  testWidgets('App renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: BudgetlyApp(initialRoute: '/'),
    ));
    await tester.pump();
    expect(find.text('Budgetly'), findsOneWidget);
  });
}

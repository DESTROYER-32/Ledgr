import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ledgr/features/budgets/budgets_screen.dart';

void main() {
  testWidgets('Budget screen renders month navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: BudgetsScreen())),
    );
    await tester.pump();

    // Should show current month and year
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    expect(find.text('${months[now.month - 1]} ${now.year}'), findsOneWidget);
  });
}

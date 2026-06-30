import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budgetly/features/transactions/transaction_form_screen.dart';
import '../test_utils.dart';

void main() {
  testWidgets('Transaction form renders type segments', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testProviderScope(
        child: const MaterialApp(home: TransactionFormScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Expense'), findsWidgets);
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Transfer'), findsWidgets);
    expect(find.text('New Transaction'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('Transaction form shows amount field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testProviderScope(
        child: const MaterialApp(home: TransactionFormScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Title / Payee'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

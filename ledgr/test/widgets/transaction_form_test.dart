import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budgetly/features/transactions/transaction_form_screen.dart';

void main() {
  testWidgets('Transaction form renders type segments',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TransactionFormScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Expense'), findsWidgets);
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Transfer'), findsWidgets);
    expect(find.text('Add Transaction'), findsOneWidget);
  });

  testWidgets('Transaction form shows amount field',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TransactionFormScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Title / Payee'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
  });
}

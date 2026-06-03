import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budgetly/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding shows welcome step', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Budgetly'), findsOneWidget);
    expect(find.text('Select your currency'), findsOneWidget);
    expect(find.text('USD'), findsWidgets);
  });

  testWidgets('Onboarding navigates to wallet step on next',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Create your first account'), findsOneWidget);
    expect(find.text('Account name'), findsOneWidget);
  });
}

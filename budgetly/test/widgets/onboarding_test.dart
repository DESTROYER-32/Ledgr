import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budgetly/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding shows richer welcome step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Budgetly'), findsOneWidget);
    expect(find.text('Private by default'), findsOneWidget);
    expect(find.text('1/10'), findsOneWidget);
  });

  testWidgets('Onboarding asks for an optional name before currency', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen())),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('What should we call you?'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Pick your currency'), findsOneWidget);
  });

  testWidgets('Onboarding navigates to wallet step with next', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen())),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 7; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Create your first account'), findsOneWidget);
    expect(find.text('Account name'), findsOneWidget);
    expect(find.text('Create a starter account now'), findsOneWidget);
  });

  testWidgets('Wallet onboarding step can be skipped independently', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen())),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 7; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Try test mode first'), findsOneWidget);
  });
}

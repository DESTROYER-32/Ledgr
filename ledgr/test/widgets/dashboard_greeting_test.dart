import 'package:flutter_test/flutter_test.dart';

import 'package:budgetly/features/dashboard/dashboard_screen.dart';

void main() {
  group('dashboardGreeting', () {
    test('falls back to app name without a saved name', () {
      expect(dashboardGreeting(name: null), 'Budgetly');
      expect(dashboardGreeting(name: '   '), 'Budgetly');
    });

    test('greets by morning, afternoon, and evening', () {
      expect(
        dashboardGreeting(name: 'Alex', now: DateTime(2026, 6, 24, 5)),
        'Good morning, Alex',
      );
      expect(
        dashboardGreeting(name: 'Alex', now: DateTime(2026, 6, 24, 12)),
        'Good afternoon, Alex',
      );
      expect(
        dashboardGreeting(name: 'Alex', now: DateTime(2026, 6, 24, 17)),
        'Good evening, Alex',
      );
      expect(
        dashboardGreeting(name: ' Alex ', now: DateTime(2026, 6, 24, 4)),
        'Good evening, Alex',
      );
    });
  });
}

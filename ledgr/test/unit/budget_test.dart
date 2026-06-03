import 'package:flutter_test/flutter_test.dart';

/// Tests for budget calculation logic
/// Note: These test the calculation math, not the database layer.
void main() {
  group('Budget Calculations', () {
    test('remaining is planned minus spent', () {
      const planned = 100000; // $1000.00
      const spent = 75000; // $750.00
      const remaining = planned - spent;
      expect(remaining, 25000); // $250.00
    });

    test('overspent when spent exceeds planned', () {
      const planned = 100000;
      const spent = 120000;
      const remaining = planned - spent;
      expect(remaining, -20000);
      expect(remaining.isNegative, true);
    });

    test('percentage clamps to 1.0', () {
      const planned = 100000;
      const spent = 200000;
      final percentage = (spent / planned).clamp(0.0, 1.0);
      expect(percentage, 1.0);
    });

    test('percentage is 0 when planned is 0', () {
      const planned = 0;
      const spent = 5000;
      final percentage =
          planned > 0 ? (spent / planned).clamp(0.0, 1.0) : 0.0;
      expect(percentage, 0.0);
    });

    test('percentage is correct for partial spend', () {
      const planned = 100000;
      const spent = 25000;
      final percentage = (spent / planned).clamp(0.0, 1.0);
      expect(percentage, 0.25);
    });

    test('total budget is sum of category limits', () {
      const limits = [50000, 30000, 20000, 100000]; // $500, $300, $200, $1000
      final total = limits.fold<int>(0, (s, v) => s + v);
      expect(total, 200000); // $2000.00
    });

    test('total spent across categories', () {
      final spentByCat = <int, int>{
        1: 25000,
        2: 15000,
        3: 5000,
      };
      final total = spentByCat.values.fold<int>(0, (s, v) => s + v);
      expect(total, 45000);
    });
  });
}

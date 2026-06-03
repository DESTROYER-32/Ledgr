import 'package:flutter_test/flutter_test.dart';
import 'package:budgetly/core/utils/money_utils.dart';

void main() {
  group('MoneyUtils', () {
    test('format formats cents as dollars', () {
      expect(MoneyUtils.format(100), contains('1.00'));
      expect(MoneyUtils.format(999), contains('9.99'));
      expect(MoneyUtils.format(0), contains('0.00'));
    });

    test('format handles negative amounts', () {
      expect(MoneyUtils.format(-500), startsWith('-'));
      expect(MoneyUtils.format(-500), contains('5.00'));
    });

    test('format with currency code', () {
      final result = MoneyUtils.format(2500, currencyCode: 'EUR');
      expect(result, contains('25.00'));
    });

    test('formatCompact shows K for thousands', () {
      expect(MoneyUtils.formatCompact(100000), contains('1.0K'));
      expect(MoneyUtils.formatCompact(250000), contains('2.5K'));
    });

    test('formatCompact shows M for millions', () {
      expect(MoneyUtils.formatCompact(150000000), contains('1.5M'));
    });

    test('toMinor converts dollars to cents', () {
      expect(MoneyUtils.toMinor(10.50), 1050);
      expect(MoneyUtils.toMinor(0.99), 99);
      expect(MoneyUtils.toMinor(0), 0);
    });

    test('toMajor converts cents to dollars', () {
      expect(MoneyUtils.toMajor(1050), 10.50);
      expect(MoneyUtils.toMajor(99), 0.99);
      expect(MoneyUtils.toMajor(0), 0.0);
    });

    test('formatDate formats date correctly', () {
      final date = DateTime(2024, 3, 15);
      final formatted = MoneyUtils.formatDate(date);
      expect(formatted, contains('Mar'));
      expect(formatted, contains('15'));
      expect(formatted, contains('2024'));
    });

    test('formatDateShort formats short date', () {
      final date = DateTime(2024, 3, 15);
      final formatted = MoneyUtils.formatDateShort(date);
      expect(formatted, contains('Mar'));
      expect(formatted, contains('15'));
    });
  });

  group('AppDateUtils', () {
    test('monthStart returns first of month', () {
      final result = AppDateUtils.monthStart(DateTime(2024, 6, 15));
      expect(result.year, 2024);
      expect(result.month, 6);
      expect(result.day, 1);
    });

    test('monthEnd returns last of month', () {
      final result = AppDateUtils.monthEnd(DateTime(2024, 6, 15));
      expect(result.year, 2024);
      expect(result.month, 6);
      expect(result.day, 30);
    });

    test('previousMonth returns previous month', () {
      final result = AppDateUtils.previousMonth(DateTime(2024, 6, 15));
      expect(result.year, 2024);
      expect(result.month, 5);
      expect(result.day, 1);
    });

    test('previousMonth handles January', () {
      final result = AppDateUtils.previousMonth(DateTime(2024, 1, 15));
      expect(result.year, 2023);
      expect(result.month, 12);
    });

    test('nextMonth returns next month', () {
      final result = AppDateUtils.nextMonth(DateTime(2024, 6, 15));
      expect(result.year, 2024);
      expect(result.month, 7);
      expect(result.day, 1);
    });

    test('nextMonth handles December', () {
      final result = AppDateUtils.nextMonth(DateTime(2024, 12, 15));
      expect(result.year, 2025);
      expect(result.month, 1);
    });
  });
}

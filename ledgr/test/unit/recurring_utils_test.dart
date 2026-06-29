import 'package:flutter_test/flutter_test.dart';
import 'package:budgetly/core/utils/recurring_utils.dart';

void main() {
  group('RecurringUtils', () {
    final baseDate = DateTime(2024, 6, 15);

    test('computeNextDueDate daily', () {
      final next = RecurringUtils.computeNextDueDate('daily', baseDate);
      expect(next.year, 2024);
      expect(next.month, 6);
      expect(next.day, 16);
    });

    test('computeNextDueDate weekly', () {
      final next = RecurringUtils.computeNextDueDate('weekly', baseDate);
      expect(next.year, 2024);
      expect(next.month, 6);
      expect(next.day, 22);
    });

    test('computeNextDueDate monthly', () {
      final next = RecurringUtils.computeNextDueDate('monthly', baseDate);
      expect(next.year, 2024);
      expect(next.month, 7);
      expect(next.day, 15);
    });

    test('computeNextDueDate monthly clamps to last valid day', () {
      final next = RecurringUtils.computeNextDueDate(
        'monthly',
        DateTime(2024, 1, 31),
      );
      expect(next, DateTime(2024, 2, 29));

      final nonLeap = RecurringUtils.computeNextDueDate(
        'monthly',
        DateTime(2023, 1, 31),
      );
      expect(nonLeap, DateTime(2023, 2, 28));
    });

    test('computeNextDueDate yearly', () {
      final next = RecurringUtils.computeNextDueDate('yearly', baseDate);
      expect(next.year, 2025);
      expect(next.month, 6);
      expect(next.day, 15);
    });

    test('generateInstances daily returns correct count', () {
      final instances = RecurringUtils.generateInstances(
        'daily',
        baseDate,
        null,
        5,
      );
      expect(instances.length, 5);
      expect(instances[0], baseDate);
      expect(instances[1].day, 16);
      expect(instances[4].day, 19);
    });

    test('generateInstances respects end date', () {
      final end = DateTime(2024, 6, 18);
      final instances = RecurringUtils.generateInstances(
        'daily',
        baseDate,
        end,
        10,
      );
      expect(instances.length, 4); // 15, 16, 17, 18
    });

    test('generateInstances monthly with end date', () {
      final end = DateTime(2024, 9, 1);
      final instances = RecurringUtils.generateInstances(
        'monthly',
        baseDate,
        end,
        10,
      );
      expect(instances.length, 3); // Jun 15, Jul 15, Aug 15
    });

    test('describeSchedule returns human-readable labels', () {
      expect(RecurringUtils.describeSchedule('daily'), 'Every day');
      expect(RecurringUtils.describeSchedule('weekly'), 'Every week');
      expect(RecurringUtils.describeSchedule('monthly'), 'Every month');
      expect(RecurringUtils.describeSchedule('yearly'), 'Every year');
      expect(RecurringUtils.describeSchedule('custom'), 'custom');
    });

    test('generateInstances returns empty for maxCount = 0', () {
      final instances = RecurringUtils.generateInstances(
        'daily',
        baseDate,
        null,
        0,
      );
      expect(instances, isEmpty);
    });

    test('generateInstances stops when rule does not advance date', () {
      final instances = RecurringUtils.generateInstances(
        'unknown-rule',
        baseDate,
        null,
        10,
      );
      expect(instances, [baseDate]);
    });
  });
}

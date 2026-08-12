class RecurringUtils {
  RecurringUtils._();

  static final _everyMonthsPattern = RegExp(
    r'^every_months:(\d+)(?::until:([0-9]{4}-[0-9]{2}-[0-9]{2}))?$',
  );

  static DateTime computeNextDueDate(String rule, DateTime fromDate) {
    final monthInterval = monthIntervalForRule(rule);
    if (monthInterval != null) {
      return _addMonthsClamped(fromDate, monthInterval);
    }

    switch (rule) {
      case 'daily':
        return DateTime(fromDate.year, fromDate.month, fromDate.day + 1);
      case 'weekly':
        return DateTime(fromDate.year, fromDate.month, fromDate.day + 7);
      default:
        return fromDate;
    }
  }

  static List<DateTime> generateInstances(
    String rule,
    DateTime start,
    DateTime? end,
    int maxCount,
  ) {
    final until = untilDateForRule(rule);
    final effectiveEnd = _earliest(end, until);
    final instances = <DateTime>[];
    var current = start;
    while (instances.length < maxCount) {
      if (effectiveEnd != null && current.isAfter(effectiveEnd)) break;
      instances.add(current);
      final next = computeNextDueDate(rule, current);
      if (!next.isAfter(current)) break;
      current = next;
    }
    return instances;
  }

  static bool isSupportedRule(String rule) =>
      rule == 'daily' || rule == 'weekly' || monthIntervalForRule(rule) != null;

  static int? monthIntervalForRule(String rule) {
    switch (rule) {
      case 'monthly':
        return 1;
      case 'quarterly':
        return 3;
      case 'yearly':
        return 12;
    }
    final match = _everyMonthsPattern.firstMatch(rule);
    if (match == null) return null;
    final interval = int.tryParse(match.group(1) ?? '');
    if (interval == null || interval < 1) return null;
    return interval;
  }

  static DateTime? untilDateForRule(String rule) {
    final match = _everyMonthsPattern.firstMatch(rule);
    final raw = match?.group(2);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static String buildEveryMonthsRule(int interval, {DateTime? until}) {
    final safeInterval = interval < 1 ? 1 : interval;
    if (until == null) return 'every_months:$safeInterval';
    return 'every_months:$safeInterval:until:${_dateOnly(until)}';
  }

  static String describeSchedule(String rule) {
    switch (rule) {
      case 'daily':
        return 'Every day';
      case 'weekly':
        return 'Every week';
      case 'monthly':
        return 'Every month';
      case 'quarterly':
        return 'Every 3 months';
      case 'yearly':
        return 'Every year';
      default:
        final months = monthIntervalForRule(rule);
        if (months != null) {
          final until = untilDateForRule(rule);
          final label = months == 1 ? 'Every month' : 'Every $months months';
          return until == null ? label : '$label until ${_dateOnly(until)}';
        }
        return rule;
    }
  }

  static DateTime? _earliest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DateTime _addMonthsClamped(DateTime date, int months) {
    final totalMonths = date.year * 12 + (date.month - 1) + months;
    final targetYear = totalMonths ~/ 12;
    final targetMonth = totalMonths % 12 + 1;
    final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
    return DateTime(
      targetYear,
      targetMonth,
      date.day > lastDay ? lastDay : date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
}

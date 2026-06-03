class RecurringUtils {
  RecurringUtils._();

  static DateTime computeNextDueDate(
      String rule, DateTime fromDate) {
    switch (rule) {
      case 'daily':
        return DateTime(fromDate.year, fromDate.month, fromDate.day + 1);
      case 'weekly':
        return DateTime(fromDate.year, fromDate.month, fromDate.day + 7);
      case 'monthly':
        return DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
      case 'yearly':
        return DateTime(fromDate.year + 1, fromDate.month, fromDate.day);
      default:
        return fromDate;
    }
  }

  static List<DateTime> generateInstances(
      String rule, DateTime start, DateTime? end, int maxCount) {
    final instances = <DateTime>[];
    var current = start;
    while (instances.length < maxCount) {
      if (end != null && current.isAfter(end)) break;
      instances.add(current);
      current = computeNextDueDate(rule, current);
    }
    return instances;
  }

  static String describeSchedule(String rule) {
    switch (rule) {
      case 'daily':
        return 'Every day';
      case 'weekly':
        return 'Every week';
      case 'monthly':
        return 'Every month';
      case 'yearly':
        return 'Every year';
      default:
        return rule;
    }
  }
}

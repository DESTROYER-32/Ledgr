import 'package:intl/intl.dart';

class MoneyUtils {
  MoneyUtils._();

  static String format(int amountMinor, {String? currencyCode}) {
    final amount = amountMinor / 100;
    final format = NumberFormat.currency(
      symbol: currencyCode ?? '',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  static String formatCompact(int amountMinor, {String? currencyCode}) {
    final amount = amountMinor / 100;
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amountMinor, currencyCode: currencyCode);
  }

  static int toMinor(double amount) => (amount * 100).round();

  static double toMajor(int minor) => minor / 100;

  static String formatDate(DateTime date) => AppDateUtils.formatDate(date);

  static String formatDateShort(DateTime date) => AppDateUtils.formatDateShort(date);
}

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat.MMMd().format(date);
  }

  static DateTime monthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime monthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static DateTime previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1, 1);
  }

  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }
}

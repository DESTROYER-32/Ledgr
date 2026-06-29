import 'dart:math' as math;

import 'package:intl/intl.dart';

class MoneyUtils {
  MoneyUtils._();

  static const String defaultCurrencyCode = 'USD';

  static String format(
    int amountMinor, {
    String? currencyCode,
    String? locale,
  }) {
    final code = currencyCode ?? defaultCurrencyCode;
    final digits = decimalDigitsFor(code);
    final amount = amountMinor / math.pow(10, digits);
    try {
      final format = NumberFormat.simpleCurrency(
        locale: locale,
        name: code,
        decimalDigits: digits,
      );
      return format.format(amount);
    } catch (_) {
      return '$code ${amount.toStringAsFixed(digits)}';
    }
  }

  static String formatCompact(
    int amountMinor, {
    String? currencyCode,
    String? locale,
  }) {
    final code = currencyCode ?? defaultCurrencyCode;
    final digits = decimalDigitsFor(code);
    final amount = amountMinor / math.pow(10, digits);
    return NumberFormat.compactSimpleCurrency(
      locale: locale,
      name: code,
    ).format(amount);
  }

  static int decimalDigitsFor(String code) {
    try {
      return NumberFormat.simpleCurrency(name: code).decimalDigits ?? 2;
    } catch (_) {
      return 2;
    }
  }

  static int convertMinor(
    int amountMinor, {
    required String fromCurrency,
    required String toCurrency,
    required Map<String, double> rates,
  }) {
    if (fromCurrency.toLowerCase() == toCurrency.toLowerCase()) {
      return amountMinor;
    }
    final fromRate =
        rates[fromCurrency.toLowerCase()] ??
        (fromCurrency.toLowerCase() == 'usd' ? 1.0 : null);
    final toRate =
        rates[toCurrency.toLowerCase()] ??
        (toCurrency.toLowerCase() == 'usd' ? 1.0 : null);
    if (fromRate == null || toRate == null || fromRate == 0) {
      return amountMinor;
    }
    return (amountMinor * toRate * (1 / fromRate)).round();
  }

  static int toMinor(double amount, {String? currencyCode}) {
    final digits = decimalDigitsFor(currencyCode ?? defaultCurrencyCode);
    final fixed = amount.toStringAsFixed(digits);
    final negative = fixed.startsWith('-');
    final normalized = negative ? fixed.substring(1) : fixed;
    final parts = normalized.split('.');
    final major = int.tryParse(parts[0]) ?? 0;
    final fraction = parts.length > 1
        ? parts[1].padRight(digits, '0')
        : ''.padRight(digits, '0');
    final minor =
        major * math.pow(10, digits).toInt() + (int.tryParse(fraction) ?? 0);
    return negative ? -minor : minor;
  }

  static double toMajor(int minor, {String? currencyCode}) {
    final digits = decimalDigitsFor(currencyCode ?? defaultCurrencyCode);
    return minor / math.pow(10, digits);
  }

  static String formatDate(DateTime date) => AppDateUtils.formatDate(date);

  static String formatDateShort(DateTime date) =>
      AppDateUtils.formatDateShort(date);
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

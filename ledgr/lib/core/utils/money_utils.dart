import 'dart:math' as math;

import 'package:intl/intl.dart';

import 'currency_utils.dart';

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
    for (final info in CurrencyUtils.currencies) {
      if (info.code.toUpperCase() == code.toUpperCase()) {
        return info.minorUnits;
      }
    }
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
    final converted = tryConvertMinor(
      amountMinor,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rates: rates,
    );
    if (converted == null) {
      throw StateError(
        'Missing exchange rate for $fromCurrency to $toCurrency',
      );
    }
    return converted;
  }

  static int? tryConvertMinor(
    int amountMinor, {
    required String fromCurrency,
    required String toCurrency,
    required Map<String, double> rates,
  }) {
    if (fromCurrency.toLowerCase() == toCurrency.toLowerCase()) {
      return amountMinor;
    }
    final fromRate = rates[fromCurrency.toLowerCase()] ??
        (fromCurrency.toLowerCase() == 'usd' ? 1.0 : null);
    final toRate = rates[toCurrency.toLowerCase()] ??
        (toCurrency.toLowerCase() == 'usd' ? 1.0 : null);
    if (fromRate == null || toRate == null || fromRate == 0) {
      return null;
    }
    final convertedMajor = toMajor(amountMinor, currencyCode: fromCurrency) *
        toRate *
        (1 / fromRate);
    return toMinor(convertedMajor, currencyCode: toCurrency);
  }

  static int toMinor(double amount, {String? currencyCode}) {
    final digits = decimalDigitsFor(currencyCode ?? defaultCurrencyCode);
    final factor = math.pow(10, digits).toDouble();
    return (amount * factor).round();
  }

  static double toMajor(int minor, {String? currencyCode}) {
    final digits = decimalDigitsFor(currencyCode ?? defaultCurrencyCode);
    return minor / math.pow(10, digits);
  }

  static String toMajorText(int minor, {String? currencyCode}) {
    final code = currencyCode ?? defaultCurrencyCode;
    return toMajor(
      minor,
      currencyCode: code,
    ).toStringAsFixed(decimalDigitsFor(code));
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

  static String formatMonthAbbreviation(DateTime date) {
    return DateFormat.MMM().format(date);
  }

  static DateTime monthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime monthEnd(DateTime date) {
    final nextMonthStart = DateTime(date.year, date.month + 1, 1);
    return nextMonthStart.subtract(const Duration(days: 1));
  }

  static DateTime previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1, 1);
  }

  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }
}

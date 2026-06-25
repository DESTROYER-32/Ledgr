import 'package:intl/intl.dart';

class MoneyUtils {
  MoneyUtils._();

  static const String defaultCurrencyCode = 'USD';

  static String _symbol(String code) {
    try {
      return NumberFormat.simpleCurrency(
        name: code,
        decimalDigits: 2,
      ).currencySymbol;
    } catch (_) {
      return code;
    }
  }

  static String format(int amountMinor, {String? currencyCode}) {
    final amount = amountMinor / 100;
    final code = currencyCode ?? defaultCurrencyCode;
    try {
      final format = NumberFormat.simpleCurrency(name: code, decimalDigits: 2);
      return format.format(amount);
    } catch (_) {
      return '$code ${amount.toStringAsFixed(2)}';
    }
  }

  static String formatCompact(int amountMinor, {String? currencyCode}) {
    final amount = amountMinor / 100;
    final sym = _symbol(currencyCode ?? defaultCurrencyCode);
    if (amount.abs() >= 1000000) {
      return '$sym${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount.abs() >= 1000) {
      return '$sym${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amountMinor, currencyCode: currencyCode);
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

  static int toMinor(double amount) => (amount * 100).round();

  static double toMajor(int minor) => minor / 100;

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

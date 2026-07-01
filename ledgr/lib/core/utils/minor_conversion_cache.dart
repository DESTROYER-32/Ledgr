import 'money_utils.dart';

/// Caches minor-unit currency conversions for repeated list rendering.
class MinorConversionCache {
  final String toCurrency;
  final Map<String, double> rates;
  final Map<_ConversionKey, int?> _cache = {};

  MinorConversionCache({required this.toCurrency, required this.rates});

  int? convert(int amountMinor, {required String fromCurrency}) {
    if (fromCurrency.toLowerCase() == toCurrency.toLowerCase()) {
      return amountMinor;
    }
    final key = _ConversionKey(amountMinor, fromCurrency.toLowerCase());
    return _cache.putIfAbsent(
      key,
      () => MoneyUtils.tryConvertMinor(
        amountMinor,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        rates: rates,
      ),
    );
  }
}

class _ConversionKey {
  final int amountMinor;
  final String fromCurrency;

  const _ConversionKey(this.amountMinor, this.fromCurrency);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ConversionKey &&
          amountMinor == other.amountMinor &&
          fromCurrency == other.fromCurrency;

  @override
  int get hashCode => Object.hash(amountMinor, fromCurrency);
}

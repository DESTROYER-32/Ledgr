import 'currency_utils.dart';

List<String> currencyOptionsWithSelection(
  List<String> favoriteCurrencies,
  String? selectedCurrency,
) {
  final options =
      favoriteCurrencies.where(CurrencyUtils.codes.contains).toSet().toList();
  if (selectedCurrency != null &&
      CurrencyUtils.codes.contains(selectedCurrency) &&
      !options.contains(selectedCurrency)) {
    options.insert(0, selectedCurrency);
  }
  return options.isEmpty ? CurrencyUtils.codes : options;
}

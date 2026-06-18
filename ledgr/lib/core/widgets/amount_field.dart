import 'package:flutter/material.dart';
import '../utils/currency_utils.dart';
import '../utils/money_utils.dart';

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String currencySymbol;
  final bool autofocus;

  const AmountField({
    super.key,
    required this.controller,
    this.label = 'Amount',
    this.currencySymbol = MoneyUtils.defaultCurrencyCode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyUtils.symbolFor(currencySymbol) ?? currencySymbol;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '$symbol ',
        hintText: '0.00',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}

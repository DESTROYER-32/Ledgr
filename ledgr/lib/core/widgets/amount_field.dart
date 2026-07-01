import 'package:flutter/material.dart';
import '../utils/currency_utils.dart';
import '../utils/money_utils.dart';

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String currencyCode;
  final bool autofocus;
  final String? Function(String?)? validator;

  const AmountField({
    super.key,
    required this.controller,
    this.label = 'Amount',
    String currencyCode = MoneyUtils.defaultCurrencyCode,
    @Deprecated(
      'Use currencyCode. This parameter expects an ISO currency code, not a symbol.',
    )
    String? currencySymbol,
    this.autofocus = false,
    this.validator,
  }) : currencyCode = currencySymbol ?? currencyCode;

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyUtils.symbolFor(currencyCode);
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '$symbol ',
        hintText: '0.00',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}

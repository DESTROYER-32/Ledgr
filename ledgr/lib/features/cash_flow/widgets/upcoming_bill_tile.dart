import 'package:flutter/material.dart';

import '../../../core/utils/money_utils.dart';
import '../cash_flow_projector.dart';

class UpcomingBillTile extends StatelessWidget {
  const UpcomingBillTile({super.key, required this.event});

  final CashFlowEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(AppDateUtils.formatDate(event.date)),
        trailing: Text(
          MoneyUtils.format(
            event.amountMinor,
            currencyCode: event.currencyCode,
          ),
          style: TextStyle(
            color: event.amountMinor < 0
                ? Theme.of(context).colorScheme.error
                : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

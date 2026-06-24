import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../theme/app_theme.dart';
import '../utils/money_utils.dart';

class TransactionGroupedList extends StatelessWidget {
  final List<Transaction> transactions;
  final void Function(Transaction transaction)? onTap;
  final int? maxItems;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;
  final bool showDaySummary;

  const TransactionGroupedList({
    super.key,
    required this.transactions,
    this.onTap,
    this.maxItems,
    this.shrinkWrap = false,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.showDaySummary = true,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...transactions]
      ..sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        if (dateCompare != 0) return dateCompare;
        return b.id.compareTo(a.id);
      });
    final visible = maxItems == null ? sorted : sorted.take(maxItems!).toList();
    final groups = _groupByDay(visible);

    return ListView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _TransactionDaySection(
          date: group.date,
          transactions: group.transactions,
          onTap: onTap,
          showSummary: showDaySummary,
        );
      },
    );
  }

  List<_TransactionDayGroup> _groupByDay(List<Transaction> txns) {
    final groups = <_TransactionDayGroup>[];
    for (final transaction in txns) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (groups.isEmpty || groups.last.date != day) {
        groups.add(_TransactionDayGroup(day, [transaction]));
      } else {
        groups.last.transactions.add(transaction);
      }
    }
    return groups;
  }
}

class _TransactionDayGroup {
  final DateTime date;
  final List<Transaction> transactions;

  _TransactionDayGroup(this.date, this.transactions);
}

class _TransactionDaySection extends StatelessWidget {
  final DateTime date;
  final List<Transaction> transactions;
  final void Function(Transaction transaction)? onTap;
  final bool showSummary;

  const _TransactionDaySection({
    required this.date,
    required this.transactions,
    required this.onTap,
    required this.showSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final income = transactions
        .where((t) => t.type == 'income')
        .fold<int>(0, (sum, t) => sum + t.amountMinor);
    final expense = transactions
        .where((t) => t.type == 'expense')
        .fold<int>(0, (sum, t) => sum + t.amountMinor);
    final net = income - expense;
    final displayCurrency = transactions.first.currencyCode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
            child: Row(
              children: [
                _DateBadge(date: date),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _relativeDateLabel(date),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        MoneyUtils.formatDate(date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showSummary)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${net < 0
                            ? '-'
                            : net > 0
                            ? '+'
                            : ''}${MoneyUtils.format(net.abs(), currencyCode: displayCurrency)}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: net < 0
                              ? AppColors.expense
                              : net > 0
                              ? AppColors.income
                              : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${transactions.length} item${transactions.length == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
                width: 0.6,
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < transactions.length; i++) ...[
                  _CashewTransactionRow(
                    transaction: transactions[i],
                    onTap: onTap == null ? null : () => onTap!(transactions[i]),
                  ),
                  if (i != transactions.length - 1)
                    Divider(
                      height: 1,
                      indent: 64,
                      color: cs.outlineVariant.withValues(alpha: 0.45),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = day.difference(today).inDays;
    return switch (diff) {
      0 => 'Today',
      -1 => 'Yesterday',
      1 => 'Tomorrow',
      _ => _weekdayName(date.weekday),
    };
  }

  String _weekdayName(int weekday) => switch (weekday) {
    DateTime.monday => 'Monday',
    DateTime.tuesday => 'Tuesday',
    DateTime.wednesday => 'Wednesday',
    DateTime.thursday => 'Thursday',
    DateTime.friday => 'Friday',
    DateTime.saturday => 'Saturday',
    _ => 'Sunday',
  };
}

class _DateBadge extends StatelessWidget {
  final DateTime date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _monthName(date.month),
            style: TextStyle(
              color: cs.onPrimaryContainer.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) => switch (month) {
    1 => 'JAN',
    2 => 'FEB',
    3 => 'MAR',
    4 => 'APR',
    5 => 'MAY',
    6 => 'JUN',
    7 => 'JUL',
    8 => 'AUG',
    9 => 'SEP',
    10 => 'OCT',
    11 => 'NOV',
    _ => 'DEC',
  };
}

class _CashewTransactionRow extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const _CashewTransactionRow({required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _typeColor(transaction.type);
    final sign = transaction.type == 'expense'
        ? '-'
        : transaction.type == 'income'
        ? '+'
        : '';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_typeIcon(transaction.type), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title?.trim().isNotEmpty == true
                        ? transaction.title!.trim()
                        : _typeLabel(transaction.type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        _typeLabel(transaction.type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (transaction.specialType != 'none') ...[
                        const SizedBox(width: 6),
                        _Dot(color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _specialTypeLabel(transaction.specialType),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$sign${MoneyUtils.format(transaction.amountMinor, currencyCode: transaction.currencyCode)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) => switch (type) {
    'expense' => AppColors.expense,
    'income' => AppColors.income,
    _ => AppColors.transfer,
  };

  IconData _typeIcon(String type) => switch (type) {
    'expense' => Icons.arrow_upward_rounded,
    'income' => Icons.arrow_downward_rounded,
    _ => Icons.swap_horiz_rounded,
  };

  String _typeLabel(String type) => switch (type) {
    'expense' => 'Expense',
    'income' => 'Income',
    _ => 'Transfer',
  };

  String _specialTypeLabel(String specialType) => switch (specialType) {
    'subscription' => 'Subscription',
    'scheduled' || 'repetitive' => 'Scheduled',
    'upcoming' => 'Upcoming',
    'credit' => 'Credit',
    'debt' => 'Debt',
    _ => specialType,
  };
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

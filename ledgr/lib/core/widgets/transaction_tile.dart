import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/category_icon_utils.dart';
import '../utils/money_utils.dart';

class TransactionTile extends StatelessWidget {
  final int id;
  final String type;
  final int amountMinor;
  final String? title;
  final DateTime date;
  final String? categoryName;
  final Color? categoryColor;
  final String? categoryIcon;
  final VoidCallback? onTap;
  final VoidCallback? onDuplicate;
  final String? currencyCode;
  final int? displayAmountMinor;
  final String? displayCurrencyCode;

  const TransactionTile({
    super.key,
    required this.id,
    required this.type,
    required this.amountMinor,
    this.title,
    required this.date,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.onTap,
    this.onDuplicate,
    this.currencyCode,
    this.displayAmountMinor,
    this.displayCurrencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = type == 'expense';
    final isIncome = type == 'income';
    final amountColor = isExpense
        ? AppColors.expense
        : (isIncome ? AppColors.income : AppColors.transfer);
    final iconColor = categoryColor ?? amountColor;
    final sign = isExpense ? '-' : (isIncome ? '+' : '');
    final originalCurrency = currencyCode ?? MoneyUtils.defaultCurrencyCode;
    final primaryCurrency = displayCurrencyCode ?? originalCurrency;
    final primaryAmount = displayAmountMinor ?? amountMinor;
    final showOriginal =
        originalCurrency.toUpperCase() != primaryCurrency.toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcon != null
                      ? materialCategoryIcon(categoryIcon)
                      : (isExpense || isIncome
                            ? Icons.category_outlined
                            : Icons.swap_horiz),
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? type[0].toUpperCase() + type.substring(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          MoneyUtils.formatDateShort(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (categoryName != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            categoryName!,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  categoryColor ??
                                  theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${MoneyUtils.format(primaryAmount, currencyCode: primaryCurrency)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: amountColor,
                    ),
                  ),
                  if (showOriginal) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$sign${MoneyUtils.format(amountMinor, currencyCode: originalCurrency)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              if (onDuplicate != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onDuplicate,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Duplicate',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';
import '../../core/utils/recurring_utils.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late final PageController _pageController;
  int? _page;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final recurringAsync = ref.watch(activeRecurringProvider);
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Search and filters',
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (allTransactions) {
          final transactions = allTransactions.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final recurringItems =
              recurringAsync.valueOrNull ?? <RecurringTransaction>[];
          final entries = _buildLedgerEntries(transactions, recurringItems);
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long,
              title: 'No transactions yet',
              subtitle: 'Tap + to add your first income, expense, or transfer.',
            );
          }

          final months = _buildMonths(entries);
          final currentMonth = DateTime(
            DateTime.now().year,
            DateTime.now().month,
          );
          final currentMonthIndex = months.indexWhere(
            (month) => _isSameMonth(month, currentMonth),
          );
          final initialPage = currentMonthIndex == -1
              ? months.length - 1
              : currentMonthIndex;
          if (_page == null) {
            _page = initialPage;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _pageController.hasClients) {
                _pageController.jumpToPage(initialPage);
              }
            });
          }
          final categoriesById = {
            for (final c in categoriesAsync.valueOrNull ?? <Category>[])
              c.id: c,
          };
          final safePage = (_page ?? initialPage).clamp(0, months.length - 1);
          final month = months[safePage];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _MonthSwitcher(
                  label: _formatMonth(month),
                  canGoOlder: safePage > 0,
                  canGoNewer: safePage < months.length - 1,
                  onOlder: () => _animateTo(safePage - 1),
                  onNewer: () => _animateTo(safePage + 1),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: months.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    final visibleMonth = months[index];
                    final monthEntries = entries
                        .where(
                          (entry) => _isSameMonth(entry.date, visibleMonth),
                        )
                        .toList();
                    return _MonthTransactionsPage(
                      month: visibleMonth,
                      entries: monthEntries,
                      categoriesById: categoriesById,
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (error, _) => Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _animateTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  List<_LedgerEntry> _buildLedgerEntries(
    List<Transaction> transactions,
    List<RecurringTransaction> recurringItems,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final previewEnd = DateTime(now.year, now.month + 12, 0, 23, 59);
    final entries = <_LedgerEntry>[
      ...transactions.map(_LedgerEntry.transaction),
    ];

    for (final item in recurringItems) {
      final nextDue = item.nextDueDate;
      if (nextDue == null) continue;
      final start = nextDue.isBefore(today) ? today : nextDue;
      final end = item.endDate != null && item.endDate!.isBefore(previewEnd)
          ? item.endDate!
          : previewEnd;
      for (final date in RecurringUtils.generateInstances(
        item.scheduleRule,
        start,
        end,
        24,
      )) {
        if (date.isBefore(today)) continue;
        final hasPostedTransaction = transactions.any(
          (transaction) =>
              transaction.type == item.transactionType &&
              transaction.amountMinor == item.amountMinor &&
              transaction.walletId == item.walletId &&
              transaction.title == item.title &&
              _isSameDay(transaction.date, date),
        );
        if (!hasPostedTransaction) {
          entries.add(_LedgerEntry.recurring(item, date));
        }
      }
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  List<DateTime> _buildMonths(List<_LedgerEntry> entries) {
    final now = DateTime.now();
    final oldest = entries
        .map((entry) => entry.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final newest = entries
        .map((entry) => entry.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final months = <DateTime>[];
    var cursor = DateTime(oldest.year, oldest.month);
    final lastTransactionMonth = DateTime(newest.year, newest.month);
    final currentMonth = DateTime(now.year, now.month);
    final last = lastTransactionMonth.isAfter(currentMonth)
        ? lastTransactionMonth
        : currentMonth;
    while (!cursor.isAfter(last)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return months;
  }

  bool _isSameMonth(DateTime date, DateTime month) =>
      date.year == month.year && date.month == month.month;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatMonth(DateTime month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[month.month - 1]} ${month.year}';
  }
}

class _MonthSwitcher extends StatelessWidget {
  final String label;
  final bool canGoNewer;
  final bool canGoOlder;
  final VoidCallback onNewer;
  final VoidCallback onOlder;

  const _MonthSwitcher({
    required this.label,
    required this.canGoNewer,
    required this.canGoOlder,
    required this.onNewer,
    required this.onOlder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Newer month',
              onPressed: canGoNewer ? onNewer : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Swipe to change month',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Older month',
              onPressed: canGoOlder ? onOlder : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthTransactionsPage extends StatelessWidget {
  final DateTime month;
  final List<_LedgerEntry> entries;
  final Map<int, Category> categoriesById;

  const _MonthTransactionsPage({
    required this.month,
    required this.entries,
    required this.categoriesById,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _MonthSummary.from(entries);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        _SummaryCard(summary: summary),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          const EmptyState(
            icon: Icons.event_busy,
            title: 'No transactions this month',
            subtitle: 'Swipe to another month or tap + to add one.',
          )
        else
          ..._buildDaySections(context),
      ],
    );
  }

  List<Widget> _buildDaySections(BuildContext context) {
    final grouped = <DateTime, List<_LedgerEntry>>{};
    for (final entry in entries) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      grouped.putIfAbsent(day, () => []).add(entry);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return days.expand((day) {
      final dayEntries = grouped[day]!;
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
          child: Text(
            MoneyUtils.formatDateShort(day),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...dayEntries.map((entry) {
          final category = entry.categoryId == null
              ? null
              : categoriesById[entry.categoryId];
          if (entry.transaction != null) {
            final transaction = entry.transaction!;
            return TransactionTile(
              id: transaction.id,
              type: entry.type,
              amountMinor: entry.amountMinor,
              title: entry.title,
              date: entry.date,
              categoryName: category?.name,
              categoryColor: category?.color == null
                  ? null
                  : Color(category!.color!),
              currencyCode: entry.currencyCode,
              onTap: () => context.push('/transactions/${transaction.id}'),
            );
          }
          return _PlannedTransactionTile(
            entry: entry,
            categoryName: category?.name,
            categoryColor: category?.color == null
                ? null
                : Color(category!.color!),
            onTap: () => context.push('/recurring/${entry.recurring!.id}'),
          );
        }),
      ];
    }).toList();
  }
}

class _PlannedTransactionTile extends StatelessWidget {
  const _PlannedTransactionTile({
    required this.entry,
    this.categoryName,
    this.categoryColor,
    this.onTap,
  });

  final _LedgerEntry entry;
  final String? categoryName;
  final Color? categoryColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = entry.type == 'expense';
    final isIncome = entry.type == 'income';
    final color = isExpense
        ? AppColors.expense
        : (isIncome ? AppColors.income : AppColors.transfer);
    final sign = isExpense ? '-' : (isIncome ? '+' : '');
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event_repeat, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title ?? entry.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          'Planned · ${MoneyUtils.formatDateShort(entry.date)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (categoryName != null)
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
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$sign${MoneyUtils.format(entry.amountMinor, currencyCode: entry.currencyCode)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _MonthSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly summary',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryPill(
                    label: 'Income',
                    amount: summary.income,
                    color: AppColors.income,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryPill(
                    label: 'Expense',
                    amount: summary.expense,
                    color: AppColors.expense,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Net balance',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    MoneyUtils.format(summary.net),
                    style: TextStyle(
                      color: summary.net >= 0
                          ? AppColors.income
                          : AppColors.expense,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final IconData icon;

  const _SummaryPill({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            MoneyUtils.format(amount),
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MonthSummary {
  final int income;
  final int expense;

  const _MonthSummary({required this.income, required this.expense});

  int get net => income - expense;

  factory _MonthSummary.from(List<_LedgerEntry> entries) {
    var income = 0;
    var expense = 0;
    for (final entry in entries) {
      if (entry.type == 'income') income += entry.amountMinor;
      if (entry.type == 'expense') expense += entry.amountMinor;
    }
    return _MonthSummary(income: income, expense: expense);
  }
}

class _LedgerEntry {
  const _LedgerEntry._({
    required this.type,
    required this.amountMinor,
    required this.date,
    this.title,
    this.categoryId,
    this.currencyCode,
    this.transaction,
    this.recurring,
  });

  final String type;
  final int amountMinor;
  final DateTime date;
  final String? title;
  final int? categoryId;
  final String? currencyCode;
  final Transaction? transaction;
  final RecurringTransaction? recurring;

  factory _LedgerEntry.transaction(Transaction transaction) => _LedgerEntry._(
    type: transaction.type,
    amountMinor: transaction.amountMinor,
    date: transaction.date,
    title: transaction.title,
    categoryId: transaction.categoryId,
    currencyCode: transaction.currencyCode,
    transaction: transaction,
  );

  factory _LedgerEntry.recurring(
    RecurringTransaction recurring,
    DateTime date,
  ) => _LedgerEntry._(
    type: recurring.transactionType,
    amountMinor: recurring.amountMinor,
    date: date,
    title: recurring.title,
    categoryId: recurring.categoryId,
    recurring: recurring,
  );
}

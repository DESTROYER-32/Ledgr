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
  final bool calendarOnly;

  const TransactionsScreen({super.key, this.calendarOnly = false});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late final PageController _pageController;
  int? _page;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _showCalendar = widget.calendarOnly;
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
        title: Text(widget.calendarOnly ? 'Calendar' : 'Transactions'),
        actions: [
          if (!widget.calendarOnly)
            IconButton(
              tooltip: _showCalendar
                  ? 'Show transaction list'
                  : 'Show calendar',
              icon: Icon(
                _showCalendar ? Icons.view_list : Icons.calendar_month,
              ),
              onPressed: () => setState(() => _showCalendar = !_showCalendar),
            ),
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
                    return _showCalendar
                        ? _MonthCalendarPage(
                            month: visibleMonth,
                            entries: monthEntries,
                          )
                        : _MonthTransactionsPage(
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

    for (final transaction in transactions) {
      final rule = transaction.recurrenceRule;
      if (!_shouldPreviewRecurringTransaction(transaction, rule)) continue;

      final start = _firstRecurringPreviewDate(rule!, transaction.date, today);
      for (final date in RecurringUtils.generateInstances(
        rule,
        start,
        previewEnd,
        24,
      )) {
        if (date.isBefore(today)) continue;
        final hasPostedTransaction = transactions.any(
          (posted) =>
              posted.id != transaction.id &&
              posted.type == transaction.type &&
              posted.amountMinor == transaction.amountMinor &&
              posted.walletId == transaction.walletId &&
              posted.title == transaction.title &&
              _isSameDay(posted.date, date),
        );
        if (!hasPostedTransaction) {
          entries.add(_LedgerEntry.recurringTransaction(transaction, date));
        }
      }
    }

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

  bool _shouldPreviewRecurringTransaction(
    Transaction transaction,
    String? rule,
  ) {
    if (rule == null || rule == 'one_time') return false;
    if (!RecurringUtils.isSupportedRule(rule)) return false;
    const recurringSpecialTypes = {'subscription', 'scheduled', 'repetitive'};
    return recurringSpecialTypes.contains(transaction.specialType);
  }

  DateTime _firstRecurringPreviewDate(
    String rule,
    DateTime transactionDate,
    DateTime today,
  ) {
    var date = RecurringUtils.computeNextDueDate(rule, transactionDate);
    while (date.isBefore(today)) {
      final next = RecurringUtils.computeNextDueDate(rule, date);
      if (!next.isAfter(date)) break;
      date = next;
    }
    return date;
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

class _MonthCalendarPage extends StatelessWidget {
  final DateTime month;
  final List<_LedgerEntry> entries;

  const _MonthCalendarPage({required this.month, required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = _MonthSummary.from(entries);
    final daySummaries = _buildDaySummaries(entries);
    final cells = _buildCalendarCells(month);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        _SummaryCard(summary: summary),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Row(
                  children: [
                    _WeekdayLabel('M'),
                    _WeekdayLabel('T'),
                    _WeekdayLabel('W'),
                    _WeekdayLabel('T'),
                    _WeekdayLabel('F'),
                    _WeekdayLabel('S'),
                    _WeekdayLabel('S'),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cells.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final date = cells[index];
                    if (date == null) return const SizedBox.shrink();
                    final key = DateTime(date.year, date.month, date.day);
                    return _CalendarDayCell(
                      date: date,
                      summary: daySummaries[key],
                      isToday: _isSameDay(date, DateTime.now()),
                      onTap: daySummaries[key] == null
                          ? null
                          : () => _showDateTransactions(
                              context,
                              date,
                              daySummaries[key]!.entries,
                            ),
                      onAddTransaction: () =>
                          _addTransactionOnDate(context, date),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap the list icon to return to transactions. Calendar includes posted and planned recurring items.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Map<DateTime, _DaySummary> _buildDaySummaries(List<_LedgerEntry> entries) {
    final map = <DateTime, _DaySummary>{};
    for (final entry in entries) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      map.putIfAbsent(day, _DaySummary.new).add(entry);
    }
    return map;
  }

  List<DateTime?> _buildCalendarCells(DateTime month) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = first.weekday - 1;
    final cells = <DateTime?>[
      for (var i = 0; i < leadingBlanks; i++) null,
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(month.year, month.month, day),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showDateTransactions(
    BuildContext context,
    DateTime date,
    List<_LedgerEntry> entries,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) =>
          _DateTransactionsSheet(date: date, entries: entries),
    );
  }

  void _addTransactionOnDate(BuildContext context, DateTime date) {
    context.push('/transactions/new', extra: {'date': date});
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final _DaySummary? summary;
  final bool isToday;
  final VoidCallback? onTap;
  final VoidCallback onAddTransaction;

  const _CalendarDayCell({
    required this.date,
    required this.summary,
    required this.isToday,
    required this.onTap,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTransactions = summary != null && summary!.count > 0;
    final net = summary?.net ?? 0;
    final netColor = net >= 0 ? AppColors.income : AppColors.expense;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onDoubleTap: onAddTransaction,
        onLongPress: onAddTransaction,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            color: isToday
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.7)
                : hasTransactions
                ? theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  )
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isToday
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${date.day}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isToday ? theme.colorScheme.primary : null,
                    ),
                  ),
                  const Spacer(),
                  if (summary != null) ...[
                    if (summary!.expense > 0)
                      const _CalendarDot(color: AppColors.expense),
                    if (summary!.income > 0) ...[
                      const SizedBox(width: 3),
                      const _CalendarDot(color: AppColors.income),
                    ],
                  ],
                ],
              ),
              const Spacer(),
              if (hasTransactions)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${net >= 0 ? '+' : '-'}${MoneyUtils.formatCompact(net.abs())}',
                    maxLines: 1,
                    style: TextStyle(
                      color: netColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarDot extends StatelessWidget {
  final Color color;

  const _CalendarDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DateTransactionsSheet extends StatelessWidget {
  final DateTime date;
  final List<_LedgerEntry> entries;

  const _DateTransactionsSheet({required this.date, required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedEntries = entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final summary = _MonthSummary.from(sortedEntries);
    final net = summary.net;
    final netColor = net >= 0 ? AppColors.income : AppColors.expense;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.32,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MoneyUtils.formatDate(date),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${sortedEntries.length} transaction${sortedEntries.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${net >= 0 ? '+' : '-'}${MoneyUtils.format(net.abs())}',
                    style: TextStyle(
                      color: netColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryPill(
                      label: 'Incoming',
                      amount: summary.income,
                      color: AppColors.income,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SummaryPill(
                      label: 'Outgoing',
                      amount: summary.expense,
                      color: AppColors.expense,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...sortedEntries.map(
                (entry) => _DateTransactionRow(
                  entry: entry,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (entry.transaction != null) {
                      context.push('/transactions/${entry.transaction!.id}');
                    } else if (entry.recurring != null) {
                      context.push('/recurring/${entry.recurring!.id}');
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DateTransactionRow extends StatelessWidget {
  final _LedgerEntry entry;
  final VoidCallback onTap;

  const _DateTransactionRow({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = entry.type == 'expense';
    final isIncome = entry.type == 'income';
    final color = isExpense
        ? AppColors.expense
        : isIncome
        ? AppColors.income
        : AppColors.transfer;
    final sign = isExpense ? '-' : (isIncome ? '+' : '');
    final isPlanned = entry.transaction == null;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: isPlanned && entry.recurring == null ? null : onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isPlanned ? Icons.event_repeat : Icons.receipt_long,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          entry.title ?? entry.type,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          isPlanned ? 'Planned' : MoneyUtils.formatDateShort(entry.date),
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Text(
          '$sign${MoneyUtils.format(entry.amountMinor, currencyCode: entry.currencyCode)}',
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
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
            onTap: entry.recurring == null
                ? null
                : () => context.push('/recurring/${entry.recurring!.id}'),
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

class _DaySummary {
  int income = 0;
  int expense = 0;
  int transfer = 0;
  int count = 0;
  final entries = <_LedgerEntry>[];

  int get net => income - expense;

  void add(_LedgerEntry entry) {
    count++;
    entries.add(entry);
    if (entry.type == 'income') {
      income += entry.amountMinor;
    } else if (entry.type == 'expense') {
      expense += entry.amountMinor;
    } else {
      transfer += entry.amountMinor;
    }
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

  factory _LedgerEntry.recurringTransaction(
    Transaction transaction,
    DateTime date,
  ) => _LedgerEntry._(
    type: transaction.type,
    amountMinor: transaction.amountMinor,
    date: date,
    title: transaction.title,
    categoryId: transaction.categoryId,
    currencyCode: transaction.currencyCode,
  );
}

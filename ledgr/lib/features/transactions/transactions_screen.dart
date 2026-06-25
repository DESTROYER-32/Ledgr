import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';
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
          if (transactions.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long,
              title: 'No transactions yet',
              subtitle: 'Tap + to add your first income, expense, or transfer.',
            );
          }

          final months = _buildMonths(transactions);
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
                    final monthTransactions = transactions
                        .where((t) => _isSameMonth(t.date, visibleMonth))
                        .toList();
                    return _MonthTransactionsPage(
                      month: visibleMonth,
                      transactions: monthTransactions,
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

  List<DateTime> _buildMonths(List<Transaction> transactions) {
    final now = DateTime.now();
    final oldest = transactions
        .map((transaction) => transaction.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final newest = transactions
        .map((transaction) => transaction.date)
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
  final List<Transaction> transactions;
  final Map<int, Category> categoriesById;

  const _MonthTransactionsPage({
    required this.month,
    required this.transactions,
    required this.categoriesById,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _MonthSummary.from(transactions);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        _SummaryCard(summary: summary),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
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
    final grouped = <DateTime, List<Transaction>>{};
    for (final transaction in transactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      grouped.putIfAbsent(day, () => []).add(transaction);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return days.expand((day) {
      final dayTransactions = grouped[day]!;
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
        ...dayTransactions.map((transaction) {
          final category = transaction.categoryId == null
              ? null
              : categoriesById[transaction.categoryId];
          return TransactionTile(
            id: transaction.id,
            type: transaction.type,
            amountMinor: transaction.amountMinor,
            title: transaction.title,
            date: transaction.date,
            categoryName: category?.name,
            categoryColor: category?.color == null
                ? null
                : Color(category!.color!),
            currencyCode: transaction.currencyCode,
            onTap: () => context.push('/transactions/${transaction.id}'),
          );
        }),
      ];
    }).toList();
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

  factory _MonthSummary.from(List<Transaction> transactions) {
    var income = 0;
    var expense = 0;
    for (final transaction in transactions) {
      if (transaction.type == 'income') income += transaction.amountMinor;
      if (transaction.type == 'expense') expense += transaction.amountMinor;
    }
    return _MonthSummary(income: income, expense: expense);
  }
}

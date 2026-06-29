import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/modern_selection_field.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;
  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() {
    _timer?.cancel();
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _queryController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 400));

  String? _type;
  int? _walletId;
  int? _categoryId;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _minAmountMinor;
  int? _maxAmountMinor;
  List<Transaction>? _results;
  StreamSubscription? _resultSubscription;

  bool get _hasFilters =>
      _type != null ||
      _walletId != null ||
      _categoryId != null ||
      _startDate != null ||
      _endDate != null ||
      _minAmountMinor != null ||
      _maxAmountMinor != null;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryController.removeListener(_onQueryChanged);
    _queryController.dispose();
    _debouncer.dispose();
    _resultSubscription?.cancel();
    super.dispose();
  }

  void _onQueryChanged() {
    _debouncer.run(_runSearch);
  }

  Future<void> _runSearch() async {
    final query = _queryController.text;
    final results = await ref
        .read(transactionRepositoryProvider)
        .search(
          query: query,
          type: _type,
          walletId: _walletId,
          categoryId: _categoryId,
          startDate: _startDate,
          endDate: _endDate,
          minAmount: _minAmountMinor,
          maxAmount: _maxAmountMinor,
        );
    if (mounted) setState(() => _results = results);
  }

  void _clearAll() {
    setState(() {
      _queryController.clear();
      _type = null;
      _walletId = null;
      _categoryId = null;
      _startDate = null;
      _endDate = null;
      _minAmountMinor = null;
      _maxAmountMinor = null;
      _results = null;
    });
    _debouncer.cancel();
  }

  String _formatAmount(int amount, {String? currencyCode}) {
    return MoneyUtils.format(amount, currencyCode: currencyCode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          if (_hasFilters || _results != null)
            TextButton(onPressed: _clearAll, child: const Text('Clear All')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _queryController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _queryController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _queryController.clear();
                          _runSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_hasFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_type != null)
                      _filterChip(
                        label: _type == 'expense'
                            ? 'Expense'
                            : _type == 'income'
                            ? 'Income'
                            : 'Transfer',
                        onRemove: () {
                          setState(() => _type = null);
                          _runSearch();
                        },
                      ),
                    if (_walletId != null)
                      _buildWalletChip(
                        onRemove: () {
                          setState(() => _walletId = null);
                          _runSearch();
                        },
                      ),
                    if (_categoryId != null)
                      _buildCategoryChip(
                        onRemove: () {
                          setState(() => _categoryId = null);
                          _runSearch();
                        },
                      ),
                    if (_startDate != null)
                      _filterChip(
                        label:
                            'From ${MoneyUtils.formatDateShort(_startDate!)}',
                        onRemove: () {
                          setState(() => _startDate = null);
                          _runSearch();
                        },
                      ),
                    if (_endDate != null)
                      _filterChip(
                        label: 'To ${MoneyUtils.formatDateShort(_endDate!)}',
                        onRemove: () {
                          setState(() => _endDate = null);
                          _runSearch();
                        },
                      ),
                    if (_minAmountMinor != null)
                      _filterChip(
                        label: 'Min ${_formatAmount(_minAmountMinor!)}',
                        onRemove: () {
                          setState(() => _minAmountMinor = null);
                          _runSearch();
                        },
                      ),
                    if (_maxAmountMinor != null)
                      _filterChip(
                        label: 'Max ${_formatAmount(_maxAmountMinor!)}',
                        onRemove: () {
                          setState(() => _maxAmountMinor = null);
                          _runSearch();
                        },
                      ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Filters', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _startDate != null && _endDate != null
                          ? DateTimeRange(start: _startDate!, end: _endDate!)
                          : null,
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = picked.end;
                      });
                      _runSearch();
                    }
                  },
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${MoneyUtils.formatDateShort(_startDate!)} - ${MoneyUtils.formatDateShort(_endDate!)}'
                        : 'Date range',
                    style: TextStyle(
                      fontSize: 12,
                      color: _startDate != null ? null : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_results == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search,
                      size: 48,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start typing to search',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(child: _buildResultsList(theme, cs)),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required VoidCallback onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildWalletChip({required VoidCallback onRemove}) {
    final wallets = ref.watch(activeWalletsProvider).valueOrNull ?? [];
    final wallet = wallets.where((w) => w.id == _walletId).firstOrNull;
    return _filterChip(
      label: wallet?.name ?? 'Account #$_walletId',
      onRemove: onRemove,
    );
  }

  Widget _buildCategoryChip({required VoidCallback onRemove}) {
    final cats = ref.watch(activeCategoriesProvider).valueOrNull ?? [];
    final cat = cats.where((c) => c.id == _categoryId).firstOrNull;
    return _filterChip(
      label: cat?.name ?? 'Category #$_categoryId',
      onRemove: onRemove,
    );
  }

  void _showFilterSheet() {
    final wallets = ref.read(activeWalletsProvider).valueOrNull ?? [];
    final cats = ref.read(activeCategoriesProvider).valueOrNull ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        String? localType = _type;
        int? localWalletId = _walletId;
        int? localCategoryId = _categoryId;
        int? localMinAmount;
        int? localMaxAmount;
        final minController = TextEditingController(
          text: _minAmountMinor != null
              ? (_minAmountMinor! / 100).toStringAsFixed(0)
              : '',
        );
        final maxController = TextEditingController(
          text: _maxAmountMinor != null
              ? (_maxAmountMinor! / 100).toStringAsFixed(0)
              : '',
        );

        return StatefulBuilder(
          builder: (ctx, setLocalState) => Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 8,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Filters',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Type', style: Theme.of(ctx).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'expense', label: Text('Expense')),
                      ButtonSegment(value: 'income', label: Text('Income')),
                      ButtonSegment(value: 'transfer', label: Text('Transfer')),
                    ],
                    selected: localType != null ? {localType!} : <String>{},
                    onSelectionChanged: (v) => setLocalState(
                      () => localType = v.isEmpty ? null : v.first,
                    ),
                    emptySelectionAllowed: true,
                    showSelectedIcon: false,
                  ),
                  const SizedBox(height: 16),
                  ModernSelectionField<int>(
                    label: 'Account',
                    value: localWalletId,
                    placeholder: 'All accounts',
                    allowClear: true,
                    leadingIcon: Icons.account_balance_wallet_outlined,
                    items: wallets
                        .map(
                          (w) => ModernSelectionItem(
                            value: w.id,
                            title: w.name,
                            subtitle: w.type.replaceAll('_', ' '),
                            icon: Icons.account_balance_outlined,
                            badge: w.currencyCode,
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setLocalState(() => localWalletId = v),
                  ),
                  const SizedBox(height: 12),
                  ModernSelectionField<int>(
                    label: 'Category',
                    value: localCategoryId,
                    placeholder: 'All categories',
                    allowClear: true,
                    leadingIcon: Icons.category_outlined,
                    items: cats
                        .map(
                          (c) => ModernSelectionItem(
                            value: c.id,
                            title: c.name,
                            icon: Icons.category_outlined,
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setLocalState(() => localCategoryId = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minController,
                          decoration: const InputDecoration(
                            labelText: 'Min amount',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) {
                            final parsed = double.tryParse(v);
                            setLocalState(
                              () => localMinAmount = parsed != null
                                  ? (parsed * 100).round()
                                  : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxController,
                          decoration: const InputDecoration(
                            labelText: 'Max amount',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) {
                            final parsed = double.tryParse(v);
                            setLocalState(
                              () => localMaxAmount = parsed != null
                                  ? (parsed * 100).round()
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _type = localType;
                        _walletId = localWalletId;
                        _categoryId = localCategoryId;
                        _minAmountMinor = localMinAmount;
                        _maxAmountMinor = localMaxAmount;
                      });
                      _runSearch();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsList(ThemeData theme, ColorScheme cs) {
    if (_results!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text('No results found', style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }

    final totalIncome = _results!
        .where((t) => t.type == 'income')
        .fold<int>(0, (s, t) => s + t.amountMinor);
    final totalExpenses = _results!
        .where((t) => t.type == 'expense')
        .fold<int>(0, (s, t) => s + t.amountMinor);

    final grouped = <String, List<Transaction>>{};
    for (final t in _results!) {
      final key =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(t);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_results!.length} transaction${_results!.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
              if (totalExpenses > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    'Exp: ${_formatAmount(totalExpenses)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.expense,
                    ),
                  ),
                ),
              if (totalIncome > 0)
                Text(
                  'Inc: ${_formatAmount(totalIncome)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.income),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (_, sectionIndex) {
              final dateKey = sortedKeys[sectionIndex];
              final dayTransactions = grouped[dateKey]!;
              final parts = dateKey.split('-');
              final date = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      MoneyUtils.formatDateShort(date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ...dayTransactions.map((t) {
                    final isExpense = t.type == 'expense';
                    final isIncome = t.type == 'income';
                    final color = isExpense
                        ? AppColors.expense
                        : (isIncome ? AppColors.income : AppColors.transfer);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        radius: 18,
                        child: Icon(
                          isExpense
                              ? Icons.arrow_upward
                              : (isIncome
                                    ? Icons.arrow_downward
                                    : Icons.swap_horiz),
                          color: color,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        t.title ?? t.type,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        '${isExpense ? '-' : (isIncome ? '+' : '')}${_formatAmount(t.amountMinor)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      onTap: () => context.push('/transactions/${t.id}'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

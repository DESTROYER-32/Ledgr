import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _queryController = TextEditingController();
  String? _type;
  int? _walletId;
  int? _categoryId;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _minAmount;
  String? _maxAmount;
  List<Transaction>? _results;
  bool _isSearching = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _queryController.clear();
      _type = null;
      _walletId = null;
      _categoryId = null;
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
      _results = null;
    });
  }

  Future<void> _search() async {
    setState(() => _isSearching = true);
    try {
      final minAmt = _minAmount != null && _minAmount!.isNotEmpty
          ? (double.tryParse(_minAmount!) ?? 0) * 100
          : null;
      final maxAmt = _maxAmount != null && _maxAmount!.isNotEmpty
          ? (double.tryParse(_maxAmount!) ?? 0) * 100
          : null;

      final results = await ref
          .read(transactionRepositoryProvider)
          .search(
            query: _queryController.text,
            type: _type,
            walletId: _walletId,
            categoryId: _categoryId,
            startDate: _startDate,
            endDate: _endDate,
            minAmount: minAmt?.round(),
            maxAmount: maxAmt?.round(),
          );
      setState(() => _results = results);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(activeWalletsProvider);
    final catsAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          if (_results != null ||
              _type != null ||
              _startDate != null ||
              _endDate != null ||
              _walletId != null ||
              _categoryId != null)
            TextButton(
              onPressed: _clearAll,
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _queryController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _queryController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _queryController.clear();
                                },
                              )
                            : null,
                  ),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _type == null,
                        onSelected: (_) =>
                            setState(() => _type = null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Expense'),
                        selected: _type == 'expense',
                        onSelected: (_) => setState(
                            () => _type = 'expense'),
                      ),
                      FilterChip(
                        label: const Text('Income'),
                        selected: _type == 'income',
                        onSelected: (_) => setState(
                            () => _type = 'income'),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Transfer'),
                        selected: _type == 'transfer',
                        onSelected: (_) => setState(
                            () => _type = 'transfer'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(
                                () => _startDate = picked);
                          }
                        },
                        child: Text(
                          _startDate != null
                              ? MoneyUtils.formatDateShort(
                                  _startDate!)
                              : 'From date',
                          style: TextStyle(
                            fontSize: 12,
                            color: _startDate != null
                                ? null
                                : theme
                                    .colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(
                                () => _endDate = picked);
                          }
                        },
                        child: Text(
                          _endDate != null
                              ? MoneyUtils.formatDateShort(
                                  _endDate!)
                              : 'To date',
                          style: TextStyle(
                            fontSize: 12,
                            color: _endDate != null
                                ? null
                                : theme
                                    .colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Min \$',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        keyboardType: const TextInputType
                            .numberWithOptions(decimal: true),
                        onChanged: (v) =>
                            setState(() => _minAmount = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Max \$',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        keyboardType: const TextInputType
                            .numberWithOptions(decimal: true),
                        onChanged: (v) =>
                            setState(() => _maxAmount = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _dropdown(
                      value: _walletId,
                      label: 'Account',
                      items: walletsAsync,
                      toText: (w) => w.name,
                      toValue: (w) => w.id,
                      onChanged: (v) =>
                          setState(() => _walletId = v),
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _dropdown(
                      value: _categoryId,
                      label: 'Category',
                      items: catsAsync,
                      toText: (c) => c.name,
                      toValue: (c) => c.id,
                      onChanged: (v) =>
                          setState(() => _categoryId = v),
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator())
                : _results == null
                    ? Center(
                        child: Text('Enter search criteria',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(
                              color: theme
                                  .colorScheme.onSurfaceVariant,
                            )),
                      )
                    : _results!.isEmpty
                        ? Center(
                            child: Text('No results',
                                style:
                                    theme.textTheme.bodyLarge))
                        : ListView.builder(
                            itemCount: _results!.length,
                            itemBuilder: (_, i) {
                              final t = _results![i];
                              final isExpense =
                                  t.type == 'expense';
                              final isIncome =
                                  t.type == 'income';
                              final color = isExpense
                                  ? AppColors.expense
                                  : (isIncome
                                      ? AppColors.income
                                      : AppColors.transfer);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      color.withValues(
                                          alpha: 0.15),
                                  child: Icon(
                                    isExpense
                                        ? Icons.arrow_upward
                                        : (isIncome
                                            ? Icons
                                                .arrow_downward
                                            : Icons
                                                .swap_horiz),
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                title: Text(t.title ?? t.type),
                                subtitle: Text(
                                    MoneyUtils.formatDateShort(
                                        t.date)),
                                trailing: Text(
                                  '${isExpense ? '-' : (isIncome ? '+' : '')}${MoneyUtils.format(t.amountMinor)}',
                                  style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      color: color),
                                ),
                                onTap: () => context.push(
                                    '/transactions/${t.id}'),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String label,
    required AsyncValue<List<dynamic>> items,
    required String Function(dynamic) toText,
    required T Function(dynamic) toValue,
    required void Function(T?) onChanged,
  }) {
    return items.when(
      data: (data) => DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8),
        ),
        isExpanded: true,
        items: [
          DropdownMenuItem<T>(
              value: null, child: const Text('All')),
          ...data.map((item) => DropdownMenuItem<T>(
                value: toValue(item),
                child: Text(toText(item)),
              )),
        ],
        onChanged: onChanged,
      ),
      error: (e, _) => const SizedBox(),
      loading: () => const SizedBox(
          height: 40, child: LinearProgressIndicator()),
    );
  }
}

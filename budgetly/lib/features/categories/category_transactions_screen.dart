import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/money_utils.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/transaction_tile.dart';

class CategoryTransactionsScreen extends ConsumerStatefulWidget {
  final int categoryId;

  const CategoryTransactionsScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryTransactionsScreen> createState() =>
      _CategoryTransactionsScreenState();
}

class _CategoryTransactionsScreenState
    extends ConsumerState<CategoryTransactionsScreen> {
  static const _pageSize = 30;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _transactions = <Transaction>[];

  Category? _category;
  List<int> _categoryIds = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String _query = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final category = await categoryRepo.getById(widget.categoryId);
    final subs = await categoryRepo.watchSubcategories(widget.categoryId).first;
    _category = category;
    _categoryIds = [widget.categoryId, ...subs.map((c) => c.id)];
    await _loadPage(reset: true);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (_loadingMore && !reset) return;
    if (!_hasMore && !reset) return;
    if (_categoryIds.isEmpty) return;

    setState(() => _loadingMore = true);
    final page = await ref
        .read(transactionRepositoryProvider)
        .searchByCategoriesPaged(
          categoryIds: _categoryIds,
          query: _query,
          limit: _pageSize,
          offset: reset ? 0 : _transactions.length,
        );
    if (!mounted) return;
    setState(() {
      if (reset) _transactions.clear();
      _transactions.addAll(page);
      _hasMore = page.length == _pageSize;
      _loadingMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 500) {
      _loadPage();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
      _query = value.trim();
      await _loadPage(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayCurrency =
        ref.watch(displayCurrencyProvider).valueOrNull ??
        MoneyUtils.defaultCurrencyCode;
    final exchangeRates = ref.watch(exchangeRatesProvider).valueOrNull ?? {};
    final title = _category?.name ?? 'Category';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search transactions',
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: _transactions.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long,
                          title: _query.isEmpty
                              ? 'No transactions in this category'
                              : 'No matching transactions',
                          subtitle: _query.isEmpty
                              ? 'Transactions assigned to $title will appear here.'
                              : 'Try a different search.',
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount:
                              _transactions.length + (_loadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _transactions.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final t = _transactions[index];
                            final converted = MoneyUtils.convertMinor(
                              t.amountMinor,
                              fromCurrency: t.currencyCode,
                              toCurrency: displayCurrency,
                              rates: exchangeRates,
                            );
                            return TransactionTile(
                              id: t.id,
                              type: t.type,
                              amountMinor: t.amountMinor,
                              title: t.title,
                              date: t.date,
                              currencyCode: t.currencyCode,
                              displayAmountMinor: converted,
                              displayCurrencyCode: displayCurrency,
                              categoryName: _category?.name,
                              categoryColor: _category?.color == null
                                  ? null
                                  : Color(_category!.color!),
                              categoryIcon: _category?.icon,
                              onTap: () =>
                                  context.push('/transactions/${t.id}'),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

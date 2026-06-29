import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class WalletsScreen extends ConsumerStatefulWidget {
  const WalletsScreen({super.key});

  @override
  ConsumerState<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends ConsumerState<WalletsScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final walletsAsync = _showArchived
        ? ref.watch(allWalletsProvider)
        : ref.watch(activeWalletsProvider);
    final balancesAsync = ref.watch(walletBalancesProvider);
    final displayCurrencyAsync = ref.watch(displayCurrencyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.filter_alt_off : Icons.filter_alt),
            tooltip: _showArchived ? 'Hide archived' : 'Show archived',
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      body: walletsAsync.when(
        data: (wallets) {
          if (wallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text('No accounts yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => context.push('/wallets/new'),
                    child: const Text('Add Account'),
                  ),
                ],
              ),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            buildDefaultDragHandles: false,
            itemCount: wallets.length + 2,
            onReorderItem: (oldIndex, newIndex) async {
              if (oldIndex < 1 || oldIndex > wallets.length) return;
              if (newIndex < 1) return;
              if (newIndex > wallets.length) newIndex = wallets.length;
              int from = oldIndex - 1;
              int to = newIndex - 1;
              if (to > from) to--;
              final repo = ref.read(walletRepositoryProvider);
              final items = [...wallets];
              final item = items.removeAt(from);
              items.insert(to, item);
              await repo.updateSortOrders(items.map((w) => w.id).toList());
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildNetWorthCard(
                  const Key('networth'),
                  context,
                  wallets,
                  theme,
                  displayCurrencyAsync,
                );
              }
              if (index == wallets.length + 1) {
                return _buildAddWalletCard(context, theme);
              }
              if (index - 1 >= wallets.length) return const SizedBox.shrink();
              final wallet = wallets[index - 1];
              final balance =
                  balancesAsync.valueOrNull?[wallet.id] ??
                  wallet.initialBalanceMinor;
              return _buildWalletCard(
                Key('wallet_${wallet.id}'),
                context,
                wallet,
                balance,
                theme,
                index: index,
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildNetWorthCard(
    Key key,
    BuildContext context,
    List<Wallet> wallets,
    ThemeData theme,
    AsyncValue<String> displayCurrencyAsync,
  ) {
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final currencyCode =
        displayCurrencyAsync.valueOrNull ?? MoneyUtils.defaultCurrencyCode;
    return totalBalanceAsync.when(
      data: (total) => Card(
        key: key,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Worth',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                MoneyUtils.format(total, currencyCode: currencyCode),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${wallets.length} account${wallets.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      error: (_, _) => Card(
        key: key,
        margin: const EdgeInsets.only(bottom: 16),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Error loading balance'),
        ),
      ),
      loading: () => Card(
        key: key,
        margin: const EdgeInsets.only(bottom: 16),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: LinearProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildWalletCard(
    Key key,
    BuildContext context,
    Wallet wallet,
    int balance,
    ThemeData theme, {
    int index = 0,
  }) {
    final archived = wallet.archived;
    return Opacity(
      key: key,
      opacity: archived ? 0.55 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!archived)
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle, color: Colors.grey),
                ),
              if (!archived) const SizedBox(width: 4),
              CircleAvatar(
                backgroundColor: _walletColor(
                  wallet.type,
                ).withValues(alpha: 0.15),
                child: Icon(
                  _walletIcon(wallet.type),
                  color: _walletColor(wallet.type),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  wallet.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (archived) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Archived',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            '${wallet.type.replaceAll('_', ' ').toUpperCase()} \u2022 ${wallet.currencyCode}',
          ),
          trailing: Text(
            MoneyUtils.format(balance, currencyCode: wallet.currencyCode),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: balance >= 0 ? AppColors.income : AppColors.expense,
            ),
          ),
          onTap: () => context.push('/wallets/${wallet.id}'),
        ),
      ),
    );
  }

  Widget _buildAddWalletCard(BuildContext context, ThemeData theme) {
    final cs = theme.colorScheme;
    return Card(
      key: const Key('add_wallet'),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/wallets/new'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Add Account',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _walletColor(String type) {
    switch (type) {
      case 'checking':
        return AppColors.transfer;
      case 'savings':
        return AppColors.income;
      case 'cash':
        return AppColors.income;
      case 'credit_card':
        return AppColors.expense;
      case 'loan':
        return AppColors.expense;
      default:
        return AppColors.transfer;
    }
  }

  IconData _walletIcon(String type) {
    switch (type) {
      case 'checking':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'cash':
        return Icons.money;
      case 'credit_card':
        return Icons.credit_card;
      case 'loan':
        return Icons.account_balance_wallet;
      default:
        return Icons.account_balance;
    }
  }
}

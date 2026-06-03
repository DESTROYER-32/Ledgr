import 'package:drift/drift.dart' show Value;
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
  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(activeWalletsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: walletsAsync.when(
        data: (wallets) {
          if (wallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet,
                      size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No accounts yet',
                      style: theme.textTheme.titleMedium),
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
            itemCount: wallets.length + 1,
            onReorderItem: (oldIndex, newIndex) async {
              final repo = ref.read(walletRepositoryProvider);
              final items = [...wallets];
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
              for (var i = 0; i < items.length; i++) {
                await repo.update(
                  items[i].id,
                  WalletsCompanion(sortOrder: Value(i)),
                );
              }
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildNetWorthCard(
                    const Key('networth'), context, wallets, theme);
              }
              final wallet = wallets[index - 1];
              return _buildWalletCard(
                  Key('wallet_${wallet.id}'), context, wallet, theme,
                  index: index);
            },
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/wallets/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNetWorthCard(
      Key key, BuildContext context, List<Wallet> wallets, ThemeData theme) {
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    return totalBalanceAsync.when(
      data: (total) => Card(
        key: key,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Net Worth',
                  style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
              const SizedBox(height: 4),
              Text(MoneyUtils.format(total),
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  '${wallets.length} account${wallets.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall),
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
      Key key, BuildContext context, Wallet wallet, ThemeData theme,
      {int index = 0}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle,
                  color: Colors.grey),
            ),
            const SizedBox(width: 4),
            CircleAvatar(
              backgroundColor:
                  _walletColor(wallet.type).withValues(alpha: 0.15),
              child: Icon(_walletIcon(wallet.type),
                  color: _walletColor(wallet.type)),
            ),
          ],
        ),
        title: Text(wallet.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            wallet.type.replaceAll('_', ' ').toUpperCase()),
        trailing: Text(
          MoneyUtils.format(wallet.initialBalanceMinor),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: wallet.initialBalanceMinor >= 0
                ? AppColors.income
                : AppColors.expense,
          ),
        ),
        onTap: () => context.push('/wallets/${wallet.id}'),
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

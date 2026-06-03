import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wallets.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildNetWorthCard(context, wallets, theme);
              final wallet = wallets[index - 1];
              return _buildWalletCard(context, wallet, theme);
            },
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/wallets/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNetWorthCard(BuildContext context, List<Wallet> wallets, ThemeData theme) {
    final total = wallets.fold<int>(0, (sum, w) => sum + w.initialBalanceMinor);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Net Worth',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(MoneyUtils.format(total),
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${wallets.length} account${wallets.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, Wallet wallet, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _walletColor(wallet.type).withValues(alpha: 0.15),
          child: Icon(_walletIcon(wallet.type), color: _walletColor(wallet.type)),
        ),
        title: Text(wallet.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(wallet.type.replaceAll('_', ' ').toUpperCase()),
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
      case 'checking': return AppColors.transfer;
      case 'savings': return AppColors.income;
      case 'cash': return AppColors.income;
      case 'credit_card': return AppColors.expense;
      case 'loan': return AppColors.expense;
      default: return AppColors.transfer;
    }
  }

  IconData _walletIcon(String type) {
    switch (type) {
      case 'checking': return Icons.account_balance;
      case 'savings': return Icons.savings;
      case 'cash': return Icons.money;
      case 'credit_card': return Icons.credit_card;
      case 'loan': return Icons.account_balance_wallet;
      default: return Icons.account_balance;
    }
  }
}

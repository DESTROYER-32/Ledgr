import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money_utils.dart';

class WalletDetailScreen extends ConsumerWidget {
  final int walletId;
  const WalletDetailScreen({super.key, required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(activeWalletsProvider);
    final theme = Theme.of(context);

    return walletsAsync.when(
      data: (wallets) {
        final wallet = wallets.where((w) => w.id == walletId).firstOrNull;
        if (wallet == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Account')),
            body: const Center(child: Text('Account not found')),
          );
        }
        return _buildScaffold(context, ref, wallet, theme);
      },
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: Center(child: Text('$e')),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
    ThemeData theme,
  ) {
    final balanceAsync = ref.watch(walletBalancesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              final repo = ref.read(walletRepositoryProvider);
              if (v == 'archive') {
                await repo.archive(wallet.id);
                if (context.mounted) context.pop();
              } else if (v == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete account?'),
                    content: Text('Delete "${wallet.name}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await repo.delete(wallet.id);
                  if (context.mounted) context.pop();
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            balanceAsync.when(
              data: (balances) {
                final balance =
                    balances[wallet.id] ?? wallet.initialBalanceMinor;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MoneyUtils.format(
                            balance,
                            currencyCode: wallet.currencyCode,
                          ),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${wallet.currencyCode} \u2022 ${wallet.type.replaceAll('_', ' ').toUpperCase()}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
              error: (_, _) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Error loading balance'),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: LinearProgressIndicator(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      '/wallets/transfer',
                      extra: <String, dynamic>{'fromWalletId': wallet.id},
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('Transfer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/wallets/${wallet.id}/analytics'),
                    icon: const Icon(Icons.insights_outlined),
                    label: const Text('Analytics'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildTransactionList(context, ref, wallet)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/transactions/new',
          extra: <String, dynamic>{'walletId': wallet.id},
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) {
    final txStream = ref
        .read(transactionRepositoryProvider)
        .watchByWallet(wallet.id);
    return StreamBuilder(
      stream: txStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final transactions = snapshot.data!;
        if (transactions.isEmpty) {
          return Center(
            child: Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return ListView.separated(
          itemCount: transactions.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final t = transactions[i];
            final isExpense = t.type == 'expense';
            final isIncome = t.type == 'income';
            final color = isExpense
                ? AppColors.expense
                : (isIncome ? AppColors.income : AppColors.transfer);
            final sign = isExpense ? '-' : (isIncome ? '+' : '');
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(
                  isExpense
                      ? Icons.arrow_upward
                      : (isIncome ? Icons.arrow_downward : Icons.swap_horiz),
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(t.title ?? t.type),
              subtitle: Text(MoneyUtils.formatDateShort(t.date)),
              trailing: Text(
                '$sign${MoneyUtils.format(t.amountMinor)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              onTap: () => context.push('/transactions/${t.id}'),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter_test/flutter_test.dart';

import 'package:budgetly/core/database/app_database.dart';
import 'package:budgetly/core/database/repositories/wallet_repository.dart';
import 'package:budgetly/core/providers/providers.dart';

class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository(this.wallet, this.balance);

  final Wallet wallet;
  final int balance;

  @override
  Future<int> balanceForWallet(int walletId) async => balance;

  @override
  Future<Map<int, int>> balancesForWallets(Iterable<Wallet> wallets) async => {
    for (final wallet in wallets) wallet.id: balance,
  };

  @override
  Future<List<Wallet>> getAll() async => [wallet];

  @override
  Future<List<Wallet>> getActive() async => [wallet];

  @override
  Stream<List<Wallet>> watchActive() => Stream.value([wallet]);

  @override
  Stream<List<Wallet>> watchAll() => Stream.value([wallet]);

  @override
  Future<Wallet?> getById(int id) async => id == wallet.id ? wallet : null;

  @override
  Future<int> totalBalance({required String currencyCode}) async => balance;

  @override
  Future<int> insert(WalletsCompanion entry) => throw UnimplementedError();

  @override
  Future<void> update(int id, WalletsCompanion entry) =>
      throw UnimplementedError();

  @override
  Future<void> updateSortOrders(List<int> walletIds) =>
      throw UnimplementedError();

  @override
  Future<void> archive(int id) => throw UnimplementedError();

  @override
  Future<void> delete(int id) => throw UnimplementedError();
}

void main() {
  test('wallet balances stay in each wallet currency', () async {
    final now = DateTime(2026, 6, 6);
    final wallet = Wallet(
      id: 1,
      name: 'INR account',
      type: 'cash',
      currencyCode: 'INR',
      initialBalanceMinor: 123456,
      archived: false,
      sortOrder: 0,
      color: null,
      icon: null,
      createdAt: now,
      updatedAt: now,
    );
    final repository = FakeWalletRepository(wallet, 123456);

    final balances = await walletBalancesByWalletCurrency(repository);

    expect(balances[wallet.id], 123456);
  });
}

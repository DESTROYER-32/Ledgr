import '../database/repositories/wallet_repository.dart';

Future<Map<int, int>> walletBalancesByWalletCurrency(
  WalletRepository repo,
) async {
  final wallets = await repo.getAll();
  return repo.balancesForWallets(wallets);
}

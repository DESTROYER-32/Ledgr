import 'package:drift/drift.dart';

import '../app_database.dart';

class PortfolioRepository {
  PortfolioRepository(this._db);

  final AppDatabase _db;

  Stream<List<InvestmentHolding>> watchHoldings() =>
      (_db.investmentHoldings.select()
            ..orderBy([(h) => OrderingTerm(expression: h.tickerSymbol)]))
          .watch();

  Stream<List<InvestmentHolding>> watchByWallet(int walletId) =>
      (_db.investmentHoldings.select()
            ..where((h) => h.walletId.equals(walletId))
            ..orderBy([(h) => OrderingTerm(expression: h.tickerSymbol)]))
          .watch();

  Future<InvestmentHolding?> getHolding(int id) =>
      (_db.investmentHoldings.select()..where((h) => h.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertHolding(InvestmentHoldingsCompanion entry) =>
      _db.into(_db.investmentHoldings).insert(entry);

  Future<void> updateHolding(int id, InvestmentHoldingsCompanion entry) =>
      (_db.investmentHoldings.update()..where((h) => h.id.equals(id))).write(
        entry.copyWith(updatedAt: Value(DateTime.now())),
      );

  Future<void> deleteHolding(int id) =>
      (_db.investmentHoldings.delete()..where((h) => h.id.equals(id))).go();

  Future<int> insertTrade(PortfolioTransactionsCompanion entry) =>
      _db.into(_db.portfolioTransactions).insert(entry);

  Stream<List<PortfolioTransaction>> watchTrades(int holdingId) =>
      (_db.portfolioTransactions.select()
            ..where((t) => t.holdingId.equals(holdingId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .watch();
}

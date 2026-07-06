# Feature Implementation Plan

> Branch: `Feat` | Last updated: 2026-07-06

---

## Status Summary

| Feature | Status | Notes |
|---|---|---|
| Net Worth Tracking | ✅ Implemented | Current net worth, snapshots, history chart, dashboard card, monthly delta |
| Cash Flow Forecasting | ✅ Implemented | Overall + wallet forecasts, 30/60/90 selector, chart, upcoming list, safe-to-spend |
| Investment Portfolio Tracking | 🟡 V1 Implemented | Manual holdings/prices, summary, allocation chart, dashboard card |
| Live Market Prices | ⬜ Remaining | Yahoo Finance / CoinGecko integration not implemented yet |
| Trade Workflow | ⬜ Remaining | DB table exists, but buy/sell trade form and history UI are not implemented yet |

---

## Net Worth Tracking

**Goal:** Show assets − liabilities over time with a trend chart.

**Status:** ✅ Implemented

### Implemented

- `NetWorthSnapshots` table added.
- Drift migration added with schema version bump.
- Snapshot index added.
- `NetWorthSnapshotRepository` added.
- `net_worth_calculator.dart` added.
- `net_worth_providers.dart` added.
- `currentNetWorthProvider` added.
- `netWorthHistoryProvider` added.
- `netWorthMonthlyDeltaProvider` added.
- `net_worth_screen.dart` added.
- `net_worth_card.dart` added.
- Dashboard card added.
- `/net-worth` route added.
- Current assets/liabilities breakdown added.
- Trend chart added.
- Dashboard monthly delta added.

### Implemented data mapping

| Existing Data | Role |
|---|---|
| Wallets with positive balances | Assets |
| Credit/loan/negative-balance wallets | Liabilities |
| Loan objectives (`type='loan'`) | Liabilities |
| Goal objectives | Excluded |

### Implemented table

```text
NetWorthSnapshots
├── id
├── date
├── assetsMinor
├── liabilitiesMinor
├── netWorthMinor
├── currencyCode
└── detailsJson
```

### Remaining / Future polish

- Add a manual “save snapshot now” action if desired.
- Add configurable snapshot cadence if automatic daily updates are not enough.
- Add richer chart labels/tooltips if needed.

---

## Cash Flow Forecasting

**Goal:** Project future wallet balances based on upcoming + recurring transactions.

**Status:** ✅ Implemented

### Implemented

- `cash_flow_projector.dart` added.
- `cash_flow_providers.dart` added.
- `overallCashFlowProvider` added.
- `walletCashFlowProvider(walletId)` added.
- `cashFlowProjectionProvider(CashFlowRequest)` added.
- `cash_flow_screen.dart` added.
- `cash_flow_mini_card.dart` added.
- `upcoming_bill_tile.dart` added.
- Dashboard mini card added.
- `/cash-flow` route added.
- `/cash-flow/:id` wallet-specific route added.
- Account detail screen entry point added.
- 30/60/90 day range selector added.
- Safe-to-spend / lowest balance display added.
- Chart date labels added.
- Chart money-axis labels added.
- Chart tooltip added.
- Internal transfers are handled so overall cash flow is not distorted.

### Implemented data sources

| Source | Role |
|---|---|
| Future-dated `Transactions` | One-time future cash flow |
| Active `RecurringTransactions` | Generated projected occurrences |
| Current wallet balances | Starting point |

### Remaining / Future polish

- Add filtering by income/expense type.
- Add warning badges for negative projected balance.
- Add export/share forecast if useful.
- Add tests directly targeting `CashFlowProjector` edge cases.

---

## Investment Portfolio Tracking

**Goal:** Track stocks, ETFs, and crypto with cost basis, current value, and gain/loss.

**Status:** 🟡 V1 Implemented

### Implemented in V1

- `InvestmentHoldings` table added.
- `PortfolioTransactions` table added.
- Drift migration added with schema version bump.
- Portfolio indexes added.
- `PortfolioRepository` added.
- `portfolio_providers.dart` added.
- `portfolio_screen.dart` added.
- `holding_form_screen.dart` added.
- `holding_tile.dart` added.
- `allocation_chart.dart` added.
- `portfolio_mini_card.dart` added.
- `/portfolio` route added.
- `/portfolio/holdings/new` route added.
- `/portfolio/holdings/:id/edit` route added.
- Dashboard portfolio card added.
- Manual holdings supported.
- Manual current price supported.
- Cost basis supported.
- Gain/loss calculation supported.
- Allocation by asset type supported.
- Add Holding selectors now use themed `ModernSelectionField` controls.

### Implemented tables

```text
InvestmentHoldings
├── id
├── walletId
├── tickerSymbol
├── assetName
├── assetType
├── shares
├── avgCostBasisMinor
├── currencyCode
├── currentPriceMinor
├── lastPriceUpdate
├── createdAt
└── updatedAt
```

```text
PortfolioTransactions
├── id
├── holdingId
├── date
├── type
├── shares
├── pricePerShareMinor
├── feesMinor
└── notes
```

### Remaining

#### Live market prices

- Fetch stock/ETF prices from Yahoo Finance or another provider.
- Fetch crypto prices from CoinGecko.
- Cache fetched prices in `currentPriceMinor` and `lastPriceUpdate`.
- Add refresh button and stale-price indicator.
- Keep manual price fallback.

#### Trade workflow

- Add `trade_form_screen.dart`.
- Add buy/sell transaction UI.
- Add portfolio transaction history UI.
- Update holdings from trades.
- Recalculate shares and average cost basis after buys/sells.
- Handle fees.
- Handle sell validation so shares cannot go below zero.

#### Wallet types

- Add explicit investment/crypto wallet type options in the wallet form if the app should distinguish them.
- Decide whether portfolio holdings should be allowed on any wallet or only investment/crypto wallets.

#### Future analytics

- Portfolio value history chart.
- Allocation by ticker.
- Allocation by wallet.
- Realized vs unrealized gain/loss.
- Dividend/income support.

---

## Dashboard Integration

**Status:** 🟡 Mostly implemented

### Implemented

- Net Worth card added.
- Cash Flow Forecast card added.
- Portfolio card added.

### Remaining / Future polish

- Add dashboard customization or collapsing if the dashboard becomes too crowded.
- Add Settings menu links for Net Worth, Cash Flow, and Portfolio.
- Add Analytics tab entry for Net Worth if desired.
- Add Wallets tab entry for Portfolio if desired.

---

## Router Additions

### Implemented

```dart
GoRoute(path: '/net-worth', ...)
GoRoute(path: '/cash-flow', ...)
GoRoute(path: '/cash-flow/:id', ...)
GoRoute(path: '/portfolio', ...)
GoRoute(path: '/portfolio/holdings/new', ...)
GoRoute(path: '/portfolio/holdings/:id/edit', ...)
```

### Remaining

```dart
GoRoute(path: '/portfolio/trades/new', ...)
```

---

## Recent Bug Fixes

- Fixed recurring transaction amount prefix showing hardcoded `USD`.
- Recurring amount prefix now uses display currency before account selection and account currency after selection.
- Fixed recurring form keyboard/app-switch layout issue by dismissing focus on app lifecycle changes.
- Fixed cash flow chart plotting minor units instead of major currency units.
- Added date and money labels to cash flow chart.
- Replaced Add Holding raw dropdowns with themed modern selectors.

---

## Recommended Next Steps

1. Implement Portfolio trade workflow:
   - buy/sell form
   - transaction history
   - average cost basis recalculation
2. Add live price fetching:
   - Yahoo Finance for stocks/ETFs
   - CoinGecko for crypto
3. Add Settings and navigation links for the new feature screens.
4. Add focused unit tests for:
   - net worth snapshot upsert
   - cash flow projector edge cases
   - portfolio summary calculations

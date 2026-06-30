# Budgetly Verified Issue Plan

> Updated on 2026-06-30. Critical, medium, and fresh high-value scan findings have been addressed. The app is pre-release, so local schema downgrade from the short-lived schema v2 build is handled destructively for test databases while the canonical schema remains version 1.

## Status legend

- `[todo]` confirmed issue still present
- `[fixed]` code fix applied and validated
- `[defer]` valid issue but lower priority or needs product decision

---

## Critical

### 1. `[fixed]` Foreign keys missing delete actions

**File:** `budgetly/lib/core/database/tables.dart`

Fixed: required child rows cascade, nullable links set null, and generated Drift schema emits `ON DELETE` clauses.

### 2. `[fixed]` Raw SQL `whereClause` interpolation

**File:** `budgetly/lib/core/database/repositories/transaction_repository.dart`

Fixed: raw condition strings were replaced with typed `type` and optional `specialType` parameters passed as Drift SQL variables.

### 3. `[fixed]` Database close ownership ambiguity

**Files:** `budgetly/lib/core/providers/providers.dart`, `budgetly/lib/main.dart`

Fixed: `main()` overrides `appDatabaseProvider` with provider-owned disposal, and `BudgetlyApp` no longer manually closes the DB.

---

## Medium and fresh scan issues

### 1. `[fixed]` `_sumByCategory` excluded uncategorized transactions

Fixed: category totals include `NULL` category rows under `TransactionRepository.uncategorizedCategoryId`, and the dashboard chart labels them `Uncategorized`.

### 2. `[fixed]` History card hidden when previous period is zero

Fixed: removed the early return so `0 → current` is displayed as a valid previous-period state.

### 3. `[fixed]` Missing exchange rates silently faked converted values

Fixed: `convertMinor` throws on missing rates, `tryConvertMinor` returns `null`, and UI paths hide converted values when rates are unavailable.

### 4. `[fixed]` Currency conversion ignored non-2-decimal currencies

Fixed: `MoneyUtils.convertMinor`, `tryConvertMinor`, and `ExchangeRateService.convert` convert via source major units and target minor units. Added tests covering USD, JPY, and BHD.

### 5. `[fixed]` Forms and exports hardcoded `* 100` and `/ 100`

Fixed: transaction, recurring, wallet, budget, objective, onboarding, search, backup CSV, bill splitter, and balance correction paths now use `MoneyUtils.toMinor`, `toMajor`, or `toMajorText` where the value is money. Remaining `* 100` usages are percentages or timestamps.

### 6. `[fixed]` App lock could flash app content before lock state resolved

Fixed: the app builder renders a blank scaffold while lock state is loading.

### 7. `[fixed]` App lock refresh had no re-entrancy guard

Fixed: `refresh()` is guarded by an in-flight future.

### 8. `[fixed]` App lock failed-attempt rate limiting was in memory only

Fixed: failed attempts and lockout expiry are persisted in `SettingsRepository` and cleared on successful PIN, biometric unlock, PIN reset, and disable.

### 9. `[fixed]` Recurring transaction processing was not transactional

Fixed: each generated transaction and recurring schedule update happen inside one database transaction.

### 10. `[fixed]` `updatedAt` columns were not maintained on updates

Fixed: update/archive/sort-order repository paths now set `updatedAt` where the table has that column.

### 11. `[fixed]` `BudgetCategoryLimits` missing wallet-aware uniqueness

Fixed: table-level unique key preserves wallet-specific limits and a SQLite expression unique index on `COALESCE(wallet_id, -1)` prevents duplicate global limits with `walletId = NULL`.

### 12. `[fixed]` Budget delete was not transactional

Fixed: child cleanup and budget deletion run inside `_db.transaction()`.

### 13. `[fixed]` Dashboard pull-to-refresh was incomplete

Fixed: refresh invalidates balance, transaction, budget, wallet, recurring, chart, monthly summary, exchange-rate, and insights providers.

### 14. `[fixed]` Dashboard insights errors rendered empty UI

Fixed: insights now render a visible error card with recovery guidance.

### 15. `[fixed]` Dashboard insights went stale after transaction changes

Fixed: insights provider watches `allTransactionsProvider` and is invalidated by pull-to-refresh.

### 16. `[fixed]` Pre-release schema downgrade risk

Fixed: canonical schema is version 1 and `onUpgrade` handles `from > to` by destructively recreating the local pre-release database schema.

### 17. `[fixed]` Drift table list order did not put all parent tables first

Fixed: `Budgets` and `Objectives` now appear before child tables that reference them.

### 18. `[fixed]` `spentForBudget` applied redundant `includeIncome` filter

Fixed: removed the duplicate expense filter.

### 19. `[fixed]` Drift multiple database warning in widget tests

Fixed: transaction form widget tests now use the in-memory test provider scope, and shared test provider overrides own DB disposal.

---

## Low priority remaining cleanup

- `[todo]` No localization/i18n for hardcoded UI strings.
- `[todo]` Silent `catch (_) {}` blocks and weak structured logging.
- `[todo]` Hardcoded font sizes and semantic colors in selected widgets.
- `[todo]` Nested ternaries in multiple UI files.
- `[todo]` `Debouncer` is defined inside `search_screen.dart` instead of a reusable utility.
- `[todo]` Provider file mixes provider definitions and utility helpers.
- `[todo]` `mainCategoryPk` should be renamed to `parentCategoryId` with a schema reset or migration.
- `[todo]` `_QuickEntrySheet` stores a `BuildContext` field.
- `[todo]` `ShimmerLoading` can render with zero width.
- `[todo]` `amount_field.dart` parameter name says `currencySymbol` but expects a code.
- `[todo]` `modern_selection_field.dart` combines `DraggableScrollableSheet` and modal sheet dragging.
- `[todo]` `FormField.initialValue` can become stale in `modern_selection_field.dart`.
- `[todo]` Date formatting is inconsistent across files.
- `[todo]` Wallet balance conversion could batch conversions and skip same-currency conversions.

# Budgetly Verified Issue Plan

> Updated on 2026-06-30. Critical and medium findings from the prior scan have been addressed or intentionally scoped below. The app is pre-release, so the Drift database was reset to schema version 1 with fresh `onCreate` schema generation rather than maintaining upgrade migrations.

## Status legend

- `[todo]` confirmed issue still present
- `[fixed]` code fix applied and validated
- `[defer]` valid issue but lower priority or needs product decision

---

## Critical

### 1. `[fixed]` Foreign keys missing delete actions

**File:** `budgetly/lib/core/database/tables.dart`

Fixed:

- Required child rows in join/dependent tables use `KeyAction.cascade`.
- Nullable links use `KeyAction.setNull`.
- Generated Drift schema emits the expected `ON DELETE` clauses.

### 2. `[fixed]` Raw SQL `whereClause` interpolation

**File:** `budgetly/lib/core/database/repositories/transaction_repository.dart`

Fixed: raw condition strings were replaced with typed `type` and optional `specialType` parameters passed as Drift SQL variables.

### 3. `[fixed]` Database close ownership ambiguity

**Files:** `budgetly/lib/core/providers/providers.dart`, `budgetly/lib/main.dart`

Fixed: `main()` overrides `appDatabaseProvider` with provider-owned disposal, and `BudgetlyApp` no longer manually closes the DB.

---

## Medium

### 1. `[fixed]` `_sumByCategory` excluded uncategorized transactions

**File:** `budgetly/lib/core/database/repositories/transaction_repository.dart`

Fixed: category totals now include `NULL` category rows under `TransactionRepository.uncategorizedCategoryId`, and the dashboard chart labels them as `Uncategorized`.

### 2. `[fixed]` History card hidden when previous period is zero

**File:** `budgetly/lib/features/budgets/budget_detail_screen.dart`

Fixed: removed the early return so `0 → current` is displayed as a valid previous-period state.

### 3. `[fixed]` `convertMinor` silently returned unconverted amount when rates were missing

**File:** `budgetly/lib/core/utils/money_utils.dart`

Fixed: `convertMinor` now throws on missing rates, and `tryConvertMinor` returns `null` for UI paths that need a non-throwing check. Converted UI amounts are hidden when rates are unavailable instead of showing incorrect values.

### 4. `[fixed]` App lock could flash app content before lock state resolved

**Files:** `budgetly/lib/main.dart`, `budgetly/lib/core/security/app_lock_controller.dart`

Fixed: the app builder renders a blank scaffold while lock state is loading.

### 5. `[fixed]` App lock refresh had no re-entrancy guard

**File:** `budgetly/lib/core/security/app_lock_controller.dart`

Fixed: `refresh()` is guarded by an in-flight future.

### 6. `[fixed]` App lock failed-attempt rate limiting was in memory only

**Files:** `budgetly/lib/core/security/app_lock_controller.dart`, `budgetly/lib/features/security/app_lock_screen.dart`

Fixed: failed attempts and lockout expiry are persisted in `SettingsRepository` and cleared on successful PIN or biometric unlock.

### 7. `[fixed]` Recurring transaction processing was not transactional

**File:** `budgetly/lib/core/services/recurring_service.dart`

Fixed: each generated transaction and its recurring schedule update now happen inside one database transaction.

### 8. `[fixed]` `updatedAt` columns were not maintained on updates

**Files:** repository update methods for wallets, categories, transactions, budgets, and objectives.

Fixed: update/archive/sort-order repository paths now set `updatedAt` where the table has that column.

### 9. `[fixed]` `BudgetCategoryLimits` missing wallet-aware unique constraint

**File:** `budgetly/lib/core/database/tables.dart`

Fixed: `uniqueKeys => [{budgetId, categoryId, walletId}]`, preserving wallet-specific limits.

### 10. `[fixed]` Budget delete was not transactional

**File:** `budgetly/lib/core/database/repositories/budget_repository.dart`

Fixed: child cleanup and budget deletion run inside `_db.transaction()`.

### 11. `[fixed]` Dashboard pull-to-refresh was incomplete

**File:** `budgetly/lib/features/dashboard/dashboard_screen.dart`

Fixed: refresh invalidates balance, transaction, budget, wallet, recurring, chart, monthly summary, exchange-rate, and insights providers.

### 12. `[fixed]` Dashboard insights errors rendered empty UI

**File:** `budgetly/lib/features/dashboard/dashboard_screen.dart`

Fixed: insights now render a visible error card with recovery guidance.

### 13. `[fixed]` Dashboard insights went stale after transaction changes

**File:** `budgetly/lib/features/dashboard/dashboard_screen.dart`

Fixed: insights provider now watches `allTransactionsProvider` and is invalidated by pull-to-refresh.

### 14. `[fixed]` Migration strategy only handled `from < 2`

**File:** `budgetly/lib/core/database/app_database.dart`

Fixed for pre-release reset: schema version is back to `1`, `onUpgrade` was removed, and fresh installs use `onCreate/createAll` plus indexes.

### 15. `[fixed]` Drift table list order did not put all parent tables first

**File:** `budgetly/lib/core/database/app_database.dart`

Fixed: `Budgets` and `Objectives` now appear before child tables that reference them.

### 16. `[fixed]` `spentForBudget` applied redundant `includeIncome` filter

**File:** `budgetly/lib/core/database/repositories/budget_repository.dart`

Fixed: removed the duplicate expense filter.

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
- `[todo]` Fragile compound key parsing in budget screens.
- `[todo]` Hardcoded `* 100` and `/ 100` conversions remain in multiple screens and are wrong for non-2-decimal currencies.
- `[todo]` Wallet balance conversion could batch conversions and skip same-currency conversions.

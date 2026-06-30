# Budgetly Verified Issue Plan

> Verified against commit `f85e0a9` on 2026-06-30. This file is now a live fix plan, not a stale scan report.

## Status legend

- `[todo]` confirmed issue still present
- `[doing]` fix started in working tree
- `[fixed]` code fix applied, awaiting or passed validation
- `[defer]` valid issue but lower priority or needs product decision

---

## Critical

### 1. `[fixed]` Foreign keys missing delete actions

**File:** `budgetly/lib/core/database/tables.dart`

Confirmed: 17 Drift `references(...)` declarations had no `onDelete` or `onUpdate` behavior. This can cause FK crashes when parent rows are deleted.

Fix applied:

- Required child rows in join/dependent tables use `KeyAction.cascade`.
- Nullable links use `KeyAction.setNull`.
- `BudgetCategoryLimits` now has a unique key for `{budgetId, categoryId, walletId}` so wallet-specific limits can coexist.
- Drift generated schema now emits the expected `ON DELETE` clauses.

Validation:

- `dart run build_runner build --delete-conflicting-outputs` passed.
- `flutter analyze` passed.
- `flutter test` passed.
- Product review recommended for required `walletId` rows because cascade can delete transactions/recurrings if wallet hard-delete is exposed.

### 2. `[fixed]` Raw SQL `whereClause` interpolation

**File:** `budgetly/lib/core/database/repositories/transaction_repository.dart`

Confirmed: `_sumByCategory` and `_sumTotal` interpolated a raw `String whereClause` into SQL.

Fix applied:

- Replaced raw condition strings with typed parameters: `type` and optional `specialType`.
- Query values are now passed as Drift variables.

Validation: analyzer and tests pass.

### 3. `[fixed]` Database close ownership is ambiguous

**Files:**

- `budgetly/lib/core/providers/providers.dart`
- `budgetly/lib/main.dart`

Confirmed: provider-created databases close via `ref.onDispose(db.close)`, while the main app manually closes the override database in `BudgetlyApp.dispose()`. Current `main()` is safe because it uses `overrideWithValue`, but ownership is fragile.

Fixed:

- `main()` now overrides `appDatabaseProvider` with `overrideWith`, registers `ref.onDispose(db.close)`, and returns the app-created database.
- `BudgetlyApp` no longer receives or manually closes the database.
- Widget smoke test now follows the same provider-owned database pattern.

---

## Medium

### 1. `[todo]` `_sumByCategory` excludes uncategorized transactions

**File:** `budgetly/lib/core/database/repositories/transaction_repository.dart`

Confirmed: category summaries still filter `category_id IS NOT NULL`. Decide whether callers need a synthetic uncategorized bucket before changing return type.

### 2. `[todo]` History card hidden when previous period is zero

**File:** `budgetly/lib/features/budgets/budget_detail_screen.dart`

Confirmed: previous-period card hides on `_prevTotalSpent == 0`, conflating valid zero with no data.

### 3. `[todo]` `convertMinor` silently returns unconverted amount when rates are missing

**File:** `budgetly/lib/core/utils/money_utils.dart`

Confirmed: missing or invalid rates return the original amount. Needs a failure-reporting API or a logged fallback path.

### 4. `[todo]` App lock can flash app content before lock state resolves

**Files:**

- `budgetly/lib/main.dart`
- `budgetly/lib/core/security/app_lock_controller.dart`

Confirmed: `AppLockController.refresh()` starts asynchronously in the constructor, while the app can render before lock state is known.

### 5. `[todo]` App lock refresh has no re-entrancy guard

**File:** `budgetly/lib/core/security/app_lock_controller.dart`

Confirmed: concurrent `refresh()` calls are possible.

### 6. `[todo]` App lock failed-attempt rate limiting is in memory only

**File:** `budgetly/lib/features/security/app_lock_screen.dart`

Confirmed: `_failedAttempts` and `_lockedUntil` reset on process restart.

### 7. `[todo]` Recurring transaction processing is not transactional

**File:** `budgetly/lib/core/services/recurring_service.dart`

Confirmed: transaction insert and recurring schedule update are separate awaits. Crash between them can duplicate recurring entries.

### 8. `[todo]` `updatedAt` columns are not maintained on updates

**File:** `budgetly/lib/core/database/tables.dart` and repositories

Confirmed: `updatedAt` defaults only apply on insert. Source updates do not set `updatedAt`.

### 9. `[fixed]` `BudgetCategoryLimits` missing wallet-aware unique constraint

**File:** `budgetly/lib/core/database/tables.dart`

Fix applied with the FK work: `uniqueKeys => [{budgetId, categoryId, walletId}]`.

Note: the original report proposed `{budgetId, categoryId}`, but the existing product behavior and tests require wallet-specific limits to remain separate. SQLite unique indexes also permit duplicate `NULL` values, so repository-level upsert logic still prevents duplicate global rows.

### 10. `[fixed]` Budget delete is transactional

**File:** `budgetly/lib/core/database/repositories/budget_repository.dart`

Fixed: child-row cleanup and budget deletion now run inside `_db.transaction()`.

### 11. `[todo]` Dashboard pull-to-refresh is incomplete

**File:** `budgetly/lib/features/dashboard/dashboard_screen.dart`

Confirmed: refresh invalidates only a subset of dashboard dependencies.

### 12. `[todo]` Dashboard insights errors render empty UI

**File:** `budgetly/lib/features/dashboard/dashboard_screen.dart`

Confirmed: insights are read with `.valueOrNull` in the current code path, which hides errors instead of surfacing recovery UI.

### 13. `[todo]` Dashboard insights can go stale after transaction changes

**File:** `budgetly/lib/features/dashboard/dashboard_screen.dart`

Confirmed: no direct invalidation of `_dashboardInsightsProvider` on transaction mutations.

### 14. `[todo]` Migration strategy only handles `from < 2`

**File:** `budgetly/lib/core/database/app_database.dart`

Confirmed. Needs explicit migration steps as schema evolves.

### 15. `[todo]` Drift table list order does not put all parent tables first

**File:** `budgetly/lib/core/database/app_database.dart`

Confirmed: `Transactions` appears before `Objectives` despite referencing it. SQLite tolerates this, but order should be cleaned up.

### 16. `[fixed]` `spentForBudget` applied redundant `includeIncome` filter

**File:** `budgetly/lib/core/database/repositories/budget_repository.dart`

Fixed: removed the second `!budget.includeIncome` expense filter.

---

## Low priority confirmed cleanup

- `[todo]` No localization/i18n for hardcoded UI strings.
- `[todo]` Silent `catch (_) {}` blocks and weak structured logging.
- `[todo]` Hardcoded font sizes and semantic colors in selected widgets.
- `[todo]` Nested ternaries in multiple UI files.
- `[todo]` `Debouncer` is defined inside `search_screen.dart` instead of a reusable utility.
- `[todo]` Provider file mixes provider definitions and utility helpers.
- `[todo]` `mainCategoryPk` should be renamed to `parentCategoryId` with a migration.
- `[todo]` `_QuickEntrySheet` stores a `BuildContext` field.
- `[todo]` `ShimmerLoading` can render with zero width.
- `[todo]` `amount_field.dart` parameter name says `currencySymbol` but expects a code.
- `[todo]` `modern_selection_field.dart` combines `DraggableScrollableSheet` and modal sheet dragging.
- `[todo]` `FormField.initialValue` can become stale in `modern_selection_field.dart`.
- `[todo]` Date formatting is inconsistent across files.
- `[todo]` Fragile compound key parsing in budget screens.
- `[todo]` Hardcoded `* 100` and `/ 100` conversions remain in multiple screens and are wrong for non-2-decimal currencies.
- `[todo]` Wallet balance conversion could batch conversions and skip same-currency conversions.

---

## Immediate next fixes

1. Regenerate Drift code and fix any generator/analyzer errors.
2. Wrap `BudgetRepository.delete()` in a transaction.
3. Make recurring processing atomic, likely by injecting `AppDatabase` or adding a repository transaction helper.
4. Resolve database close ownership.
5. Add focused database tests for FK behavior, budget delete atomicity, and recurring duplicate prevention.

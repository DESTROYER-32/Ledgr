# Code Audit — Bugs & Issues

## 🔴 CRITICAL (data loss / crashes / security)

No known critical issues remain after the latest fix pass.

## 🟠 HIGH (incorrect behavior / runtime crashes)

| Issue | File | Lines | Details |
|-------|------|-------|---------|
| Floating-point currency arithmetic | 10+ files | various | `(double * 100).round()` causes off-by-1-cent errors (e.g., `1.15 → 114`) |
| Post-frame callback after disposal | `main.dart` | 47-51 | `ref.read()` after widget disposed throws |
| Database connection never closed | `main.dart` | 17-24 | Resource leak — `overrideWithValue` skips `onDispose` |
| `GoRouter` recreated on every invalidation | `app_router.dart` | 39-284 | Loses all navigation state when any provider changes |
| Budget calc always excludes debt/credit/income | `budget_repository.dart` | 140-152 | `type.equals('expense')` unconditionally applied before `includeIncome` check — logic broken |
| Historical rates silently use today's rates | `exchange_rate_service.dart` | 183-192 | `fetchRates()` saves under today's key but returns for requested `onDate` |
| Missing currency silently returns 1.0 | `exchange_rate_service.dart` | 192 | Unknown currency treated as equal to USD — financial error |
| String-encoded family keys with `DateTime.parse` | `providers.dart` | 300-335 | `key.split(',')` crashes on malformed keys |
| All rows fetched to sum in Dart | `transaction_repository.dart` | 147-229 | Should use SQL `SUM()`, `GROUP BY` instead |
| N+1 queries in wallet balance | `wallet_repository.dart` | 41-49 | 1+N queries instead of single query |
| `_autoCategorize` fires on every keystroke | `transaction_form_screen.dart` | 445 | No debounce — DB query per keystroke |
| `refresh()` re-locks app on every call | `app_lock_controller.dart` | 64-79 | No way to refresh without re-locking |
| `hasData` hides Insights card when all zero | `dashboard_screen.dart` | 880,1400-1404 | Brand-new user sees no Insights card |
| Wallet analytics chart capped at 6 months | `wallet_analytics_screen.dart` | 141-145 | Summary shows all-time but chart only plots 6mo |
| CSV import crashes if no wallets exist | `backup_screen.dart` | 437-439 | `wallets.first` throws `Bad state: No element` |
| Fire-and-forget async void callbacks | `backup_screen.dart` | 137-146,161-169 | Unhandled future rejections on save failures |
| `_runSearch()` called inside `setState` | `search_screen.dart` | 157-219 | Calling `setState` during `setState` is invalid |
| Empty `setState(() {})` before navigation | `onboarding_screen.dart` | 217 | Useless rebuild |

## 🟡 MEDIUM

| Issue | File | Lines | Details |
|-------|------|-------|---------|
| Non-normalized `budgetFks` stored as JSON/text | `tables.dart` | 52-53 | Violates 1NF; should be join table |
| Wallet-specific decimals should be currency-derived | `tables.dart` | 14 | `decimals` per-wallet allows inconsistencies |
| AMOLED theme wasteful ColorScheme computation | `app_theme.dart` | 27-51 | Computes 30+ colors then overrides 11 |
| Category colors exhaust at 12 | `app_theme.dart` | 189-202 | Categories 1 and 13 share the same color |
| Hardcoded `DateTime(2030)` in DatePickers | `transaction_form_screen.dart`, `transfer_form_screen.dart` | 469,147 | Y2K-style bug — expires in 2030 |
| `FutureBuilder` nested in Riverpod `Consumer` | `dashboard_screen.dart` | 438-500,604-648,876-926 | New Future on every rebuild |
| `intl` decimal digits hardcoded to 2 for all currencies | `money_utils.dart` | 12,23 | JPY shows `¥1.00` instead of `¥1`, BHD shows wrong values |
| `formatCompact` uses English-centric abbreviations | `money_utils.dart` | 34,37 | "M"/"K" hardcoded regardless of locale |
| `monthEnd` uses day-0 hack | `money_utils.dart` | 88-89 | `DateTime(year, month+1, 0)` is non-obvious |
| TOCTOU race in settings upsert | `settings_repository.dart` | 17-27 | Race between select and insert |
| `watchActive().first` wasteful Stream subscriptions | `budget_detail_screen.dart` | 47,150,176-177 | Should use Future-based getters instead |
| Budget `spent/planned` clamp inconsistent | `budget_detail_screen.dart` | 231,519 | 2.0 (text) vs 1.0 (progress bar) |
| Division by zero in percentage display | `objective_detail_screen.dart` | 114 | If `amountMinor == 0`, shows `NaN%` |
| False empty state during loading | `objective_detail_screen.dart` | 30-34 | Shows "No transactions" while still loading |
| N+1 queries for objective progress | `objectives_list_screen.dart` | 174-209 | Separate `FutureBuilder` per objective |
| `double.parse` can throw FormatException | `objective_form_screen.dart` | 207-209 | Unhandled exception on invalid input |
| Sequential DB updates in reorder loop | `wallets_screen.dart` | 79-84 | N updates for N wallets |
| No form validation in transfer form | `transfer_form_screen.dart` | 41-54 | Inline imperative checks instead of `Form` widget |
| `firstWhere` throws StateError | `transfer_form_screen.dart` | 57 | Should use `firstWhereOrNull` |
| `_specialType` silently transforms data | `transaction_form_screen.dart` | 91-92 | `repetitive` → `scheduled` silently |
| `AppColors.soft` variants light-mode only | `app_theme.dart` | 182-184 | Invisible on dark backgrounds |
| `Wallet` color `Color(0)` creates transparent widget | multiple files | various | ARGB = 0x00000000 is invisible |
| No loading indicator during mutations | multiple files | various | User can tap save multiple times |
| Unsafe `snapshot.data!` in FutureBuilders | `objectives_list_screen.dart` | 180 | Crashes if data is null |
| `associated_titles_screen.dart` uses `dynamic` throughout | `associated_titles_screen.dart` | 32-33,51-67 | Zero compile-time type safety |
| `_topEntries` duplicated in two files | `wallet_detail_screen.dart`, `wallet_analytics_screen.dart` | 1326,488 | DRY violation |
| `multiWalletBalance` sums different currencies | `wallet_repository.dart` | 46 | 100 USD + 100 EUR = 200 (meaningless) |
| Synchronous call `NotificationService.init()` no catch | `main.dart` | 15 | Crash on notification init failure |
| `repetitive` → `scheduled` in form silently loses data | `transaction_form_screen.dart` | 91-92 | Data-altering behavior with no user awareness |
| Exchange rate `ratio()` fetches sequentially | `exchange_rate_service.dart` | 197-198 | Could be parallelized with `Future.wait` |
| No `mounted` check after async in `Switch.onChanged` | `recurring_screen.dart` | 93-101 | No rollback if DB update fails |

## 🔵 LOW (code smells / style)

| Issue | File | Lines | Details |
|-------|------|-------|---------|
| Utility functions in providers file | `providers.dart` | 148-162,280-290 | `currencyOptionsWithSelection`, `walletBalancesByWalletCurrency` |
| `mainCategoryPk` misleading column name | `tables.dart` | 26-27 | `Pk` suffix implies primary key; should be `parentId` |
| `ref.watch` on singletons instead of `ref.read` | `providers.dart` | ~30 locations | Unnecessary subscription overhead |
| `app_router.dart` has no `errorBuilder` | `app_router.dart` | entire file | Blank screen on undefined routes |
| Hardcoded `Colors.red`/`Colors.green` instead of theme | `wallet_analytics_screen.dart` | 100,386,227-252 | Bypasses theming system |
| Nested ternary chains instead of switch expressions | multiple files | various | Harder to read and maintain |
| `SizedBox.shrink()` in error handlers | multiple files | 10+ locations | Errors silently swallowed; no logging |
| `key.split(',').map(...)` fragile parsing | `budget_detail_screen.dart`, `budgets_screen.dart` | 4+ locations | DRY violation; trailing comma edge case |
| `Debouncer` defined in screen file | `search_screen.dart` | 13-28 | Reusable utility trapped in a screen file |
| Manual date formatting instead of `DateFormat` | `backup_screen.dart`, `search_screen.dart`, `objective_form_screen.dart` | various | 4 different formatting approaches |
| Inconsistent date formatting across project | multiple files | various | `MoneyUtils.formatDate`, `DateFormat`, manual concat, `toString().split(' ')` |
| No localization — all strings hardcoded English | all files | all | Cannot be translated |
| No error logging in catch blocks | multiple files | various | Debugging production issues impossible |
| `_QuickEntrySheet` stores `BuildContext` as field | `app_scaffold.dart` | 105 | Anti-pattern — fragile if callback fires after disposal |
| `DraggableScrollableSheet` nested in `showModalBottomSheet` | `modern_selection_field.dart` | 178 | Two competing drag systems |
| `FormField` `initialValue` never updates | `modern_selection_field.dart` | 51 | Stale `FormFieldState` value |
| `balance_card.dart` gradient blends to wrong surface | `balance_card.dart` | 37-38 | Visible hard edge inside card |
| `transaction_tile.dart` hardcoded font sizes | `transaction_tile.dart` | 90-155 | Ignores system font-size accessibility |
| `stat_tile.dart` hardcoded font size 14 | `stat_tile.dart` | 39-42 | Ignores theme text styles |
| `ShimmerLoading` zero-width invisible without `width` | `shimmer_loading.dart` | 10-11 | Silent no-op |
| `category_icon_utils.dart` null param silently falls through | `category_icon_utils.dart` | 3-41 | Null maps to "category" without logging |
| bare `catch (_)` in multiple locations | multiple files | various | Hides programming errors |
| `amount_field.dart` misleading `currencySymbol` param | `amount_field.dart` | 8,15 | Actually expects a currency code, not a symbol |
| `symbolFor` returns `String?` but never null | `currency_utils.dart` | 174 | Dead `??` at all call sites |
| `CurrencyUtils` O(n) linear scan on every symbol lookup | `currency_utils.dart` | 176 | Should use `Map` for O(1) lookup |
| No `.gitignore` for `*.g.dart` generated files | `.gitignore` | — | Generated drift/riverpod files tracked in git |

## Cross-Cutting

| Issue | Impact |
|-------|--------|
| No localization / i18n | App cannot be translated; every string is hardcoded English |
| No error logging | `catch` blocks show snackbars but never log — production debugging impossible |
| No loading states on mutations | Users can double-tap save; no feedback during long saves |
| Inconsistent currency symbol resolution | 3 different mechanisms (`CurrencyUtils`, `MoneyUtils._symbol`, `NumberFormat`) may give different results |
| `FlutterLocalNotificationsPlugin` iOS class deprecated | `IOSFlutterLocalNotificationsPlugin` renamed to `DarwinFlutterLocalNotificationsPlugin` in v14+ |

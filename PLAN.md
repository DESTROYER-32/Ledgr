# Code Audit — Bugs & Issues

## 🔴 CRITICAL (data loss / crashes / security)

No known critical issues remain after the latest fix pass.

## 🟠 HIGH (incorrect behavior / runtime crashes)

No known high-priority issues remain after the latest fix pass.

## 🟡 MEDIUM

| Issue | File | Lines | Details |
|-------|------|-------|---------|
| Wallet-specific decimals should be currency-derived | `tables.dart` | 14 | `decimals` per-wallet allows inconsistencies |
| AMOLED theme wasteful ColorScheme computation | `app_theme.dart` | 27-51 | Computes 30+ colors then overrides 11 |
| `monthEnd` uses day-0 hack | `money_utils.dart` | 88-89 | `DateTime(year, month+1, 0)` is non-obvious |
| `watchActive().first` wasteful Stream subscriptions | `budget_detail_screen.dart` | 47,150,176-177 | Should use Future-based getters instead |
| Sequential DB updates in reorder loop | `wallets_screen.dart` | 79-84 | N updates for N wallets |
| No loading indicator during mutations | multiple files | various | User can tap save multiple times |
| `_topEntries` duplicated in two files | `wallet_detail_screen.dart`, `wallet_analytics_screen.dart` | 1326,488 | DRY violation |
| Exchange rate `ratio()` fetches sequentially | `exchange_rate_service.dart` | 197-198 | Could be parallelized with `Future.wait` |

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

# Code Quality Backlog

All previously identified functional/data correctness issues have been fixed. No known critical, high, or medium severity bugs remain in this audit snapshot.

The remaining work is low-severity code quality, maintainability, accessibility, and polish.

## 🔵 LOW — Code smells / maintainability

| Issue | File | Lines | Details |
|-------|------|-------|---------|
| AMOLED theme wasteful `ColorScheme` computation | `budgetly/lib/core/theme/app_theme.dart` | 27-51 | Calls `ColorScheme.fromSeed()` to generate the full dark scheme, then immediately overrides 11 colors. This is harmless but wasteful and less explicit than a purpose-built AMOLED scheme helper. |
| No localization / i18n | multiple files | various | UI strings are hardcoded English, so the app cannot be translated without a larger extraction pass. |
| No structured error logging | multiple files | various | Many `catch` blocks intentionally keep the UI alive but discard error details, making production debugging harder. |
| Hardcoded font sizes | `transaction_tile.dart`, `stat_tile.dart`, others | various | Some widgets use fixed sizes instead of theme text styles, which can reduce accessibility with larger system fonts. |
| `Debouncer` defined in a screen file | `budgetly/lib/features/search/search_screen.dart` | 13-28 | Reusable utility is scoped to a feature screen instead of a shared utility module. |
| Utility functions live in providers file | `budgetly/lib/core/providers/providers.dart` | various | Non-provider helpers such as currency/wallet utility logic make the providers file broader than necessary. |
| `mainCategoryPk` column name is misleading | `budgetly/lib/core/database/tables.dart` | 25-26 | Name implies a primary key. A future migration could rename it to `parentCategoryId` or similar for clarity. |
| Hardcoded semantic colors | selected feature screens | various | Some UI uses direct red/green colors instead of theme roles, which may clash with custom themes. |
| Nested ternary chains | multiple files | various | Some UI state rendering would be clearer with switch expressions or small helper methods. |
| Fragile compound-key parsing | budget screens | various | Repeated `split(',')` parsing should be replaced with a small typed key object/helper. |
| Manual/inconsistent date formatting | multiple files | various | The app mixes `MoneyUtils`, `DateFormat`, manual string concat, and `toString().split(' ')`. |
| `_QuickEntrySheet` stores `BuildContext` as a field | `budgetly/lib/core/widgets/app_scaffold.dart` | ~105 | Works today, but storing context outside immediate build/callback scope is fragile. |
| `DraggableScrollableSheet` inside `showModalBottomSheet` | `budgetly/lib/core/widgets/modern_selection_field.dart` | ~178 | Two drag systems can make behavior harder to tune. |
| `FormField.initialValue` can become stale | `budgetly/lib/core/widgets/modern_selection_field.dart` | ~51 | Parent value changes may not always sync into the internal `FormFieldState`. |
| `ShimmerLoading` can render zero width | `budgetly/lib/core/widgets/shimmer_loading.dart` | 10-11 | Missing width can silently produce an invisible placeholder. |
| Ambiguous parameter naming | `budgetly/lib/core/widgets/amount_field.dart` | 8,15 | `currencySymbol` actually expects a currency code. Rename to avoid confusion. |

## Notes

- These are not release blockers.
- Prioritize items only when touching nearby code, except localization and logging, which need coordinated project-wide decisions.
- The AMOLED item is the only remaining clearly technical inefficiency from the latest audit pass.

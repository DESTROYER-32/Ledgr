# Budget App — Full Feature Plan

This document describes all features to build a personal budget and financial tracking Flutter app. Features are categorized as **MVP** (already partially built), **Phase 2** (gap features ported from Cashew), and **Phase 3** (advanced/cloud/monetization).

## Product Goal

Build a mobile-first personal finance app that helps users understand their money quickly: what they have, what they spent, what is coming up, and whether they are staying inside their budget.

The app should prioritize fast daily use over complex accounting. A user should be able to add a transaction in a few seconds, review this month's budget at a glance, and trust that their data can be backed up or exported.

## Target Platforms

- Primary: Android and iOS.
- Secondary: Web, useful for wider access and easier testing.
- Recommended framework: Flutter with Dart, because one codebase can cover Android, iOS, and web while still supporting native integrations when needed.

## Recommended Stack

- UI framework: Flutter.
- Language: Dart.
- Local database: SQLite.
- Dart database layer: Drift ORM.
- State management: Riverpod (used throughout).
- Charts: `fl_chart` for pie charts, line graphs, bar graphs, heatmap, net worth over time, and budget trend visuals.
- Local persistence for small settings: `shared_preferences`.
- File import/export: CSV support plus full database backup/restore.
- Authentication and cloud sync: Firebase Auth and Cloud Firestore (Phase 3).
- Push/local notifications: Flutter local notifications for bill reminders and recurring transaction alerts.
- Security: device biometrics/local auth for optional app lock.
- Localization: `easy_localization` for multi-language support (Phase 2).
- In-app purchases: `in_app_purchase` for premium subscriptions (Phase 3).
- Google APIs: `google_sign_in`, `googleapis` for Drive backup sync and Gmail scanning (Phase 3).

## Core Concepts

- Wallet/account: a place where money is stored or owed, such as cash, checking account, savings account, credit card, or loan.
- Transaction: a money movement. Types: expense, income, transfer + special types (upcoming, subscription, repetitive, credit/debt).
- Transaction special types: Upcoming (scheduled future), Subscription (recurring payment), Repetitive (repeat on schedule), Credit (lent money), Debt (borrowed money).
- Category: a user-facing group for transactions, such as groceries, rent, salary, subscriptions, or transport.
- Subcategory: a child category under a main parent category (`mainCategoryPk`).
- Auto-categorization (smart labels): keyword-to-category mapping that auto-assigns categories on new transactions.
- Budget: a spending plan for a period (daily, weekly, monthly, yearly, custom).
- Budget category limit: the planned amount for one category inside a budget.
- Budget transaction filters: income, debt, balance correction, excluded budgets, shared budgets, watched categories.
- Recurring transaction: a repeated bill, subscription, salary, transfer, or reminder.
- Objective/goal: a savings or payoff target. Supports goals and loans.
- Loan/debt tracking: lent/borrowed money with paired transactions and installment tracking.
- Bill splitting: dividing a single expense across multiple people.
- Attachment: photo or file attached to a transaction (uploaded via Google Drive or local).
- Activity log: recently deleted transactions cache with restore capability.
- Note/tag: optional metadata that helps users find or explain transactions later.
- Exchange rate: currency conversion rate between currency pairs.

## Phase 2 Features (Gap from Cashew)

### 12. Categories — Advanced
- Subcategories: `mainCategoryPk` on categories table for parent-child hierarchy.
- Auto-categorization: `associated_titles` table mapping keywords to categories. On transaction creation, auto-assign category if title matches a keyword.

### 13. Transaction Special Types
- Support `specialType` field: `none` (default), `upcoming`, `subscription`, `repetitive`, `credit`, `debt`.
- Dedicated views for each type: Subscriptions page, Upcoming/Overdue page, Credit/Debt page.
- Upcoming transactions appear as scheduled entries that become real transactions on due date.
- Subscription transactions with configurable renewal periods.
- Credit (lent) and Debt (borrowed) with paired transactions for tracking repayments.

### 14. Loan/Debt Tracking (Objectives)
- `objectives` table replaces the simple `goals` table.
- Two objective types: `goal` (savings target) and `loan` (money lent or borrowed).
- For loans: track full amount lent/borrowed, link transactions as repayments, show remaining balance.
- Installments: paired transactions showing each repayment installment.
- Dedicated credit/debt transactions view.

### 15. Bill Splitter
- Add items with costs; add people to split with.
- Even split or custom percentage split per person.
- Calculate per-person totals and create transactions for each person's share.
- Full save/load of bill split state.

### 16. Transaction Activity Log
- Cache deleted transactions (up to 50) in SharedPreferences or a `delete_logs` table.
- Activity page showing recently deleted entries with timestamps.
- Restore deleted transactions with full metadata.

### 17. Attachments
- Attach photos (camera/gallery) or files to transactions.
- Upload to Google Drive for cloud storage, or store locally.
- Attachment preview on transaction detail.

### 18. Configurable Home Page (Dashboard)
- 13 widget types: wallet switcher, wallets list, pinned budgets, objectives, credit/debts, spending summary, net worth graph, line graph, pie chart, heatmap, upcoming transactions, transactions list, greeting banner.
- Drag-to-reorder widgets.
- Full-screen double-column layout option.
- Per-widget visibility toggles and cycle period settings (all time, custom, monthly, yearly).

### 19. Spending Heatmap
- Calendar heatmap showing daily spending intensity.
- Color-coded by spending amount relative to average.

### 20. Net Worth Over Time Graph
- Line chart tracking net worth across selected time periods.
- Multi-wallet net worth calculation.

### 21. Past Budget History
- Track historical budget periods with line graphs.
- Compare spending across months.
- View previous budget performance.

### 22. Multi-Wallet Budgets + Advanced Filters
- Budgets can span multiple wallets.
- Advanced budget transaction filters: exclude income, exclude debt/credit, exclude balance correction, exclude transactions in other budgets, member-only transactions for shared budgets.
- Absolute spending limit toggle.
- Watched categories on budget.

### 23. Number Format Customization
- Custom delimiter character, decimal character.
- Currency position (before/after amount).
- Compact/short format (e.g., $1.2K).
- Percentage precision (decimal places).
- 12h/24h clock format selection.

### 24. Font + Animation + Icon Customization
- Font selection: Avenir, DM Sans, Metropolis, Roboto Condensed, Inconsolata, Platform (system).
- Animation speed slider (time dilation).
- Animation modes: All / Minimal.
- Icon style: Rounded vs outlined toggle.
- Haptic feedback on interactions.

### 25. Auto-Transactions (Email)
- Gmail API integration (`googleapis/gmail/v1`).
- Scanner templates: pattern-based extraction (contains, title before/after, amount before/after).
- Queue transactions from email content.
- Default category and wallet assignment per template.

### 26. Auto-Transactions (Notification Listener)
- Android notification listener service.
- Capture payment notifications from banking/bill apps.
- Auto-create transactions from notification content.

### 27. Localization (Multi-Language)
- `easy_localization` integration.
- Language picker in settings.
- Community translation support.
- RTL layout support.

### 28. Preview Demo Data
- Generate realistic sample transactions, wallets, categories, budgets for testing.
- Demo mode toggle to switch between demo and real data.

## Phase 3 Features (Cloud & Monetization)

### 29. Google Drive Sync
- Multi-device backup sync via Google Drive API.
- Sync-on-change (every mutation triggers sync).
- Pull-to-refresh sync.
- Device-based backup naming with timestamps.
- Sync debouncing (5-second debounce).

### 30. Firebase Auth + Shared Budgets
- Google Sign-In via Firebase Auth.
- Share budgets with other users via Cloud Firestore.
- Owner/member roles with per-member transaction filters.
- Real-time budget sync across users.

### 31. Premium / In-App Purchases
- Yearly, monthly, and lifetime subscription tiers.
- Premium feature gating logic.
- Premium popup after N transaction additions.

### 32. Android Home Screen Widgets
- Net worth total widget.
- Widget theme (app theme / light / dark).
- Widget background opacity.

### 33. Deep Linking & Quick Actions
- Handle incoming app links for deep navigation.
- iOS quick actions / Android shortcuts.
- Configurable keyboard shortcuts (Ctrl+N for new transaction).

### 34. Platform Features
- High refresh rate (90/120Hz) on supported Android displays.
- Timezone-aware notifications.
- Incognito keyboard mode.

## Suggested Data Model

Use SQLite with Drift. Store money as integer minor units, such as cents, not floating-point values.

### Existing Tables (Extended)

- `wallets`
  - `id`, `name`, `type`, `currencyCode`, `initialBalanceMinor`, `archived`, `sortOrder`, `color`, `icon`, `decimals`, `createdAt`, `updatedAt`

- `categories`
  - `id`, `name`, `icon`, `color`, `kind` (income/expense/both), `mainCategoryPk` (nullable, for subcategories), `archived`, `sortOrder`, `createdAt`, `updatedAt`

- `transactions`
  - `id`, `type` (expense/income/transfer), `specialType` (none/upcoming/subscription/repetitive/credit/debt), `amountMinor`, `currencyCode`, `date`, `walletId`, `transferWalletId`, `categoryId`, `title`, `note`, `tags`, `recurrenceRule`, `budgetFksExclude`, `objectiveFk`, `attachmentPath`, `sharedKey`, `sharedStatus`, `sharedDateUpdated`, `methodAdded`, `createdAt`, `updatedAt`

- `budgets`
  - `id`, `name`, `amount`, `color`, `periodStart`, `periodEnd`, `currencyCode`, `recurrenceRule`, `pinned`, `archived`, `includeIncome`, `includeDebtCredit`, `includeBalanceCorrection`, `includeInOtherBudgets`, `absoluteLimit`, `createdAt`, `updatedAt`

- `budget_category_limits`
  - `id`, `budgetId`, `categoryId`, `walletId`, `plannedAmountMinor`

- `budget_wallets` (new join table)
  - `budgetId`, `walletId`

- `recurring_transactions`
  - `id`, `transactionType`, `specialType`, `amountMinor`, `walletId`, `transferWalletId`, `categoryId`, `title`, `note`, `scheduleRule`, `startDate`, `endDate`, `nextDueDate`, `active`

- `settings`
  - `key`, `value`

### New Tables

- `objectives`
  - `id`, `name`, `type` (goal/loan), `amountMinor`, `walletId`, `color`, `icon`, `emojiIcon`, `deadline`, `pinned`, `archived`, `sortOrder`, `createdAt`, `updatedAt`

- `associated_titles` (smart labels)
  - `id`, `title`, `categoryId`, `exactMatch`

- `scanner_templates` (email scanning)
  - `id`, `name`, `contains`, `titleBefore`, `titleAfter`, `amountBefore`, `amountAfter`, `defaultCategoryId`, `walletId`

- `delete_logs` (activity log)
  - `id`, `type`, `jsonData`, `deletedAt`

- `exchange_rates`
  - `id`, `fromCurrency`, `toCurrency`, `rate` (already exists)

## Build Order

### Phase 1 (MVP — existing, stabilize)
1. Flutter project setup and configuration.
2. App theming, navigation (GoRouter), settings storage.
3. Drift/SQLite initial schema + migrations.
4. Onboarding + starter categories + first wallet.
5. Wallet list, detail, balance calculation.
6. Transaction entry + transaction list.
7. Category management (flat).
8. Monthly budget creation + budget review.
9. Dashboard (fixed layout).
10. Search and filters.
11. Recurring transactions + upcoming reminders.
12. CSV import/export + full backup/restore.
13. App lock + notification settings.

### Phase 2 (Gap features — this sprint)
14. Add `mainCategoryPk` to categories → subcategories UI.
15. Add `associated_titles` table → auto-categorization UI.
16. Add `specialType` to transactions → upcoming/subscription/repetitive/credit/debt.
17. Add `objectives` table → goals + loan/debt tracking (replace simple goals).
18. Add bill splitter page and logic.
19. Add `delete_logs` table → activity log with restore.
20. Add attachment support to transactions.
21. Add configurable home page with 13 widget types + drag-to-reorder.
22. Add spending heatmap + net worth over time graph.
23. Add past budget history with line graphs.
24. Add multi-wallet budgets + advanced budget filters.
25. Add number format customization (delimiter, decimal, compact, clock).
26. Add font selection + animation speed + icon style toggle + haptic feedback.
27. Add localization + RTL support.
28. Add preview demo data generation.

### Phase 3 (Cloud & Monetization)
29. Add Gmail auto-transactions + scanner templates.
30. Add notification listener auto-transactions.
31. Add Google Drive sync + Firebase Auth + shared budgets.
32. Add Android home screen widgets.
33. Add deep linking + quick actions.
34. Add high refresh rate + timezone support.
35. Add premium/in-app purchases.

## UX Principles

- Mobile-first: important actions should be reachable with one hand.
- Fast entry: adding a transaction should feel faster than opening a spreadsheet.
- Dense but readable: finance apps are used repeatedly, so avoid oversized marketing-style layouts.
- Clear money states: income, expense, transfer, debt, and available balance must not be visually ambiguous.
- Trustworthy data handling: backup, restore, and export should be easy to find and easy to verify.
- Local-first by default: core tracking should work without an account or internet connection.

## Verification Checklist

- Run `flutter pub get` after dependency changes.
- Run `flutter analyze` before merging changes.
- Add unit tests for money math, date ranges, recurring schedules, CSV parsing, budget calculations, smart label matching, bill splitter math.
- Add widget tests for transaction entry, budget review, onboarding, category subcategory selection, auto-categorization.
- Test transaction special type filtering (upcoming, subscription, credit, debt).
- Test bill splitter calculations with even and custom splits.
- Test auto-categorization keyword matching (exact and substring).
- Test activity log delete/restore flow.
- Test email scanner template pattern matching.
- Test shared budget member permissions.
- Test multi-language locale switching.
- Test premium feature gating.
- Test backup/restore with realistic data.
- Test transaction entry and budget review on a small phone viewport.
- Test web only after mobile core behavior is solid.
- For database migrations, test upgrading from at least one previous schema version.

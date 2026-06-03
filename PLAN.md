# Budget App Greenfield Plan

This document describes how to build a personal budget and financial tracking app from scratch. It assumes there is no existing reference code.

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
- State management: Provider, Riverpod, or Bloc. Pick one and use it consistently; Provider or Riverpod is enough for the MVP.
- Charts: `fl_chart` for pie charts, line graphs, bar graphs, and budget trend visuals.
- Local persistence for small settings: `shared_preferences`.
- File import/export: CSV support plus full database backup/restore.
- Authentication and cloud sync, optional after MVP: Firebase Auth and Cloud Firestore.
- Push/local notifications: Flutter local notifications for bill reminders and recurring transaction alerts.
- Security: device biometrics/local auth for optional app lock.
- Localization: Flutter localization from the start if the app will support multiple regions or currencies.

## Core Concepts

- Wallet/account: a place where money is stored or owed, such as cash, checking account, savings account, credit card, or loan.
- Transaction: a money movement. Types should include expense, income, and transfer.
- Category: a user-facing group for transactions, such as groceries, rent, salary, subscriptions, or transport.
- Budget: a spending plan for a period, usually monthly.
- Budget category limit: the planned amount for one category inside a budget.
- Recurring transaction: a repeated bill, subscription, salary, transfer, or reminder.
- Objective/goal: an optional savings or payoff target.
- Attachment/note/tag: optional metadata that helps users find or explain transactions later.

## MVP Features

1. Onboarding
   - Let the user choose currency and basic preferences.
   - Create one initial wallet/account.
   - Install starter categories that the user can edit later.
   - End onboarding on the dashboard with a clear action to add the first transaction.

2. Wallets/accounts
   - Create, edit, archive, and reorder wallets.
   - Track current balance.
   - Support common wallet types: cash, bank, credit card, savings, loan, and custom.
   - Show total net worth across selected wallets.

3. Transactions
   - Add expense, income, and transfer transactions.
   - Required fields: amount, date, wallet, transaction type.
   - Common optional fields: category, title/payee, note, tags.
   - Support editing, deleting, duplicating, and searching transactions.
   - Make entry fast on mobile with numeric keypad behavior, sensible defaults, and minimal required taps.

4. Categories
   - Provide editable default categories.
   - Support category name, color, icon, and income/expense usage.
   - Allow users to archive categories without destroying transaction history.

5. Monthly budget
   - Create a monthly budget.
   - Set planned amounts by category.
   - Show planned, spent, remaining, and overspent values.
   - Make over-budget categories visually obvious.
   - Let users navigate between budget periods.

6. Dashboard
   - Show total balance/net worth.
   - Show this month's income, expenses, and net cash flow.
   - Show recent transactions.
   - Show top spending categories.
   - Show upcoming recurring transactions.
   - Keep the dashboard compact and useful for repeated daily checks.

7. Search and filters
   - Filter transactions by date range, wallet, category, type, text, and amount range.
   - Make filters easy to combine and easy to clear.
   - Preserve performance for large transaction histories.

8. Recurring transactions
   - Create recurring expenses, income, and transfers.
   - Support common schedules: daily, weekly, monthly, yearly, and custom interval.
   - Generate upcoming instances or reminders predictably.
   - Support skipping an occurrence and editing future occurrences.

9. Import, export, and backup
   - Export all app data to a user-owned backup file.
   - Restore from backup.
   - Import transactions from CSV.
   - Export transactions to CSV.
   - Validate imported data and show clear errors before committing changes.

10. Settings
    - Currency and number formatting.
    - Theme.
    - App lock.
    - Notification preferences.
    - Data export/import.
    - Category and wallet management shortcuts.

## Suggested Data Model

Use SQLite with Drift. Store money as integer minor units, such as cents, not floating-point values.

- `wallets`
  - `id`
  - `name`
  - `type`
  - `currencyCode`
  - `initialBalanceMinor`
  - `archived`
  - `sortOrder`
  - `createdAt`
  - `updatedAt`

- `categories`
  - `id`
  - `name`
  - `icon`
  - `color`
  - `kind`
  - `archived`
  - `sortOrder`
  - `createdAt`
  - `updatedAt`

- `transactions`
  - `id`
  - `type`
  - `amountMinor`
  - `currencyCode`
  - `date`
  - `walletId`
  - `transferWalletId`
  - `categoryId`
  - `title`
  - `note`
  - `createdAt`
  - `updatedAt`

- `budgets`
  - `id`
  - `name`
  - `periodStart`
  - `periodEnd`
  - `currencyCode`
  - `createdAt`
  - `updatedAt`

- `budget_category_limits`
  - `id`
  - `budgetId`
  - `categoryId`
  - `plannedAmountMinor`

- `recurring_transactions`
  - `id`
  - `transactionType`
  - `amountMinor`
  - `walletId`
  - `transferWalletId`
  - `categoryId`
  - `title`
  - `note`
  - `scheduleRule`
  - `startDate`
  - `endDate`
  - `nextDueDate`
  - `active`

- `settings`
  - `key`
  - `value`

Add tables for tags, attachments, goals, sync metadata, and shared budgets only after the core flows are stable.

## UX Principles

- Mobile-first: important actions should be reachable with one hand.
- Fast entry: adding a transaction should feel faster than opening a spreadsheet.
- Dense but readable: finance apps are used repeatedly, so avoid oversized marketing-style layouts.
- Clear money states: income, expense, transfer, debt, and available balance must not be visually ambiguous.
- Trustworthy data handling: backup, restore, and export should be easy to find and easy to verify.
- Local-first by default: core tracking should work without an account or internet connection.

## Build Order

1. Create the Flutter project and configure Android, iOS, and web targets.
2. Add app theming, navigation, localization foundation, and basic settings storage.
3. Add Drift/SQLite and create the initial schema.
4. Build onboarding, starter categories, and first wallet creation.
5. Build wallet list, wallet detail, and balance calculation.
6. Build transaction entry and transaction list.
7. Build category management.
8. Build monthly budget creation and budget review.
9. Build the dashboard using real wallet, transaction, and budget data.
10. Build search and filters.
11. Build recurring transactions and upcoming reminders.
12. Build CSV import/export and full backup/restore.
13. Add app lock and notification settings.
14. Add cloud account/sync only after local-first behavior is reliable.
15. Add advanced features such as shared budgets, goals, exchange rates, widgets, and premium features.

## Verification Checklist

- Run `flutter pub get` after dependency changes.
- Run `flutter analyze` before merging changes.
- Add unit tests for money math, date ranges, recurring schedules, CSV parsing, and budget calculations.
- Add widget tests for transaction entry, budget review, and onboarding.
- Test backup/restore with realistic data.
- Test transaction entry and budget review on a small phone viewport.
- Test web only after mobile core behavior is solid.
- For database migrations, test upgrading from at least one previous schema version.

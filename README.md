# Ledgr

[![Build APK](https://github.com/DESTROYER-32/Ledgr/actions/workflows/build.yml/badge.svg)](https://github.com/DESTROYER-32/Ledgr/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Ledgr is a privacy-first, local-first personal budget and finance tracking app built with Flutter. All financial data is kept securely on your device in a local SQLite database via Drift. No cloud account required, no ads, and zero trackers.

---

## Features

- **Multi-wallet & accounts**: Cash, checking, savings, credit cards, loans, and investment accounts in one place with multi-currency support.
- **Smart budgets**: Monthly, periodic, and category-specific spending limits with real-time indicators.
- **Cash flow forecasting**: Project future wallet balances 30, 60, or 90 days ahead based on upcoming bills and recurring transactions.
- **Investment portfolio**: Stock, ETF, and crypto tracking with cost basis, current valuations, and asset allocation breakdown.
- **Net worth tracking**: Monitor assets minus liabilities over time with historical snapshots and trends.
- **App security**: Protect financial data with biometric authentication (fingerprint / Face Unlock) or secure PBKDF2 PIN.
- **Full local backup & CSV**: Encrypted 15-table JSON backup export/restore and CSV transaction import/export.
- **Clean Material 3 UI**: Light, dark, and true AMOLED dark themes with customizable accent colors.

---

## Privacy Model

Ledgr is local-first. Your financial information never leaves your device unless you explicitly export or share a backup. Network access is strictly limited to fetching public currency exchange rates. See [PRIVACY.md](ledgr/PRIVACY.md) for details.

---

## Open Source & Packaging

- 100% open-source dependencies (zero proprietary Google Play or Firebase SDKs).
- Fastlane store metadata and localized descriptions in [`fastlane/metadata/android/`](fastlane/metadata/android/).

---

## Development

```bash
cd ledgr
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

See [ledgr/README.md](ledgr/README.md) for additional development, release signing, and CI details.

---

## License

This project is licensed under the [MIT License](LICENSE).

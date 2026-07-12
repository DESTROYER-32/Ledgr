# Ledgr

Ledgr is a privacy-first personal budget and finance tracking app built with Flutter. It helps track wallets, transactions, budgets, recurring payments, objectives, portfolio holdings, net worth, analytics, backups, and security settings from one mobile app.

## Features

- Wallet and transaction tracking with category management
- Budget monitoring and spending analytics
- Recurring transaction processing and cash-flow projections
- Objectives, net-worth snapshots, credit/debt, and portfolio tracking
- CSV import/export and local backup tools
- App lock support with local authentication
- Light, dark, and AMOLED themes

## Privacy model

Ledgr stores financial data locally on the device using SQLite via Drift. The app does not require an account or a hosted backend for core usage. Network access is used for features that need external data, such as exchange rates.

See [PRIVACY.md](PRIVACY.md) for the public privacy statement.

## Requirements

- Flutter 3.44.1, as used by CI
- Dart SDK compatible with `^3.12.1`
- Java 17 for Android builds
- Xcode on macOS for iOS builds

## Getting started

```bash
cd ledgr
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Quality checks

Run these before opening a pull request or cutting a release:

```bash
cd ledgr
dart format --set-exit-if-changed .
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release
```

## Android release signing

Do not commit keystores or signing passwords. For a signed Android release, create `android/key.properties` locally or in CI from secrets:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Then build:

```bash
flutter build appbundle --release
```

If `android/key.properties` is absent, the Gradle config falls back to debug signing so local release builds continue to work, but those artifacts are not suitable for app-store distribution.

## CI builds

GitHub Actions validate formatting, generated code, static analysis, tests, and Android release APK generation. Workflow artifacts are uploaded to GitHub Actions. Optional Telegram delivery is only attempted when the required secrets are configured.

## Contributing

1. Fork the repository and create a feature branch.
2. Keep generated Drift/Riverpod files in sync with source changes.
3. Run the quality checks above.
4. Open a pull request with a short description and screenshots for UI changes.

## Release checklist

- [ ] Update `version` in `pubspec.yaml`.
- [ ] Run all quality checks locally or confirm CI is green.
- [ ] Verify app icons, display names, and store descriptions.
- [ ] Build signed Android App Bundle or APK with release secrets.
- [ ] Build iOS archive using the Apple Developer signing profile.
- [ ] Smoke test install, onboarding, transaction creation, backup/export, and app lock.
- [ ] Tag the release and attach public artifacts or store links.

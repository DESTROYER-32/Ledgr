import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgr/core/database/app_database.dart';
import 'package:ledgr/core/database/repositories/settings_repository.dart';
import 'package:ledgr/core/providers/providers.dart';
import 'package:ledgr/core/security/app_lock_controller.dart';
import 'package:ledgr/features/security/app_lock_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthenticationOptions());
  });

  late AppDatabase db;
  late SettingsRepository settings;
  late MockLocalAuthentication mockAuth;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsRepository(db);
    mockAuth = MockLocalAuthentication();

    when(() => mockAuth.isDeviceSupported()).thenAnswer((_) async => true);
    when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => true);
    when(
      () => mockAuth.getAvailableBiometrics(),
    ).thenAnswer((_) async => [BiometricType.fingerprint]);
    when(
      () => mockAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => true);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('renders locked screen with unlock button', (tester) async {
    await settings.set('app_lock_enabled', 'true');
    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();
    controller.lock();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: AppLockScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Ledgr is locked'), findsOneWidget);
    expect(find.text('Unlock Ledgr'), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint), findsOneWidget);
  });

  testWidgets('shows message when authentication fails or is cancelled', (
    tester,
  ) async {
    when(
      () => mockAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => false);

    await settings.set('app_lock_enabled', 'true');
    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();
    controller.lock();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: AppLockScreen()),
      ),
    );

    // Let post-frame callback run
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.text('Authentication was cancelled or failed. Tap to retry.'),
      findsOneWidget,
    );
  });

  testWidgets('shows disable emergency button when device lock is not supported', (
    tester,
  ) async {
    when(() => mockAuth.isDeviceSupported()).thenAnswer((_) async => false);
    when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => false);

    await settings.set('app_lock_enabled', 'true');
    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();
    controller.lock();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: AppLockScreen()),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Disable App Lock'), findsOneWidget);
    expect(
      find.text('Device lock is not detected on this device'),
      findsOneWidget,
    );
  });
}

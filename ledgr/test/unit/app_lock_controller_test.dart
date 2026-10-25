import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgr/core/database/app_database.dart';
import 'package:ledgr/core/database/repositories/settings_repository.dart';
import 'package:ledgr/core/security/app_lock_controller.dart';
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

  setUp(() {
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

  test('initial state with no lock enabled', () async {
    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();

    expect(controller.state.isEnabled, isFalse);
    expect(controller.state.isLocked, isFalse);
    expect(controller.state.isDeviceSupported, isTrue);
    expect(controller.state.hasFingerprint, isTrue);
  });

  test('migrates legacy PIN lock gracefully', () async {
    await settings.set('app_lock_pin_hash', r'pbkdf2-sha256$100000$salt$hash');

    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();

    expect(controller.state.isEnabled, isTrue);
    expect(controller.state.isLocked, isTrue);
  });

  test('setEnabled(true) authenticates with device before enabling', () async {
    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();

    final result = await controller.setEnabled(true);
    expect(result, isTrue);
    expect(controller.state.isEnabled, isTrue);
    expect(await settings.get('app_lock_enabled'), 'true');
    verify(
      () => mockAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        options: any(named: 'options'),
      ),
    ).called(1);
  });

  test('setEnabled(true) aborts if authentication is cancelled', () async {
    when(
      () => mockAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => false);

    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();

    final result = await controller.setEnabled(true);
    expect(result, isFalse);
    expect(controller.state.isEnabled, isFalse);
    expect(await settings.get('app_lock_enabled'), isNull);
  });

  test('setEnabled(false) disables lock and cleans up settings', () async {
    await settings.set('app_lock_enabled', 'true');
    await settings.set('app_lock_pin_hash', 'legacy_hash');

    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();
    expect(controller.state.isEnabled, isTrue);

    final result = await controller.setEnabled(false);
    expect(result, isTrue);
    expect(controller.state.isEnabled, isFalse);
    expect(await settings.get('app_lock_enabled'), 'false');
    expect(await settings.get('app_lock_pin_hash'), isNull);
  });

  test('authenticate unlocks app when successful', () async {
    await settings.set('app_lock_enabled', 'true');
    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();
    controller.lock();
    expect(controller.state.isLocked, isTrue);

    final ok = await controller.authenticate();
    expect(ok, isTrue);
    expect(controller.state.isLocked, isFalse);
  });

  test('lock timeout immediately locks on resume when set to 0', () async {
    await settings.set('app_lock_enabled', 'true');
    await settings.set('app_lock_timeout_seconds', '0');

    final controller = AppLockController(settings, localAuth: mockAuth);
    await controller.refresh();
    controller.unlockDirectlyForTesting();
    expect(controller.state.isLocked, isFalse);

    controller.markAppLeft();
    controller.handleAppResumed();

    expect(controller.state.isLocked, isTrue);
  });
}

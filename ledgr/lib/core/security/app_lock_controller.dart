import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../database/repositories/settings_repository.dart';
import '../utils/app_logger.dart';

class AppLockState {
  final bool isEnabled;
  final bool isLocked;
  final bool isDeviceSupported;
  final List<BiometricType> availableBiometrics;
  final int lockTimeoutSeconds;
  final bool isLoading;

  const AppLockState({
    this.isEnabled = false,
    this.isLocked = false,
    this.isDeviceSupported = false,
    this.availableBiometrics = const [],
    this.lockTimeoutSeconds = -1,
    this.isLoading = true,
  });

  bool get biometricsEnabled => isEnabled && isDeviceSupported;
  bool get biometricsAvailable => isDeviceSupported;

  bool get hasFingerprint =>
      availableBiometrics.contains(BiometricType.fingerprint) ||
      availableBiometrics.contains(BiometricType.strong);

  bool get hasFace => availableBiometrics.contains(BiometricType.face);

  bool get hasBiometrics => availableBiometrics.isNotEmpty;

  String get lockTypeDescription {
    if (hasFingerprint && hasFace) return 'fingerprint, face, or device lock';
    if (hasFingerprint) return 'fingerprint or device lock';
    if (hasFace) return 'face or device lock';
    if (hasBiometrics) return 'biometrics or device lock';
    return 'device lock (PIN, pattern, or passcode)';
  }

  AppLockState copyWith({
    bool? isEnabled,
    bool? isLocked,
    bool? isDeviceSupported,
    List<BiometricType>? availableBiometrics,
    int? lockTimeoutSeconds,
    bool? isLoading,
  }) {
    return AppLockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLocked: isLocked ?? this.isLocked,
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
      lockTimeoutSeconds: lockTimeoutSeconds ?? this.lockTimeoutSeconds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppLockController extends ChangeNotifier {
  AppLockController(this._settings, {LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication() {
    refresh();
  }

  static const _enabledKey = 'app_lock_enabled';
  static const _timeoutKey = 'app_lock_timeout_seconds';

  // Legacy keys for migration from custom PIN lock
  static const _legacyPinHashKey = 'app_lock_pin_hash';
  static const _legacyPinSaltKey = 'app_lock_pin_salt';
  static const _legacyBiometricKey = 'app_lock_biometrics_enabled';
  static const _legacyFailedAttemptsKey = 'app_lock_failed_attempts';
  static const _legacyLockedUntilKey = 'app_lock_locked_until';

  final SettingsRepository _settings;
  final LocalAuthentication _localAuth;
  AppLockState _state = const AppLockState();
  DateTime? _leftAppAt;
  Future<void>? _refreshInFlight;
  bool _isAuthenticating = false;

  AppLockState get state => _state;
  bool get isAuthenticating => _isAuthenticating;

  Future<void> refresh({bool preserveLockState = false}) async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;
    final future = _refresh(preserveLockState: preserveLockState);
    _refreshInFlight = future;
    try {
      await future;
    } finally {
      if (identical(_refreshInFlight, future)) _refreshInFlight = null;
    }
  }

  Future<void> _refresh({required bool preserveLockState}) async {
    final enabledValue = await _settings.get(_enabledKey);
    final legacyPinHash = await _settings.get(_legacyPinHashKey);

    // If enabled via new key OR if user previously had PIN lock enabled
    final isEnabled =
        enabledValue == 'true' ||
        (enabledValue == null && legacyPinHash != null);

    final timeoutSeconds =
        int.tryParse(await _settings.get(_timeoutKey) ?? '') ?? -1;

    bool supported = false;
    List<BiometricType> biometrics = const [];
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      supported = isDeviceSupported || canCheckBiometrics;
      if (canCheckBiometrics) {
        biometrics = await _localAuth.getAvailableBiometrics();
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to query local authentication capabilities',
        error: error,
        stackTrace: stackTrace,
      );
    }

    _state = AppLockState(
      isEnabled: isEnabled,
      isLocked: preserveLockState ? _state.isLocked : isEnabled,
      isDeviceSupported: supported,
      availableBiometrics: biometrics,
      lockTimeoutSeconds: timeoutSeconds,
      isLoading: false,
    );
    notifyListeners();
  }

  void lock() {
    if (!_state.isEnabled || _state.isLocked) return;
    _state = _state.copyWith(isLocked: true);
    notifyListeners();
  }

  void unlockDirectlyForTesting() {
    _state = _state.copyWith(isLocked: false);
    notifyListeners();
  }

  void markAppLeft() {
    if (!_state.isEnabled || _state.isLocked || _isAuthenticating) return;
    _leftAppAt = DateTime.now();
  }

  void handleAppResumed() {
    if (!_state.isEnabled || _state.isLocked || _isAuthenticating) return;
    final timeoutSeconds = _state.lockTimeoutSeconds;
    final leftAt = _leftAppAt;
    _leftAppAt = null;

    if (timeoutSeconds < 0 || leftAt == null) return;
    final elapsed = DateTime.now().difference(leftAt).inSeconds;
    if (elapsed >= timeoutSeconds) lock();
  }

  Future<bool> authenticate({
    String reason = 'Unlock Ledgr',
    bool force = false,
  }) async {
    if (!_state.isEnabled && !force) {
      _state = _state.copyWith(isLocked: false);
      notifyListeners();
      return true;
    }

    if (_isAuthenticating) return false;
    _isAuthenticating = true;

    try {
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly:
              false, // Allows fingerprint, face, pattern, PIN, or passcode
          stickyAuth: true,
        ),
      );
      if (ok) {
        _state = _state.copyWith(isLocked: false);
        notifyListeners();
      }
      return ok;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Authentication failed or cancelled',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<bool> authenticateWithBiometrics() => authenticate();

  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final ok = await authenticate(
        reason: 'Authenticate to enable App Lock',
        force: true,
      );
      if (!ok) return false;
      await _settings.set(_enabledKey, 'true');
      await _cleanupLegacyKeys();
      _state = _state.copyWith(isEnabled: true, isLocked: false);
      notifyListeners();
      return true;
    } else {
      await _settings.set(_enabledKey, 'false');
      await _cleanupLegacyKeys();
      _leftAppAt = null;
      _state = _state.copyWith(isEnabled: false, isLocked: false);
      notifyListeners();
      return true;
    }
  }

  Future<void> disableWithoutAuth() async {
    await _settings.set(_enabledKey, 'false');
    await _cleanupLegacyKeys();
    _leftAppAt = null;
    _state = _state.copyWith(isEnabled: false, isLocked: false);
    notifyListeners();
  }

  Future<void> disable() => disableWithoutAuth();

  Future<void> setLockTimeoutSeconds(int seconds) async {
    await _settings.set(_timeoutKey, seconds.toString());
    _state = _state.copyWith(lockTimeoutSeconds: seconds);
    notifyListeners();
  }

  Future<void> _cleanupLegacyKeys() async {
    await _settings.remove(_legacyPinHashKey);
    await _settings.remove(_legacyPinSaltKey);
    await _settings.remove(_legacyBiometricKey);
    await _settings.remove(_legacyFailedAttemptsKey);
    await _settings.remove(_legacyLockedUntilKey);
  }
}

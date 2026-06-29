import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../database/repositories/settings_repository.dart';

class AppLockState {
  final bool isEnabled;
  final bool isLocked;
  final bool biometricsEnabled;
  final bool biometricsAvailable;
  final int lockTimeoutSeconds;
  final bool isLoading;

  const AppLockState({
    this.isEnabled = false,
    this.isLocked = false,
    this.biometricsEnabled = false,
    this.biometricsAvailable = false,
    this.lockTimeoutSeconds = -1,
    this.isLoading = true,
  });

  AppLockState copyWith({
    bool? isEnabled,
    bool? isLocked,
    bool? biometricsEnabled,
    bool? biometricsAvailable,
    int? lockTimeoutSeconds,
    bool? isLoading,
  }) {
    return AppLockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLocked: isLocked ?? this.isLocked,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      biometricsAvailable: biometricsAvailable ?? this.biometricsAvailable,
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

  static const _pinHashKey = 'app_lock_pin_hash';
  static const _pinSaltKey = 'app_lock_pin_salt';
  static const _biometricKey = 'app_lock_biometrics_enabled';
  static const _timeoutKey = 'app_lock_timeout_seconds';
  static const _pbkdf2Iterations = 100000;
  static const _pbkdf2Prefix = 'pbkdf2-sha256';

  final SettingsRepository _settings;
  final LocalAuthentication _localAuth;
  AppLockState _state = const AppLockState();
  DateTime? _leftAppAt;

  AppLockState get state => _state;

  Future<void> refresh() async {
    final pinHash = await _settings.get(_pinHashKey);
    final biometricsEnabled = await _settings.get(_biometricKey) == 'true';
    final timeoutSeconds =
        int.tryParse(await _settings.get(_timeoutKey) ?? '') ?? -1;
    final biometricsAvailable = await _canUseBiometrics();
    _state = AppLockState(
      isEnabled: pinHash != null,
      isLocked: pinHash != null,
      biometricsEnabled: biometricsEnabled && biometricsAvailable,
      biometricsAvailable: biometricsAvailable,
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

  void markAppLeft() {
    if (!_state.isEnabled || _state.isLocked) return;
    _leftAppAt = DateTime.now();
  }

  void handleAppResumed() {
    if (!_state.isEnabled || _state.isLocked) return;
    final timeoutSeconds = _state.lockTimeoutSeconds;
    final leftAt = _leftAppAt;
    _leftAppAt = null;

    // -1 means the default Cashew-like behavior: lock on initial app open only,
    // not when quickly switching away and back.
    if (timeoutSeconds < 0 || leftAt == null) return;
    final elapsed = DateTime.now().difference(leftAt).inSeconds;
    if (elapsed >= timeoutSeconds) lock();
  }

  Future<void> setPin(String pin) async {
    final salt = _randomSalt();
    await _settings.set(_pinSaltKey, salt);
    await _settings.set(_pinHashKey, _hashPin(pin, salt));
    _state = _state.copyWith(
      isEnabled: true,
      isLocked: false,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<void> setLockTimeoutSeconds(int seconds) async {
    await _settings.set(_timeoutKey, seconds.toString());
    _state = _state.copyWith(lockTimeoutSeconds: seconds);
    notifyListeners();
  }

  Future<void> disable() async {
    await _settings.remove(_pinHashKey);
    await _settings.remove(_pinSaltKey);
    await _settings.remove(_biometricKey);
    await _settings.remove(_timeoutKey);
    _leftAppAt = null;
    _state = _state.copyWith(
      isEnabled: false,
      isLocked: false,
      biometricsEnabled: false,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _settings.get(_pinSaltKey);
    final expected = await _settings.get(_pinHashKey);
    final ok =
        salt != null && expected != null && _verifyHash(pin, salt, expected);
    if (ok) {
      if (!expected.startsWith('$_pbkdf2Prefix\$')) {
        await _settings.set(_pinHashKey, _hashPin(pin, salt));
      }
      _state = _state.copyWith(isLocked: false);
      notifyListeners();
    }
    return ok;
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!_state.biometricsEnabled) return false;
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Unlock Budgetly',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (ok) {
        _state = _state.copyWith(isLocked: false);
        notifyListeners();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setBiometricsEnabled(bool enabled) async {
    if (enabled) {
      final available = await _canUseBiometrics();
      if (!available) return false;
      final ok = await _localAuth.authenticate(
        localizedReason: 'Enable biometric unlock for Budgetly',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!ok) return false;
    }
    await _settings.set(_biometricKey, enabled.toString());
    _state = _state.copyWith(biometricsEnabled: enabled);
    notifyListeners();
    return true;
  }

  Future<bool> _canUseBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported() &&
          (await _localAuth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String _hashPin(String pin, String salt) {
    final hash = _pbkdf2Sha256(
      password: utf8.encode(pin),
      salt: utf8.encode(salt),
      iterations: _pbkdf2Iterations,
      length: 32,
    );
    return '$_pbkdf2Prefix\$$_pbkdf2Iterations\$$salt\$${base64UrlEncode(hash)}';
  }

  bool _verifyHash(String pin, String salt, String expected) {
    if (expected.startsWith('$_pbkdf2Prefix\$')) {
      final parts = expected.split('\$');
      if (parts.length != 4) return false;
      final iterations = int.tryParse(parts[1]);
      if (iterations == null || iterations <= 0) return false;
      final hash = _pbkdf2Sha256(
        password: utf8.encode(pin),
        salt: utf8.encode(parts[2]),
        iterations: iterations,
        length: 32,
      );
      return _constantTimeEquals(base64UrlEncode(hash), parts[3]);
    }

    final legacy = sha256.convert(utf8.encode('$salt:$pin')).toString();
    return _constantTimeEquals(legacy, expected);
  }

  List<int> _pbkdf2Sha256({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int length,
  }) {
    final hmac = Hmac(sha256, password);
    final result = <int>[];
    var block = 1;

    while (result.length < length) {
      var u = hmac.convert([...salt, ..._int32BigEndian(block)]).bytes;
      final output = List<int>.from(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < output.length; j++) {
          output[j] ^= u[j];
        }
      }
      result.addAll(output);
      block++;
    }

    return result.take(length).toList(growable: false);
  }

  List<int> _int32BigEndian(int value) => [
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  String _randomSalt() => base64UrlEncode(
    List<int>.generate(24, (_) => Random.secure().nextInt(256)),
  );
}

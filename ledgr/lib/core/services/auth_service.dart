import 'package:local_auth/local_auth.dart';

class AuthService {
  static final _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    try {
      final deviceSupported = await _auth.isDeviceSupported();
      if (!deviceSupported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock Budgetly to view your finances',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

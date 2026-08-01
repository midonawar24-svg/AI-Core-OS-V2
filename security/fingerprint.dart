import 'package:local_auth/local_auth.dart';

class FingerprintService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheck() async {
    try { return await _auth.canCheckBiometrics && await _auth.isDeviceSupported(); } catch (_) { return false; }
  }

  Future<bool> auth() async {
    try { return await _auth.authenticate(localizedReason: 'دخول AI Core OS V3', options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true)); } catch (_) { return false; }
  }
}

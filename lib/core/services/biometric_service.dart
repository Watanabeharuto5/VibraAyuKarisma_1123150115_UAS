import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Menanyakan apakah perangkat mendukung autentikasi biometrik
  static Future<bool> isAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (_) {
      return false;
    }
  }

  /// Memverifikasi biometrik pengguna (sidik jari/FaceID)
  static Future<bool> authenticate() async {
    try {
      final available = await isAvailable();
      if (!available) return false;

      return await _auth.authenticate(
        localizedReason: 'Scan sidik jari atau wajah Anda untuk mengakses Kantong Ku',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

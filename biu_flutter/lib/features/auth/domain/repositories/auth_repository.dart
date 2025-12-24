import '../entities/auth_token.dart';
import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Get current user info from API
  /// Returns null if not logged in
  Future<User?> getCurrentUser();

  /// Generate QR code for login
  /// Returns (url, qrcodeKey) tuple
  Future<(String url, String qrcodeKey)> generateQrCode();

  /// Poll QR code login status
  /// Returns (code, refreshToken) tuple
  /// code: 0-success, 86038-expired, 86090-scanned, 86101-not scanned
  Future<(int code, String? refreshToken, String message)> pollQrCodeStatus(
      String qrcodeKey);

  /// Get RSA public key for password encryption
  /// Returns (hash, key) tuple
  Future<(String hash, String publicKey)> getPasswordKey();

  /// Login with password
  /// Returns (success, refreshToken, message) tuple
  Future<(bool success, String? refreshToken, String message)> loginWithPassword({
    required String username,
    required String encryptedPassword,
    required String geetestToken,
    required String geetestChallenge,
    required String geetestValidate,
    required String geetestSeccode,
  });

  /// Send SMS verification code
  /// Returns (success, captchaKey, message) tuple
  Future<(bool success, String? captchaKey, String message)> sendSmsCode({
    required int countryCode,
    required int phone,
    required String geetestToken,
    required String geetestChallenge,
    required String geetestValidate,
    required String geetestSeccode,
  });

  /// Login with SMS code
  /// Returns (success, refreshToken, message) tuple
  Future<(bool success, String? refreshToken, String message)> loginWithSms({
    required int countryCode,
    required int phone,
    required int code,
    required String captchaKey,
  });

  /// Check if cookie needs refresh
  /// Returns (needsRefresh, timestamp) tuple
  Future<(bool needsRefresh, int timestamp)> checkCookieInfo();

  /// Refresh cookie
  /// Returns new refresh token if successful
  Future<String?> refreshCookie({
    required String refreshCsrf,
    required String refreshToken,
  });

  /// Logout and clear session
  Future<bool> logout();

  /// Get stored auth token
  Future<AuthToken?> getStoredToken();

  /// Store auth token
  Future<void> storeToken(AuthToken token);

  /// Clear stored auth token
  Future<void> clearStoredToken();
}

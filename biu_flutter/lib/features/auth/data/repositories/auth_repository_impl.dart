import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Storage keys for auth data
class AuthStorageKeys {
  static const String authToken = 'auth_token';
  static const String userInfo = 'user_info';
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    AuthRemoteDatasource? remoteDatasource,
    SecureStorageService? secureStorage,
  })  : _remoteDatasource = remoteDatasource ?? AuthRemoteDatasource(),
        _secureStorage = secureStorage ?? SecureStorageService.instance;

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _remoteDatasource.getUserInfo();
      if (response.isLoggedIn && response.data != null) {
        return response.data!.toEntity();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<(String url, String qrcodeKey)> generateQrCode() async {
    final response = await _remoteDatasource.generateQrCode();
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty
          ? response.message
          : 'Failed to generate QR code');
    }
    return (response.data!.url, response.data!.qrcodeKey);
  }

  @override
  Future<(int code, String? refreshToken, String message)> pollQrCodeStatus(
      String qrcodeKey) async {
    final response = await _remoteDatasource.pollQrCodeStatus(qrcodeKey);
    final data = response.data;
    if (data == null) {
      return (-1, null, response.message);
    }
    return (data.code, data.isSuccess ? data.refreshToken : null, data.message);
  }

  @override
  Future<(String hash, String publicKey)> getPasswordKey() async {
    final response = await _remoteDatasource.getWebKey();
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty
          ? response.message
          : 'Failed to get password key');
    }
    return (response.data!.hash, response.data!.key);
  }

  @override
  Future<(bool success, String? refreshToken, String message)>
      loginWithPassword({
    required String username,
    required String encryptedPassword,
    required String geetestToken,
    required String geetestChallenge,
    required String geetestValidate,
    required String geetestSeccode,
  }) async {
    final response = await _remoteDatasource.loginWithPassword(
      username: username,
      password: encryptedPassword,
      token: geetestToken,
      challenge: geetestChallenge,
      validate: geetestValidate,
      seccode: geetestSeccode,
    );

    if (response.isSuccess) {
      return (true, response.data?.refreshToken, response.message);
    }
    return (false, null, response.message);
  }

  @override
  Future<(bool success, String? captchaKey, String message)> sendSmsCode({
    required int countryCode,
    required int phone,
    required String geetestToken,
    required String geetestChallenge,
    required String geetestValidate,
    required String geetestSeccode,
  }) async {
    final response = await _remoteDatasource.sendSmsCode(
      cid: countryCode,
      tel: phone,
      token: geetestToken,
      challenge: geetestChallenge,
      validate: geetestValidate,
      seccode: geetestSeccode,
    );

    if (response.isSuccess && response.data != null) {
      return (true, response.data!.captchaKey, response.message);
    }
    return (false, null, response.message);
  }

  @override
  Future<(bool success, String? refreshToken, String message)> loginWithSms({
    required int countryCode,
    required int phone,
    required int code,
    required String captchaKey,
  }) async {
    final response = await _remoteDatasource.loginWithSms(
      cid: countryCode,
      tel: phone,
      code: code,
      captchaKey: captchaKey,
    );

    if (response.isSuccess && response.data != null) {
      return (true, response.data!.refreshToken, response.message);
    }
    return (false, null, response.message);
  }

  @override
  Future<(bool needsRefresh, int timestamp)> checkCookieInfo() async {
    try {
      final response = await _remoteDatasource.getCookieInfo();
      if (response.isSuccess && response.data != null) {
        return (response.data!.refresh, response.data!.timestamp);
      }
      if (response.isNotLoggedIn) {
        return (false, 0);
      }
      return (false, 0);
    } catch (e) {
      return (false, 0);
    }
  }

  @override
  Future<String?> refreshCookie({
    required String refreshCsrf,
    required String refreshToken,
  }) async {
    try {
      final response = await _remoteDatasource.refreshCookie(
        refreshCsrf: refreshCsrf,
        refreshToken: refreshToken,
      );
      if (response.isSuccess && response.data != null) {
        return response.data!.refreshToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final response = await _remoteDatasource.logout();
      if (response.isSuccess) {
        // Clear cookies
        await DioClient.instance.clearCookies();
        // Clear stored token
        await clearStoredToken();
        return true;
      }
      return false;
    } catch (e) {
      // Even if API fails, clear local data
      await DioClient.instance.clearCookies();
      await clearStoredToken();
      return true;
    }
  }

  @override
  Future<AuthToken?> getStoredToken() async {
    final json = await _secureStorage.getJson(AuthStorageKeys.authToken);
    if (json == null) return null;
    return AuthToken.fromJson(json);
  }

  @override
  Future<void> storeToken(AuthToken token) async {
    await _secureStorage.setJson(AuthStorageKeys.authToken, token.toJson());
  }

  @override
  Future<void> clearStoredToken() async {
    await _secureStorage.remove(AuthStorageKeys.authToken);
  }
}

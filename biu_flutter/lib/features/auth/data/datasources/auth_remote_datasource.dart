import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/captcha_response.dart';
import '../models/country_response.dart';
import '../models/login_response.dart';
import '../models/qrcode_response.dart';
import '../models/session_response.dart';
import '../models/user_info_response.dart';

/// Remote data source for authentication APIs
///
/// Consolidates multiple source services into Clean Architecture DataSource pattern.
/// Source: biu/src/service/passport-login-*.ts (multiple files consolidated)
/// Source: biu/src/service/user-info.ts#getUserInfo
class AuthRemoteDatasource {

  AuthRemoteDatasource({
    Dio? dio,
    Dio? passportDio,
  })  : _dio = dio ?? DioClient.instance.dio,
        _passportDio = passportDio ?? DioClient.instance.passportDio;
  final Dio _dio;
  final Dio _passportDio;

  /// Get current user info
  /// GET /x/web-interface/nav
  /// Source: biu/src/service/user-info.ts#getUserInfo
  Future<UserInfoResponse> getUserInfo() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/web-interface/nav',
    );
    return UserInfoResponse.fromJson(response.data ?? {});
  }

  /// Generate QR code for login
  /// GET /x/passport-login/web/qrcode/generate
  /// Source: biu/src/service/passport-login-web-qrcode-generate.ts#getPassportLoginWebQrcodeGenerate
  Future<QrCodeGenerateResponse> generateQrCode() async {
    final response = await _passportDio.get<Map<String, dynamic>>(
      '/x/passport-login/web/qrcode/generate',
    );
    return QrCodeGenerateResponse.fromJson(response.data ?? {});
  }

  /// Poll QR code login status
  /// GET /x/passport-login/web/qrcode/poll
  /// Source: biu/src/service/passport-login-web-qrcode-poll.ts#getPassportLoginWebQrcodePoll
  Future<QrCodePollResponse> pollQrCodeStatus(String qrcodeKey) async {
    final response = await _passportDio.get<Map<String, dynamic>>(
      '/x/passport-login/web/qrcode/poll',
      queryParameters: {'qrcode_key': qrcodeKey},
    );
    return QrCodePollResponse.fromJson(response.data ?? {});
  }

  /// Get RSA public key for password encryption
  /// GET /x/passport-login/web/key
  /// Source: biu/src/service/passport-login-web-key.ts#getPassportLoginWebKey
  Future<WebKeyResponse> getWebKey() async {
    final response = await _passportDio.get<Map<String, dynamic>>(
      '/x/passport-login/web/key',
    );
    return WebKeyResponse.fromJson(response.data ?? {});
  }

  /// Get captcha challenge for Geetest verification
  /// GET /x/passport-login/captcha
  /// Source: biu/src/service/passport-login-captcha.ts#getPassportLoginCaptcha
  Future<CaptchaResponse> getCaptcha({String source = 'main_web'}) async {
    final response = await _passportDio.get<Map<String, dynamic>>(
      '/x/passport-login/captcha',
      queryParameters: {'source': source},
    );
    return CaptchaResponse.fromJson(response.data ?? {});
  }

  /// Login with password
  /// POST /x/passport-login/web/login
  /// Source: biu/src/service/passport-login-web-login-passport.ts#passportLoginWebLoginPassport
  Future<PasswordLoginResponse> loginWithPassword({
    required String username,
    required String password,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    final response = await _passportDio.post<Map<String, dynamic>>(
      '/x/passport-login/web/login',
      data: {
        'username': username,
        'password': password,
        'keep': 0,
        'token': token,
        'challenge': challenge,
        'validate': validate,
        'seccode': seccode,
        'source': 'main_web',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return PasswordLoginResponse.fromJson(response.data ?? {});
  }

  /// Send SMS verification code
  /// POST /x/passport-login/web/sms/send
  /// Source: biu/src/service/passport-login-web-sms-send.ts#postPassportLoginWebSmsSend
  Future<SmsSendResponse> sendSmsCode({
    required int cid,
    required int tel,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    final response = await _passportDio.post<Map<String, dynamic>>(
      '/x/passport-login/web/sms/send',
      data: {
        'cid': cid,
        'tel': tel,
        'source': 'main_web',
        'token': token,
        'challenge': challenge,
        'validate': validate,
        'seccode': seccode,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return SmsSendResponse.fromJson(response.data ?? {});
  }

  /// Login with SMS code
  /// POST /x/passport-login/web/login/sms
  /// Source: biu/src/service/passport-login-web-login-sms.ts#postPassportLoginWebLoginSms
  Future<SmsLoginResponse> loginWithSms({
    required int cid,
    required int tel,
    required int code,
    required String captchaKey,
  }) async {
    final response = await _passportDio.post<Map<String, dynamic>>(
      '/x/passport-login/web/login/sms',
      data: {
        'cid': cid,
        'tel': tel,
        'code': code,
        'source': 'main_web',
        'captcha_key': captchaKey,
        'keep': true,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return SmsLoginResponse.fromJson(response.data ?? {});
  }

  /// Check if cookie needs refresh
  /// GET /x/passport-login/web/cookie/info
  /// Source: biu/src/service/passport-login-web-cookie-info.ts#getPassportLoginWebCookieInfo
  Future<CookieInfoResponse> getCookieInfo() async {
    final response = await _passportDio.get<Map<String, dynamic>>(
      '/x/passport-login/web/cookie/info',
    );
    return CookieInfoResponse.fromJson(response.data ?? {});
  }

  /// Refresh cookie
  /// POST /x/passport-login/web/cookie/refresh
  /// Source: biu/src/service/passport-login-web-cookie-refresh.ts#postPassportLoginWebCookieRefresh
  Future<CookieRefreshResponse> refreshCookie({
    required String refreshCsrf,
    required String refreshToken,
  }) async {
    // Get CSRF token from cookies
    final csrf = await DioClient.instance.getCookie('bili_jct');

    final response = await _passportDio.post<Map<String, dynamic>>(
      '/x/passport-login/web/cookie/refresh',
      data: {
        'refresh_csrf': refreshCsrf,
        'source': 'main_web',
        'refresh_token': refreshToken,
        'csrf': csrf ?? '',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return CookieRefreshResponse.fromJson(response.data ?? {});
  }

  /// Confirm cookie refresh (invalidates old refresh_token)
  /// POST /x/passport-login/web/confirm/refresh
  /// Source: biu/src/service/passport-login-web-confirm-refresh.ts#postPassportLoginWebConfirmRefresh
  Future<ConfirmRefreshResponse> confirmRefresh({
    required String refreshToken,
  }) async {
    // Get CSRF token from cookies
    final csrf = await DioClient.instance.getCookie('bili_jct');

    final response = await _passportDio.post<Map<String, dynamic>>(
      '/x/passport-login/web/confirm/refresh',
      data: {
        'refresh_token': refreshToken,
        'csrf': csrf ?? '',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return ConfirmRefreshResponse.fromJson(response.data ?? {});
  }

  /// Get correspond path page HTML to extract refresh_csrf
  /// GET /correspond/1/{correspondPath}
  Future<String> getCorrespondPathHtml(String correspondPath) async {
    // Use main site Dio for this request
    final mainSiteDio = Dio(BaseOptions(
      baseUrl: 'https://www.bilibili.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Copy cookies from main dio
    final cookies = await DioClient.instance.getCookies('https://www.bilibili.com');
    if (cookies.isNotEmpty) {
      mainSiteDio.options.headers['Cookie'] = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    }

    final response = await mainSiteDio.get<String>(
      '/correspond/1/$correspondPath',
      options: Options(
        responseType: ResponseType.plain,
      ),
    );
    return response.data ?? '';
  }

  /// Logout
  /// POST /login/exit/v2
  /// Source: biu/src/service/passport-login-exit.ts#passportLoginExit
  Future<LogoutResponse> logout() async {
    // Get CSRF token from cookies
    final csrf = await DioClient.instance.getCookie('bili_jct');

    final response = await _passportDio.post<Map<String, dynamic>>(
      '/login/exit/v2',
      data: {
        'biliCSRF': csrf ?? '',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return LogoutResponse.fromJson(response.data ?? {});
  }

  /// Get country/region list for SMS login
  /// GET /x/passport-login/web/country
  /// Source: biu/src/service/passport-login-web-country.ts#getPassportLoginDefaultCountry
  Future<CountryListResponse> getCountryList() async {
    final response = await _passportDio.get<Map<String, dynamic>>(
      '/x/passport-login/web/country',
    );
    return CountryListResponse.fromJson(response.data ?? {});
  }
}

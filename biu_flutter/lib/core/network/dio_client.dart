import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/api.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/response_interceptor.dart';

/// Singleton Dio client for Bilibili API requests.
///
/// Manages multiple Dio instances for different Bilibili endpoints:
/// - [dio]: api.bilibili.com (main API)
/// - [passportDio]: passport.bilibili.com (login/auth)
/// - [searchDio]: s.search.bilibili.com (search)
/// - [biliDio]: www.bilibili.com (web pages, audio info)
///
/// Source: biu/src/service/request/index.ts
class DioClient {
  DioClient._();

  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  late final Dio _dio;
  late final Dio _passportDio;
  late final Dio _searchDio;
  late final Dio _biliDio;
  late final PersistCookieJar _cookieJar;

  bool _initialized = false;

  /// Get the main Dio instance
  Dio get dio => _dio;

  /// Get the passport Dio instance (for login)
  Dio get passportDio => _passportDio;

  /// Get the search Dio instance
  Dio get searchDio => _searchDio;

  /// Get the bili Dio instance (for www.bilibili.com)
  ///
  /// Source: biu/src/service/request/index.ts#biliRequest
  Dio get biliDio => _biliDio;

  /// Get the cookie jar
  PersistCookieJar get cookieJar => _cookieJar;

  /// Initialize the Dio client
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize persistent cookie jar
    final appDocDir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );

    // Create main Dio instance for api.bilibili.com
    _dio = _createDio(
      baseUrl: ApiConstants.baseUrl,
      withAuth: true,
    );

    // Create passport Dio instance for passport.bilibili.com
    _passportDio = _createDio(
      baseUrl: ApiConstants.passportUrl,
      withAuth: true,
    );

    // Create search Dio instance for s.search.bilibili.com
    _searchDio = _createDio(
      baseUrl: 'https://s.search.bilibili.com',
      withAuth: true,
    );

    // Create bili Dio instance for www.bilibili.com
    // Source: biu/src/service/request/index.ts#biliRequest
    _biliDio = _createDio(
      baseUrl: 'https://www.bilibili.com',
      withAuth: true,
    );

    _initialized = true;
  }

  Dio _createDio({
    required String baseUrl,
    bool withAuth = false,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
        headers: {
          'User-Agent': ApiConstants.webUserAgent,
          'Referer': 'https://www.bilibili.com/',
          'Origin': 'https://www.bilibili.com',
        },
      ),
    );

    // Add cookie manager
    dio.interceptors.add(CookieManager(_cookieJar));

    // Add auth interceptor if needed
    if (withAuth) {
      dio.interceptors.add(AuthInterceptor(cookieJar: _cookieJar));
    }

    // Add response interceptor
    dio.interceptors.add(BiliResponseInterceptor());

    // Add logging interceptor in debug mode
    assert(() {
      dio.interceptors.add(LoggingInterceptor());
      return true;
    }());

    return dio;
  }

  /// Get cookie value by name
  Future<String?> getCookie(String name) async {
    final cookies = await _cookieJar.loadForRequest(
      Uri.parse('https://bilibili.com'),
    );
    for (final cookie in cookies) {
      if (cookie.name == name) {
        return cookie.value;
      }
    }
    return null;
  }

  /// Set a cookie
  Future<void> setCookie(String name, String value) async {
    final cookie = Cookie(name, value)
      ..domain = '.bilibili.com'
      ..path = '/';
    await _cookieJar.saveFromResponse(
      Uri.parse('https://bilibili.com'),
      [cookie],
    );
  }

  /// Get all cookies as a string
  Future<String> getCookieString() async {
    final cookies = await _cookieJar.loadForRequest(
      Uri.parse('https://bilibili.com'),
    );
    return cookies.map((c) => '${c.name}=${c.value}').join('; ');
  }

  /// Get all cookies for a URL
  Future<List<Cookie>> getCookies(String url) async {
    return _cookieJar.loadForRequest(Uri.parse(url));
  }

  /// Clear all cookies
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }
}

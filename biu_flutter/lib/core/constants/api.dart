/// API base URLs and endpoints for Bilibili.
///
/// Contains all the base URLs, timeout configurations, and user agent strings
/// needed for Bilibili API communication.
///
/// Source: Flutter-only (consolidates values from multiple source files)
class ApiConstants {
  ApiConstants._();

  /// Bilibili main API base URL
  static const String baseUrl = 'https://api.bilibili.com';

  /// Bilibili passport API base URL (for login)
  static const String passportUrl = 'https://passport.bilibili.com';

  /// Bilibili audio API base URL
  static const String audioUrl = 'https://www.bilibili.com/audio';

  /// Default timeout duration in milliseconds
  static const int defaultTimeout = 30000;

  /// Default user agent for web requests
  static const String webUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36';

  /// Search API base URL
  static const String searchUrl = 'https://s.search.bilibili.com';

  /// Bilibili API response success code
  static const int successCode = 0;

  /// Bilibili main site URL (for referer header)
  static const String bilibiliReferer = 'https://www.bilibili.com';

  /// User agent for audio streaming requests
  static const String userAgent = webUserAgent;
}

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

import '../ticket/bili_ticket_service.dart';
import '../wbi/wbi_sign.dart';

/// Interceptor for handling authentication-related tasks:
/// - Injecting CSRF token
/// - Adding WBI signature when needed
/// - Injecting bili_ticket cookie
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.cookieJar});

  final PersistCookieJar cookieJar;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if CSRF token is needed
    if (options.extra['useCSRF'] == true) {
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        if (options.method.toUpperCase() == 'POST') {
          // Add to form data
          if (options.data is Map) {
            (options.data as Map)['csrf'] = csrfToken;
          } else if (options.data is FormData) {
            (options.data as FormData).fields.add(MapEntry('csrf', csrfToken));
          } else {
            options.data = {'csrf': csrfToken};
          }
        } else {
          // Add to query parameters
          options.queryParameters['csrf'] = csrfToken;
        }
      }
    }

    // Check if WBI signature is needed
    if (options.extra['useWbi'] == true) {
      options.queryParameters = await WbiSign.instance.encodeParams(
        options.queryParameters.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        ),
      );
    }

    // Inject bili_ticket if available
    await _injectBiliTicket(options);

    handler.next(options);
  }

  /// Inject bili_ticket into request cookies
  Future<void> _injectBiliTicket(RequestOptions options) async {
    try {
      // Ensure ticket is available
      await BiliTicketService.instance.refreshIfNeeded();

      final ticket = BiliTicketService.instance.ticket;
      if (ticket != null && ticket.isNotEmpty) {
        // Add bili_ticket to existing cookies
        final existingCookie = options.headers['Cookie'] as String? ?? '';
        final newCookie = existingCookie.isEmpty
            ? 'bili_ticket=$ticket'
            : '$existingCookie; bili_ticket=$ticket';
        options.headers['Cookie'] = newCookie;
      }
    } catch (e) {
      // Silently fail if ticket injection fails
    }
  }

  Future<String?> _getCsrfToken() async {
    final cookies = await cookieJar.loadForRequest(
      Uri.parse('https://bilibili.com'),
    );
    for (final cookie in cookies) {
      if (cookie.name == 'bili_jct') {
        return cookie.value;
      }
    }
    return null;
  }
}

/// Extension on RequestOptions to add custom extra fields
extension RequestOptionsExtra on RequestOptions {
  /// Set useCSRF flag
  void setUseCSRF(bool value) {
    extra['useCSRF'] = value;
  }

  /// Set useWbi flag
  void setUseWbi(bool value) {
    extra['useWbi'] = value;
  }
}

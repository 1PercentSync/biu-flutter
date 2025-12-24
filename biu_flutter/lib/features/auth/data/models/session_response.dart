/// Response from /x/passport-login/web/cookie/info
class CookieInfoResponse {
  final int code;
  final String message;
  final CookieInfoData? data;

  const CookieInfoResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory CookieInfoResponse.fromJson(Map<String, dynamic> json) {
    return CookieInfoResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? CookieInfoData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Check if request was successful
  bool get isSuccess => code == 0;

  /// Check if user is not logged in (-101)
  bool get isNotLoggedIn => code == -101;
}

class CookieInfoData {
  /// Whether cookie refresh is needed
  final bool refresh;

  /// Current timestamp in milliseconds
  final int timestamp;

  const CookieInfoData({
    required this.refresh,
    required this.timestamp,
  });

  factory CookieInfoData.fromJson(Map<String, dynamic> json) {
    return CookieInfoData(
      refresh: json['refresh'] as bool? ?? false,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }
}

/// Response from /x/passport-login/web/cookie/refresh
class CookieRefreshResponse {
  final int code;
  final String message;
  final CookieRefreshData? data;

  const CookieRefreshResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory CookieRefreshResponse.fromJson(Map<String, dynamic> json) {
    return CookieRefreshResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? CookieRefreshData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Check if refresh was successful
  bool get isSuccess => code == 0;
}

class CookieRefreshData {
  /// Status code
  final int status;

  /// Status message
  final String message;

  /// New refresh token
  final String refreshToken;

  const CookieRefreshData({
    required this.status,
    required this.message,
    required this.refreshToken,
  });

  factory CookieRefreshData.fromJson(Map<String, dynamic> json) {
    return CookieRefreshData(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }
}

/// Response from /login/exit/v2
class LogoutResponse {
  final int code;
  final bool? status;
  final int? ts;
  final String? message;
  final LogoutData? data;

  const LogoutResponse({
    required this.code,
    this.status,
    this.ts,
    this.message,
    this.data,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      code: json['code'] as int? ?? -1,
      status: json['status'] as bool?,
      ts: json['ts'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? LogoutData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Check if logout was successful
  bool get isSuccess => code == 0;
}

class LogoutData {
  final String redirectUrl;

  const LogoutData({required this.redirectUrl});

  factory LogoutData.fromJson(Map<String, dynamic> json) {
    return LogoutData(
      redirectUrl: json['redirectUrl'] as String? ?? '',
    );
  }
}

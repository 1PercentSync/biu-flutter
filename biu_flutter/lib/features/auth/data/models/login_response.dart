/// Response from /x/passport-login/web/key API
class WebKeyResponse {

  const WebKeyResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory WebKeyResponse.fromJson(Map<String, dynamic> json) {
    return WebKeyResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? WebKeyData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
  final int code;
  final String message;
  final WebKeyData? data;

  bool get isSuccess => code == 0 && data != null;
}

class WebKeyData {

  const WebKeyData({required this.hash, required this.key});

  factory WebKeyData.fromJson(Map<String, dynamic> json) {
    return WebKeyData(
      hash: json['hash'] as String? ?? '',
      key: json['key'] as String? ?? '',
    );
  }
  /// Salt hash for password encryption
  final String hash;

  /// RSA public key (PEM format)
  final String key;
}

/// Response from /x/passport-login/web/login (password login)
class PasswordLoginResponse {

  const PasswordLoginResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory PasswordLoginResponse.fromJson(Map<String, dynamic> json) {
    return PasswordLoginResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? PasswordLoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
  final int code;
  final String message;
  final PasswordLoginData? data;

  bool get isSuccess => code == 0;
}

class PasswordLoginData {

  const PasswordLoginData({
    this.status,
    this.url,
    this.refreshToken,
    this.timestamp,
    this.message,
  });

  factory PasswordLoginData.fromJson(Map<String, dynamic> json) {
    return PasswordLoginData(
      status: json['status'] as int?,
      url: json['url'] as String?,
      refreshToken: json['refresh_token'] as String?,
      timestamp: json['timestamp'] as int?,
      message: json['message'] as String?,
    );
  }
  final int? status;
  final String? url;
  final String? refreshToken;
  final int? timestamp;
  final String? message;
}

/// Response from /x/passport-login/web/sms/send
class SmsSendResponse {

  const SmsSendResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory SmsSendResponse.fromJson(Map<String, dynamic> json) {
    return SmsSendResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SmsSendData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
  final int code;
  final String message;
  final SmsSendData? data;

  bool get isSuccess => code == 0;
}

class SmsSendData {

  const SmsSendData({required this.captchaKey});

  factory SmsSendData.fromJson(Map<String, dynamic> json) {
    return SmsSendData(
      captchaKey: json['captcha_key'] as String? ?? '',
    );
  }
  /// Captcha key for SMS login
  final String captchaKey;
}

/// Response from /x/passport-login/web/login/sms
class SmsLoginResponse {

  const SmsLoginResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory SmsLoginResponse.fromJson(Map<String, dynamic> json) {
    return SmsLoginResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SmsLoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
  final int code;
  final String message;
  final SmsLoginData? data;

  bool get isSuccess => code == 0;
}

class SmsLoginData {

  const SmsLoginData({
    required this.hint,
    required this.isNew,
    required this.status,
    required this.url,
    required this.refreshToken,
    required this.timestamp,
  });

  factory SmsLoginData.fromJson(Map<String, dynamic> json) {
    return SmsLoginData(
      hint: json['hint'] as String? ?? '',
      isNew: json['is_new'] as bool? ?? false,
      status: json['status'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }
  final String hint;
  final bool isNew;
  final int status;
  final String url;
  final String refreshToken;
  final int timestamp;
}

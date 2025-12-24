/// Response from /x/passport-login/web/qrcode/generate API
class QrCodeGenerateResponse {

  const QrCodeGenerateResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory QrCodeGenerateResponse.fromJson(Map<String, dynamic> json) {
    return QrCodeGenerateResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? QrCodeData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
  final int code;
  final String message;
  final QrCodeData? data;

  bool get isSuccess => code == 0 && data != null;
}

class QrCodeData {

  const QrCodeData({required this.url, required this.qrcodeKey});

  factory QrCodeData.fromJson(Map<String, dynamic> json) {
    return QrCodeData(
      url: json['url'] as String? ?? '',
      qrcodeKey: json['qrcode_key'] as String? ?? '',
    );
  }
  /// QR code URL to display
  final String url;

  /// QR code key for polling
  final String qrcodeKey;
}

/// Response from /x/passport-login/web/qrcode/poll API
class QrCodePollResponse {

  const QrCodePollResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory QrCodePollResponse.fromJson(Map<String, dynamic> json) {
    return QrCodePollResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? QrCodePollData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
  final int code;
  final String message;
  final QrCodePollData? data;
}

class QrCodePollData {

  const QrCodePollData({
    required this.url,
    required this.refreshToken,
    required this.timestamp,
    required this.code,
    required this.message,
  });

  factory QrCodePollData.fromJson(Map<String, dynamic> json) {
    return QrCodePollData(
      url: json['url'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
    );
  }
  /// Login URL (only available after successful login)
  final String url;

  /// Refresh token (only available after successful login)
  final String refreshToken;

  /// Timestamp (milliseconds)
  final int timestamp;

  /// Status code:
  /// - 0: Login successful
  /// - 86038: QR code expired
  /// - 86090: QR code scanned, waiting for confirmation
  /// - 86101: QR code not scanned
  final int code;

  /// Status message
  final String message;

  /// Check if login is successful
  bool get isSuccess => code == 0;

  /// Check if QR code is expired
  bool get isExpired => code == 86038;

  /// Check if QR code is scanned but not confirmed
  bool get isScanned => code == 86090;

  /// Check if QR code is not scanned
  bool get isNotScanned => code == 86101;
}

/// Response from /x/passport-login/captcha API
class CaptchaResponse {

  const CaptchaResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory CaptchaResponse.fromJson(Map<String, dynamic> json) {
    return CaptchaResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? CaptchaData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
  final int code;
  final String message;
  final CaptchaData? data;

  bool get isSuccess => code == 0 && data != null;
}

class CaptchaData {

  const CaptchaData({
    required this.type,
    required this.token,
    this.geetest,
  });

  factory CaptchaData.fromJson(Map<String, dynamic> json) {
    return CaptchaData(
      type: json['type'] as String? ?? '',
      token: json['token'] as String? ?? '',
      geetest: json['geetest'] != null
          ? GeetestParams.fromJson(json['geetest'] as Map<String, dynamic>)
          : null,
    );
  }
  /// Captcha type (e.g., "geetest")
  final String type;

  /// Token for captcha verification
  final String token;

  /// Geetest specific parameters
  final GeetestParams? geetest;
}

class GeetestParams {

  const GeetestParams({
    required this.gt,
    required this.challenge,
  });

  factory GeetestParams.fromJson(Map<String, dynamic> json) {
    return GeetestParams(
      gt: json['gt'] as String? ?? '',
      challenge: json['challenge'] as String? ?? '',
    );
  }
  /// Geetest gt parameter
  final String gt;

  /// Geetest challenge parameter
  final String challenge;
}

/// Geetest verification result
class GeetestResult {

  const GeetestResult({
    required this.token,
    required this.gt,
    required this.challenge,
    required this.validate,
    required this.seccode,
  });
  /// Geetest token from captcha API
  final String token;

  /// Geetest gt parameter
  final String gt;

  /// Geetest challenge (may be updated after verification)
  final String challenge;

  /// Geetest validate result
  final String validate;

  /// Geetest seccode result
  final String seccode;

  /// Check if result is valid
  bool get isValid =>
      validate.isNotEmpty && seccode.isNotEmpty && challenge.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'token': token,
        'gt': gt,
        'challenge': challenge,
        'validate': validate,
        'seccode': seccode,
      };
}

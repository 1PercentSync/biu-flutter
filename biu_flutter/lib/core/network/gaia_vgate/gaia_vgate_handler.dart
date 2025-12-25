import 'package:flutter/material.dart';

/// Abstract handler for Gaia VGate risk control verification.
///
/// This abstraction allows core network layer to trigger verification
/// without depending on feature layer implementations.
///
/// Source concept: biu/src/service/request/response-interceptors.ts
abstract class GaiaVgateHandler {
  /// Register Gaia VGate challenge and get Geetest parameters.
  ///
  /// Returns null if registration fails or cannot be handled.
  Future<GaiaVgateRegisterResult?> register({required String vVoucher});

  /// Show Geetest verification dialog and get result.
  ///
  /// Returns null if user cancels or verification fails.
  Future<GeetestVerificationResult?> showVerification({
    required BuildContext context,
    required String token,
    required String gt,
    required String challenge,
  });

  /// Validate Geetest result and get grisk_id (gaia_vtoken).
  ///
  /// Returns null if validation fails.
  Future<String?> validate({
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  });
}

/// Result from Gaia VGate register API.
///
/// Source: biu/src/service/gaia-vgate-register.ts
class GaiaVgateRegisterResult {
  const GaiaVgateRegisterResult({
    required this.token,
    this.gt,
    this.challenge,
  });

  /// Verification token for subsequent validate call.
  final String token;

  /// Geetest gt parameter. Null if Geetest is not available.
  final String? gt;

  /// Geetest challenge parameter. Null if Geetest is not available.
  final String? challenge;

  /// Check if Geetest verification is available.
  bool get hasGeetest => gt != null && challenge != null;
}

/// Result from Geetest verification dialog.
///
/// Source: biu/src/service/request/response-interceptors.ts
class GeetestVerificationResult {
  const GeetestVerificationResult({
    required this.challenge,
    required this.validate,
    required this.seccode,
  });

  /// Updated challenge from Geetest.
  final String challenge;

  /// Validate token from Geetest.
  final String validate;

  /// Seccode from Geetest.
  final String seccode;
}

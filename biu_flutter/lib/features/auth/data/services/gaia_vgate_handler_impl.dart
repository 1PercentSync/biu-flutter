import 'package:flutter/material.dart';

import '../../../../core/network/gaia_vgate/gaia_vgate_handler.dart';
import '../../presentation/widgets/geetest_dialog.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of GaiaVgateHandler using auth feature components.
///
/// This class bridges the core network layer's abstract interface with
/// the auth feature's concrete implementations for Gaia VGate risk control.
///
/// Source: biu/src/service/request/response-interceptors.ts
class GaiaVgateHandlerImpl implements GaiaVgateHandler {
  GaiaVgateHandlerImpl({
    AuthRemoteDatasource? authDatasource,
  }) : _authDatasource = authDatasource;

  /// Lazily initialized auth datasource to avoid circular dependency
  AuthRemoteDatasource? _authDatasource;
  AuthRemoteDatasource get _datasource =>
      _authDatasource ??= AuthRemoteDatasource();

  @override
  Future<GaiaVgateRegisterResult?> register({required String vVoucher}) async {
    try {
      final response = await _datasource.registerGaiaVgate(vVoucher: vVoucher);

      if (!response.isSuccess || response.data == null) {
        debugPrint('[GaiaVgateHandler] Register failed: ${response.message}');
        return null;
      }

      final data = response.data!;
      return GaiaVgateRegisterResult(
        token: data.token,
        gt: data.geetest?.gt,
        challenge: data.geetest?.challenge,
      );
    } catch (e) {
      debugPrint('[GaiaVgateHandler] Register error: $e');
      return null;
    }
  }

  @override
  Future<GeetestVerificationResult?> showVerification({
    required BuildContext context,
    required String token,
    required String gt,
    required String challenge,
  }) async {
    try {
      final result = await GeetestDialog.show(
        context,
        token: token,
        gt: gt,
        challenge: challenge,
      );

      if (result == null) {
        return null;
      }

      return GeetestVerificationResult(
        challenge: result.challenge,
        validate: result.validate,
        seccode: result.seccode,
      );
    } catch (e) {
      debugPrint('[GaiaVgateHandler] Show verification error: $e');
      return null;
    }
  }

  @override
  Future<String?> validate({
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    try {
      final response = await _datasource.validateGaiaVgate(
        token: token,
        challenge: challenge,
        validate: validate,
        seccode: seccode,
      );

      if (!response.isSuccess || response.data == null) {
        debugPrint('[GaiaVgateHandler] Validate failed: ${response.message}');
        return null;
      }

      final data = response.data!;
      if (!data.isSuccessful || data.griskId.isEmpty) {
        debugPrint('[GaiaVgateHandler] Validation not successful');
        return null;
      }

      return data.griskId;
    } catch (e) {
      debugPrint('[GaiaVgateHandler] Validate error: $e');
      return null;
    }
  }
}

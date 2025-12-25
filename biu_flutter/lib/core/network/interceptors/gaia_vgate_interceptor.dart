import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../router/navigator_key.dart';
import '../dio_client.dart';
import '../gaia_vgate/gaia_vgate_handler.dart';
import '../gaia_vgate/gaia_vgate_provider.dart';

/// Interceptor for handling Bilibili Gaia VGate risk control
///
/// Source: biu/src/service/request/response-interceptors.ts#geetestInterceptors
///
/// When API returns v_voucher in response data, this indicates risk control
/// has been triggered. This interceptor:
/// 1. Calls Gaia VGate register to get Geetest captcha parameters
/// 2. Shows Geetest verification dialog to user
/// 3. Calls Gaia VGate validate to get grisk_id (gaia_vtoken)
/// 4. Retries the original request with gaia_vtoken parameter
class GaiaVgateInterceptor extends Interceptor {
  GaiaVgateInterceptor();

  /// Get the handler from holder (may be null if not initialized)
  GaiaVgateHandler? get _handler => GaiaVgateHandlerHolder.handler;

  /// Track if we're currently handling a v_voucher to prevent recursion
  bool _isHandlingVoucher = false;

  @override
  Future<void> onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    // Skip if not a JSON response
    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      handler.next(response);
      return;
    }

    // Check for v_voucher in response (risk control triggered)
    final responseData = data['data'];
    if (responseData is! Map<String, dynamic>) {
      handler.next(response);
      return;
    }

    final vVoucher = responseData['v_voucher'] as String?;
    if (vVoucher == null || vVoucher.isEmpty) {
      handler.next(response);
      return;
    }

    // Prevent recursive handling
    if (_isHandlingVoucher) {
      debugPrint('[GaiaVgate] Already handling v_voucher, skipping');
      handler.next(response);
      return;
    }

    // Check if handler is available
    final handlerInstance = _handler;
    if (handlerInstance == null) {
      debugPrint('[GaiaVgate] Handler not initialized, skipping verification');
      handler.next(response);
      return;
    }

    // Platform check for WebView support:
    // 1. First check kIsWeb - web platform doesn't support native WebView
    // 2. Then check for specific platforms - only Android and iOS support WebView
    // This order is important because kIsWeb must be checked before Platform.is*
    // (Platform.is* throws on web), and we need WebView for Geetest captcha.
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('[GaiaVgate] WebView not supported on this platform');
      handler.next(response);
      return;
    }

    // Check if global navigator is available
    final context = globalContext;
    if (context == null || !isNavigatorMounted) {
      debugPrint('[GaiaVgate] Navigator not available');
      handler.next(response);
      return;
    }

    debugPrint('[GaiaVgate] Risk control detected, v_voucher: ${vVoucher.substring(0, 20)}...');

    _isHandlingVoucher = true;
    try {
      final retryResponse = await _handleGaiaVgate(
        handler: handlerInstance,
        vVoucher: vVoucher,
        originalResponse: response,
        context: context,
      );

      if (retryResponse != null) {
        handler.next(retryResponse);
      } else {
        // User cancelled or verification failed, return original response
        handler.next(response);
      }
    } catch (e) {
      debugPrint('[GaiaVgate] Error: $e');
      handler.next(response);
    } finally {
      _isHandlingVoucher = false;
    }
  }

  /// Handle Gaia VGate risk control verification
  Future<Response<dynamic>?> _handleGaiaVgate({
    required GaiaVgateHandler handler,
    required String vVoucher,
    required Response<dynamic> originalResponse,
    required BuildContext context,
  }) async {
    // 1. Call register to get Geetest parameters
    debugPrint('[GaiaVgate] Registering...');
    final registerResult = await handler.register(vVoucher: vVoucher);

    if (registerResult == null) {
      debugPrint('[GaiaVgate] Register failed');
      return null;
    }

    if (!registerResult.hasGeetest) {
      debugPrint('[GaiaVgate] No geetest data, cannot verify');
      return null;
    }

    // 2. Show Geetest dialog
    debugPrint('[GaiaVgate] Showing Geetest dialog...');
    if (!context.mounted) return null;

    final geetestResult = await handler.showVerification(
      context: context,
      token: registerResult.token,
      gt: registerResult.gt!,
      challenge: registerResult.challenge!,
    );

    if (geetestResult == null) {
      debugPrint('[GaiaVgate] User cancelled verification');
      return null;
    }

    // 3. Call validate to get grisk_id
    debugPrint('[GaiaVgate] Validating...');
    final gaiaVtoken = await handler.validate(
      token: registerResult.token,
      challenge: geetestResult.challenge,
      validate: geetestResult.validate,
      seccode: geetestResult.seccode,
    );

    if (gaiaVtoken == null || gaiaVtoken.isEmpty) {
      debugPrint('[GaiaVgate] Validation not successful');
      return null;
    }

    debugPrint('[GaiaVgate] Got gaia_vtoken: ${gaiaVtoken.substring(0, 20)}...');

    // 4. Store gaia_vtoken in cookie
    await DioClient.instance.setCookie(
      'x-bili-gaia-vtoken',
      gaiaVtoken,
      'bilibili.com',
    );

    // 5. Retry original request with gaia_vtoken
    debugPrint('[GaiaVgate] Retrying original request...');
    final originalRequest = originalResponse.requestOptions;

    // Add gaia_vtoken to query parameters
    final newQueryParams = Map<String, dynamic>.from(originalRequest.queryParameters);
    newQueryParams['gaia_vtoken'] = gaiaVtoken;

    final retryOptions = Options(
      method: originalRequest.method,
      headers: originalRequest.headers,
      contentType: originalRequest.contentType,
    );

    final retryResponse = await DioClient.instance.dio.request<dynamic>(
      originalRequest.path,
      data: originalRequest.data,
      queryParameters: newQueryParams,
      options: retryOptions,
    );

    debugPrint('[GaiaVgate] Retry successful');
    return retryResponse;
  }
}

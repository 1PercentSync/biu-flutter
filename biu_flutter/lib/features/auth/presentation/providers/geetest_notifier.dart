import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/captcha_response.dart';
import '../widgets/geetest_dialog.dart';

/// State for Geetest verification
class GeetestState {
  final bool isLoading;
  final String? errorMessage;
  final GeetestResult? result;

  const GeetestState({
    this.isLoading = false,
    this.errorMessage,
    this.result,
  });

  GeetestState copyWith({
    bool? isLoading,
    String? errorMessage,
    GeetestResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return GeetestState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

/// Provider for Geetest verification
class GeetestNotifier extends StateNotifier<GeetestState> {
  final AuthRemoteDatasource _datasource;

  GeetestNotifier(this._datasource) : super(const GeetestState());

  /// Verify using Geetest captcha
  /// Returns the verification result, or null if cancelled/failed
  Future<GeetestResult?> verify(BuildContext context) async {
    state = state.copyWith(isLoading: true, clearError: true, clearResult: true);

    try {
      // Get captcha challenge from server
      final captchaResponse = await _datasource.getCaptcha();

      if (!captchaResponse.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: captchaResponse.message.isEmpty
              ? '获取验证码失败'
              : captchaResponse.message,
        );
        return null;
      }

      final captchaData = captchaResponse.data!;

      if (captchaData.geetest == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '验证码数据无效',
        );
        return null;
      }

      state = state.copyWith(isLoading: false);

      // Show Geetest dialog
      if (!context.mounted) return null;

      final result = await GeetestDialog.show(
        context,
        token: captchaData.token,
        gt: captchaData.geetest!.gt,
        challenge: captchaData.geetest!.challenge,
      );

      if (result != null) {
        state = state.copyWith(result: result);
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Clear state
  void clear() {
    state = const GeetestState();
  }
}

/// Provider for GeetestNotifier
final geetestNotifierProvider =
    StateNotifierProvider.autoDispose<GeetestNotifier, GeetestState>((ref) {
  return GeetestNotifier(AuthRemoteDatasource());
});

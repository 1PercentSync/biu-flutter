import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_notifier.dart';

/// SMS login state
enum SmsLoginStatus {
  idle,
  sendingCode,
  codeSent,
  loggingIn,
  success,
  error,
}

/// SMS login state
class SmsLoginState {

  const SmsLoginState({
    this.status = SmsLoginStatus.idle,
    this.errorMessage,
    this.captchaKey,
    this.countryCode = 86, // Default to China
    this.countdown = 0,
  });
  final SmsLoginStatus status;
  final String? errorMessage;
  final String? captchaKey;
  final int countryCode;
  final int countdown;

  static const SmsLoginState initial = SmsLoginState();

  bool get isSendingCode => status == SmsLoginStatus.sendingCode;
  bool get isLoggingIn => status == SmsLoginStatus.loggingIn;
  bool get canSendCode => countdown == 0 && !isSendingCode;

  SmsLoginState copyWith({
    SmsLoginStatus? status,
    String? errorMessage,
    String? captchaKey,
    int? countryCode,
    int? countdown,
    bool clearError = false,
    bool clearCaptchaKey = false,
  }) {
    return SmsLoginState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      captchaKey: clearCaptchaKey ? null : (captchaKey ?? this.captchaKey),
      countryCode: countryCode ?? this.countryCode,
      countdown: countdown ?? this.countdown,
    );
  }
}

/// Provider for SMS login state
final smsLoginNotifierProvider =
    StateNotifierProvider.autoDispose<SmsLoginNotifier, SmsLoginState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  return SmsLoginNotifier(repository, authNotifier);
});

/// SMS login state notifier
class SmsLoginNotifier extends StateNotifier<SmsLoginState> {

  SmsLoginNotifier(this._repository, this._authNotifier)
      : super(SmsLoginState.initial);
  final AuthRepository _repository;
  final AuthNotifier _authNotifier;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Set country code
  void setCountryCode(int code) {
    state = state.copyWith(countryCode: code);
  }

  /// Send SMS verification code
  ///
  /// Note: This requires GeeTest captcha verification
  Future<bool> sendCode({
    required String phone,
    required String geetestToken,
    required String geetestChallenge,
    required String geetestValidate,
    required String geetestSeccode,
  }) async {
    final phoneNumber = int.tryParse(phone);
    if (phoneNumber == null) {
      state = state.copyWith(
        status: SmsLoginStatus.error,
        errorMessage: '请输入有效的手机号',
      );
      return false;
    }

    state = state.copyWith(
      status: SmsLoginStatus.sendingCode,
      clearError: true,
    );

    try {
      final (success, captchaKey, message) = await _repository.sendSmsCode(
        countryCode: state.countryCode,
        phone: phoneNumber,
        geetestToken: geetestToken,
        geetestChallenge: geetestChallenge,
        geetestValidate: geetestValidate,
        geetestSeccode: geetestSeccode,
      );

      if (success && captchaKey != null) {
        state = state.copyWith(
          status: SmsLoginStatus.codeSent,
          captchaKey: captchaKey,
        );
        _startCountdown();
        return true;
      } else {
        state = state.copyWith(
          status: SmsLoginStatus.error,
          errorMessage: message.isNotEmpty ? message : '发送验证码失败',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: SmsLoginStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Login with SMS code
  Future<bool> login({
    required String phone,
    required String code,
  }) async {
    final phoneNumber = int.tryParse(phone);
    final codeNumber = int.tryParse(code);

    if (phoneNumber == null) {
      state = state.copyWith(
        status: SmsLoginStatus.error,
        errorMessage: '请输入有效的手机号',
      );
      return false;
    }

    if (codeNumber == null) {
      state = state.copyWith(
        status: SmsLoginStatus.error,
        errorMessage: '请输入有效的验证码',
      );
      return false;
    }

    final captchaKey = state.captchaKey;
    if (captchaKey == null || captchaKey.isEmpty) {
      state = state.copyWith(
        status: SmsLoginStatus.error,
        errorMessage: '请先发送验证码',
      );
      return false;
    }

    state = state.copyWith(
      status: SmsLoginStatus.loggingIn,
      clearError: true,
    );

    try {
      final (success, refreshToken, message) = await _repository.loginWithSms(
        countryCode: state.countryCode,
        phone: phoneNumber,
        code: codeNumber,
        captchaKey: captchaKey,
      );

      if (success) {
        state = state.copyWith(status: SmsLoginStatus.success);
        await _authNotifier.onLoginSuccess(refreshToken);
        return true;
      } else {
        state = state.copyWith(
          status: SmsLoginStatus.error,
          errorMessage: message.isNotEmpty ? message : '登录失败',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: SmsLoginStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    state = state.copyWith(countdown: 60);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown > 0) {
        state = state.copyWith(countdown: state.countdown - 1);
      } else {
        timer.cancel();
      }
    });
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    _countdownTimer?.cancel();
    state = SmsLoginState.initial;
  }
}

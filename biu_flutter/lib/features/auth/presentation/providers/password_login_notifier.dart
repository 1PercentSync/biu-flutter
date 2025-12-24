import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rsa_utils.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_notifier.dart';

/// Password login state
enum PasswordLoginStatus {
  idle,
  loading,
  needCaptcha,
  success,
  error,
}

/// Password login state
class PasswordLoginState {
  final PasswordLoginStatus status;
  final String? errorMessage;
  final bool isPasswordVisible;

  const PasswordLoginState({
    this.status = PasswordLoginStatus.idle,
    this.errorMessage,
    this.isPasswordVisible = false,
  });

  static const PasswordLoginState initial = PasswordLoginState();

  bool get isLoading => status == PasswordLoginStatus.loading;

  PasswordLoginState copyWith({
    PasswordLoginStatus? status,
    String? errorMessage,
    bool? isPasswordVisible,
    bool clearError = false,
  }) {
    return PasswordLoginState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}

/// Provider for password login state
final passwordLoginNotifierProvider = StateNotifierProvider.autoDispose<
    PasswordLoginNotifier, PasswordLoginState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  return PasswordLoginNotifier(repository, authNotifier);
});

/// Password login state notifier
class PasswordLoginNotifier extends StateNotifier<PasswordLoginState> {
  final AuthRepository _repository;
  final AuthNotifier _authNotifier;

  PasswordLoginNotifier(this._repository, this._authNotifier)
      : super(PasswordLoginState.initial);

  /// Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  /// Login with password
  ///
  /// Note: This currently requires manual captcha handling (geetest).
  /// In a full implementation, you would integrate with GeeTest SDK.
  Future<bool> login({
    required String username,
    required String password,
    required String geetestToken,
    required String geetestChallenge,
    required String geetestValidate,
    required String geetestSeccode,
  }) async {
    if (username.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: PasswordLoginStatus.error,
        errorMessage: '请输入账号和密码',
      );
      return false;
    }

    state = state.copyWith(
      status: PasswordLoginStatus.loading,
      clearError: true,
    );

    try {
      // Get RSA public key
      final (hash, publicKey) = await _repository.getPasswordKey();

      // Encrypt password
      final encryptedPassword = RsaUtils.encryptPassword(
        publicKeyPem: publicKey,
        hash: hash,
        password: password,
      );

      if (encryptedPassword == null) {
        state = state.copyWith(
          status: PasswordLoginStatus.error,
          errorMessage: '密码加密失败，请重试',
        );
        return false;
      }

      // Login
      final (success, refreshToken, message) = await _repository.loginWithPassword(
        username: username,
        encryptedPassword: encryptedPassword,
        geetestToken: geetestToken,
        geetestChallenge: geetestChallenge,
        geetestValidate: geetestValidate,
        geetestSeccode: geetestSeccode,
      );

      if (success) {
        state = state.copyWith(status: PasswordLoginStatus.success);
        await _authNotifier.onLoginSuccess(refreshToken);
        return true;
      } else {
        state = state.copyWith(
          status: PasswordLoginStatus.error,
          errorMessage: message.isNotEmpty ? message : '登录失败',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: PasswordLoginStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = PasswordLoginState.initial;
  }
}

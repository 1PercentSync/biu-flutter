import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/cookie_refresh_service.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Provider for the auth state notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Convenience provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

/// Convenience provider for current user
final currentUserProvider = Provider((ref) {
  return ref.watch(authNotifierProvider).user;
});

/// Auth state notifier
///
/// Manages authentication state including login, logout, and session refresh.
/// Source: biu/src/store/user.ts#useUser (auth-related state management)
/// Source: biu/src/store/token.ts (token storage logic)
class AuthNotifier extends StateNotifier<AuthState> {

  AuthNotifier(this._repository)
      : _cookieRefreshService = CookieRefreshService(AuthRemoteDatasource()),
        super(AuthState.initial) {
    // Check auth status on initialization
    checkAuthStatus();
  }
  final AuthRepository _repository;
  final CookieRefreshService _cookieRefreshService;

  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    try {
      // Get stored token
      final storedToken = await _repository.getStoredToken();

      // Try to get current user
      final user = await _repository.getCurrentUser();

      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: storedToken,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle successful login
  Future<void> onLoginSuccess(String? refreshToken) async {
    // Store refresh token
    if (refreshToken != null) {
      final token = AuthToken(
        refreshToken: refreshToken,
        nextCheckRefreshTime: _getNextCheckTime(),
      );
      await _repository.storeToken(token);
      state = state.copyWith(token: token);
    }

    // Fetch user info
    await checkAuthStatus();
  }

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.authenticating);

    try {
      await _repository.logout();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearToken: true,
        clearError: true,
      );
    } catch (e) {
      // Even on error, set as unauthenticated
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearToken: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh user info
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user);
      } else {
        // User is no longer authenticated
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        );
      }
    } catch (e) {
      // Ignore errors during refresh
    }
  }

  /// Check and refresh session if needed
  Future<void> checkAndRefreshSession() async {
    final token = state.token;
    if (token == null || !token.hasToken) return;
    if (!token.shouldCheckRefresh) return;

    state = state.copyWith(isRefreshing: true);

    try {
      // Perform cookie refresh using the service
      final (success, newRefreshToken) =
          await _cookieRefreshService.refreshCookieIfNeeded(token.refreshToken);

      if (success && newRefreshToken != null) {
        // Update token with new refresh token and next check time
        final newToken = token.copyWith(
          refreshToken: newRefreshToken,
          nextCheckRefreshTime: _getNextCheckTime(),
        );
        await _repository.storeToken(newToken);
        state = state.copyWith(token: newToken, isRefreshing: false);
      } else {
        // Just update the check time to try again later
        final newToken = token.copyWith(
          nextCheckRefreshTime: _getNextCheckTime(),
        );
        await _repository.storeToken(newToken);
        state = state.copyWith(token: newToken, isRefreshing: false);
      }
    } catch (e) {
      state = state.copyWith(isRefreshing: false);
    }
  }

  /// Set authenticating state
  void setAuthenticating() {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearError: true,
    );
  }

  /// Set error state
  void setError(String message) {
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Get next refresh check time (2 days from now)
  int _getNextCheckTime() {
    return (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
        (2 * 24 * 60 * 60); // 2 days in seconds
  }
}

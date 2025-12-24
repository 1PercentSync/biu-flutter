import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';

/// Possible authentication states
enum AuthStatus {
  /// Initial state, checking auth status
  initial,

  /// Not logged in
  unauthenticated,

  /// Currently authenticating
  authenticating,

  /// Successfully authenticated
  authenticated,

  /// Authentication failed
  error,
}

/// Authentication state
class AuthState {
  /// Current authentication status
  final AuthStatus status;

  /// Current user (if authenticated)
  final User? user;

  /// Auth token data
  final AuthToken? token;

  /// Error message (if error state)
  final String? errorMessage;

  /// Whether a refresh check is in progress
  final bool isRefreshing;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
    this.isRefreshing = false,
  });

  /// Initial state
  static const AuthState initial = AuthState();

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Check if still loading initial state
  bool get isLoading => status == AuthStatus.initial;

  /// Create a copy with updated fields
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    AuthToken? token,
    String? errorMessage,
    bool? isRefreshing,
    bool clearUser = false,
    bool clearToken = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      token: clearToken ? null : (token ?? this.token),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.uname}, isRefreshing: $isRefreshing)';
  }
}

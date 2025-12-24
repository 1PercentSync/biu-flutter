/// Authentication token storage
///
/// Source: biu/src/store/token.ts (token state structure)
class AuthToken {

  const AuthToken({
    this.refreshToken,
    this.nextCheckRefreshTime,
  });

  /// Create from JSON
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      refreshToken: json['refresh_token'] as String?,
      nextCheckRefreshTime: json['next_check_refresh_time'] as int?,
    );
  }
  /// Refresh token from login
  final String? refreshToken;

  /// Next time to check for cookie refresh (Unix timestamp in seconds)
  final int? nextCheckRefreshTime;

  /// Check if token data exists
  bool get hasToken => refreshToken != null && refreshToken!.isNotEmpty;

  /// Check if refresh check is due
  bool get shouldCheckRefresh {
    if (nextCheckRefreshTime == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= nextCheckRefreshTime!;
  }

  /// Create a copy with updated fields
  AuthToken copyWith({
    String? refreshToken,
    int? nextCheckRefreshTime,
  }) {
    return AuthToken(
      refreshToken: refreshToken ?? this.refreshToken,
      nextCheckRefreshTime: nextCheckRefreshTime ?? this.nextCheckRefreshTime,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
      'next_check_refresh_time': nextCheckRefreshTime,
    };
  }

  /// Empty token
  static const AuthToken empty = AuthToken();
}

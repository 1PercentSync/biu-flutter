import '../constants/response_code.dart';

/// Base exception class for all application exceptions
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  /// Error message
  final String message;

  /// Error code (optional)
  final int? code;

  /// Stack trace (optional)
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception for network-related errors
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.stackTrace,
    this.statusCode,
    this.url,
  });

  /// HTTP status code
  final int? statusCode;

  /// Request URL
  final String? url;

  @override
  String toString() => 'NetworkException: $message (statusCode: $statusCode)';
}

/// Exception for Bilibili API errors
class BilibiliApiException extends AppException {
  BilibiliApiException({
    required int code,
    String? message,
    super.stackTrace,
    this.requestUrl,
  }) : super(
          code: code,
          message: message ?? BiliErrorCode.fromCode(code)?.message ?? 'Unknown error',
        );

  /// The request URL that caused the error
  final String? requestUrl;

  /// Check if this error indicates authentication is required
  bool get isAuthRequired => BiliErrorCode.isAuthRequired(code ?? 0);

  /// Get the BiliErrorCode enum value
  BiliErrorCode? get errorCode => BiliErrorCode.fromCode(code ?? 0);

  @override
  String toString() => 'BilibiliApiException: $message (code: $code)';
}

/// Exception for authentication errors
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.stackTrace,
    this.requiresRelogin = false,
  });

  /// Whether the user needs to re-login
  final bool requiresRelogin;

  @override
  String toString() => 'AuthException: $message';
}

/// Exception for storage-related errors
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.stackTrace,
    this.key,
  });

  /// The storage key involved in the error
  final String? key;

  @override
  String toString() => 'StorageException: $message (key: $key)';
}

/// Exception for player-related errors
class PlayerException extends AppException {
  const PlayerException({
    required super.message,
    super.code,
    super.stackTrace,
    this.source,
  });

  /// The audio source that caused the error
  final String? source;

  @override
  String toString() => 'PlayerException: $message';
}

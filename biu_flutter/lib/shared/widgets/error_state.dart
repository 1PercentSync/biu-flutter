import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A widget to display error state with retry option.
class ErrorState extends StatelessWidget {

  /// Create an error state for network errors
  factory ErrorState.network({
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      title: 'Network Error',
      message: 'Please check your internet connection and try again.',
      icon: const Icon(
        Icons.wifi_off,
        size: 48,
        color: AppColors.textTertiary,
      ),
      onRetry: onRetry,
    );
  }

  /// Create an error state for server errors
  factory ErrorState.server({
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      title: 'Server Error',
      message: 'The server is temporarily unavailable. Please try again later.',
      icon: const Icon(
        Icons.cloud_off,
        size: 48,
        color: AppColors.textTertiary,
      ),
      onRetry: onRetry,
    );
  }

  /// Create an error state for authentication errors
  factory ErrorState.auth({
    VoidCallback? onLogin,
  }) {
    return ErrorState(
      title: 'Login Required',
      message: 'Please log in to access this content.',
      icon: const Icon(
        Icons.lock_outline,
        size: 48,
        color: AppColors.textTertiary,
      ),
      onRetry: onLogin,
      retryText: 'Log In',
    );
  }
  const ErrorState({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryText,
  });

  /// Optional title text
  final String? title;

  /// Error message
  final String? message;

  /// Optional custom icon
  final Widget? icon;

  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  /// Custom retry button text
  final String? retryText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message ?? 'Something went wrong',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryText ?? 'Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A snackbar-style error message
class ErrorSnackBar {
  ErrorSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}

/// A banner-style error message that stays at the top
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    required this.message, super.key,
    this.onDismiss,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: AppColors.error,
      leading: const Icon(Icons.error_outline, color: Colors.white),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        TextButton(
          onPressed: onDismiss ??
              () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
          child: const Text(
            'Dismiss',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A widget to display error state with retry option.
///
/// This is a mobile-adapted version that provides flexible error display patterns
/// including full-screen states, snackbars, and banners.
///
/// Source: biu/src/components/error-fallback/index.tsx#Fallback (adapted for mobile)
class ErrorState extends StatelessWidget {

  /// Create an error state for network errors
  factory ErrorState.network({
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      title: '网络错误',
      message: '请检查网络连接后重试',
      icon: const Icon(
        CupertinoIcons.wifi_slash,
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
      title: '服务器错误',
      message: '服务器暂时不可用，请稍后重试',
      icon: const Icon(
        CupertinoIcons.xmark_circle_fill,
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
      title: '需要登录',
      message: '请登录以访问此内容',
      icon: const Icon(
        CupertinoIcons.lock_fill,
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
                  CupertinoIcons.exclamationmark_circle_fill,
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
                icon: const Icon(CupertinoIcons.refresh, size: 18),
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
                label: '重试',
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
      leading: const Icon(CupertinoIcons.exclamationmark_circle_fill, color: Colors.white),
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

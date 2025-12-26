import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/router/navigator_key.dart';
import '../theme/theme.dart';

/// Global snackbar utility for showing messages from anywhere in the app
class GlobalSnackbar {
  GlobalSnackbar._();

  /// Show an error snackbar
  static void showError(String message) {
    _showSnackbar(
      message,
      backgroundColor: Colors.red.shade800,
      icon: CupertinoIcons.exclamationmark_circle,
    );
  }

  /// Show a warning snackbar
  static void showWarning(String message) {
    _showSnackbar(
      message,
      backgroundColor: Colors.orange.shade800,
      icon: CupertinoIcons.exclamationmark_triangle,
    );
  }

  /// Show a success snackbar
  static void showSuccess(String message) {
    _showSnackbar(
      message,
      backgroundColor: Colors.green.shade800,
      icon: CupertinoIcons.checkmark_circle,
    );
  }

  /// Show an info snackbar
  static void showInfo(String message) {
    _showSnackbar(
      message,
      backgroundColor: AppColors.surface,
      icon: CupertinoIcons.info,
    );
  }

  static void _showSnackbar(
    String message, {
    Color? backgroundColor,
    IconData? icon,
  }) {
    final context = globalContext;
    if (context == null) {
      debugPrint('[GlobalSnackbar] No context available, cannot show: $message');
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint('[GlobalSnackbar] No ScaffoldMessenger found: $message');
      return;
    }

    messenger
      ..clearSnackBars()
      ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }
}

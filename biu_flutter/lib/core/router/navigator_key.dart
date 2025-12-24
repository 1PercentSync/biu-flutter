import 'package:flutter/material.dart';

/// Global context holder for showing dialogs from anywhere (e.g., interceptors)
///
/// This allows network interceptors to trigger UI elements like captcha dialogs
/// when risk control (v_voucher) is detected.
class GlobalContextHolder {
  GlobalContextHolder._();

  static BuildContext? _context;

  /// Set the global context (should be called from the app root)
  // ignore: use_setters_to_change_properties
  static void setContext(BuildContext context) {
    _context = context;
  }

  /// Clear the global context (should be called when app is disposed)
  static void clearContext() {
    _context = null;
  }

  /// Get the current global context
  static BuildContext? get context => _context;

  /// Check if the global context is available and mounted
  static bool get isAvailable {
    final ctx = _context;
    if (ctx == null) return false;
    try {
      // Check if context is still mounted by trying to access it
      return ctx.mounted;
    } catch (e) {
      return false;
    }
  }
}

/// Get the current BuildContext from the global holder
///
/// Returns null if the context is not set or not mounted
BuildContext? get globalContext => GlobalContextHolder.isAvailable ? GlobalContextHolder.context : null;

/// Check if the global navigator is mounted and ready
bool get isNavigatorMounted => GlobalContextHolder.isAvailable;

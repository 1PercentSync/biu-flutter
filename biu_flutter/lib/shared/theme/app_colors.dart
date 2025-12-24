import 'package:flutter/material.dart';

/// Application color palette matching the source design
class AppColors {
  AppColors._();

  // ============ Brand Colors ============

  /// Primary green color
  static const Color primary = Color(0xFF17C964);

  /// Primary color with variants
  static const Color primaryLight = Color(0xFF4ADE80);
  static const Color primaryDark = Color(0xFF15803D);

  // ============ Background Colors ============

  /// Main background color (darkest)
  static const Color background = Color(0xFF18181B);

  /// Content area background (slightly lighter)
  static const Color contentBackground = Color(0xFF1F1F1F);

  /// Surface color for cards and elevated elements
  static const Color surface = Color(0xFF27272A);

  /// Elevated surface for modals and popups
  static const Color surfaceElevated = Color(0xFF3F3F46);

  // ============ Text Colors ============

  /// Primary text color
  static const Color textPrimary = Color(0xFFFAFAFA);

  /// Secondary text color (muted)
  static const Color textSecondary = Color(0xFFA1A1AA);

  /// Tertiary text color (very muted)
  static const Color textTertiary = Color(0xFF71717A);

  /// Disabled text color
  static const Color textDisabled = Color(0xFF52525B);

  // ============ Functional Colors ============

  /// Error/danger color
  static const Color error = Color(0xFFEF4444);

  /// Warning color
  static const Color warning = Color(0xFFF59E0B);

  /// Success color
  static const Color success = Color(0xFF22C55E);

  /// Info color
  static const Color info = Color(0xFF3B82F6);

  // ============ UI Colors ============

  /// Divider color
  static const Color divider = Color(0xFF27272A);

  /// Border color
  static const Color border = Color(0xFF3F3F46);

  /// Overlay color (for modals backdrop)
  static const Color overlay = Color(0x80000000);

  /// Shimmer base color (for loading placeholders)
  static const Color shimmerBase = Color(0xFF27272A);

  /// Shimmer highlight color
  static const Color shimmerHighlight = Color(0xFF3F3F46);

  // ============ Player Colors ============

  /// Progress bar background
  static const Color progressBackground = Color(0xFF3F3F46);

  /// Progress bar buffered
  static const Color progressBuffered = Color(0xFF52525B);

  // ============ Navigation Colors ============

  /// Navigation bar background
  static const Color navigationBackground = Color(0xFF1F1F1F);

  /// Navigation indicator (selected)
  static Color navigationIndicator = primary.withValues(alpha: 0.2);

  // ============ Bilibili Brand Colors ============

  /// Bilibili pink (for VIP indicators)
  static const Color bilibiliPink = Color(0xFFFB7299);

  /// Bilibili blue
  static const Color bilibiliBlue = Color(0xFF00A1D6);
}

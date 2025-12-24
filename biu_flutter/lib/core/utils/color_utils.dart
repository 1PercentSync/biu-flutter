import 'package:flutter/material.dart';

/// Utility functions for color manipulation.
///
/// Provides hex color parsing, HSL conversion, and color adjustment functions.
/// Extended beyond source with Flutter-specific utilities.
///
/// Source: biu/src/common/utils/color.ts (hexToHsl, hexToRgb)
class ColorUtils {
  ColorUtils._();

  /// Parse hex color string to Color
  /// Supports formats: #RGB, #RRGGBB, #AARRGGBB
  static Color? fromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;

    var colorStr = hex.replaceFirst('#', '');

    // Handle short format (#RGB)
    if (colorStr.length == 3) {
      colorStr = colorStr.split('').map((c) => '$c$c').join();
    }

    // Handle #RRGGBB format (add alpha)
    if (colorStr.length == 6) {
      colorStr = 'FF$colorStr';
    }

    try {
      return Color(int.parse(colorStr, radix: 16));
    } catch (_) {
      return null;
    }
  }

  /// Convert Color to hex string
  static String toHex(Color color, {bool includeAlpha = false}) {
    if (includeAlpha) {
      return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Darken a color by a percentage (0.0 - 1.0)
  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Lighten a color by a percentage (0.0 - 1.0)
  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Get a contrasting text color (black or white) for a given background
  static Color getContrastingTextColor(Color background) {
    // Calculate relative luminance using sRGB
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Create a color with modified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}

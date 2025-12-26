import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Utility class for computing frosted glass effect colors.
///
/// Glass colors are derived from the user's background color setting,
/// ensuring consistency with the theme system while providing the
/// characteristic iOS frosted glass appearance.
///
/// Usage:
/// ```dart
/// final backgroundColor = ref.watch(settingsNotifierProvider).backgroundColor;
/// final glassColor = GlassStyles.glassBackground(backgroundColor);
/// ```
class GlassStyles {
  GlassStyles._();

  /// Computes the standard frosted glass background color.
  ///
  /// Returns the [backgroundColor] with 88% opacity, suitable for
  /// header backdrops and navigation backgrounds.
  static Color glassBackground(Color backgroundColor) {
    return backgroundColor.withValues(alpha: AppTheme.glassOpacity);
  }

  /// Computes the elevated frosted glass background color.
  ///
  /// Returns a slightly lightened version of [backgroundColor] with 85% opacity,
  /// suitable for floating elements like the mini player that need to stand out
  /// from the standard glass backdrop.
  static Color glassBackgroundElevated(Color backgroundColor) {
    final hsl = HSLColor.fromColor(backgroundColor);
    final lighter = hsl.withLightness(
      (hsl.lightness + AppTheme.glassLightnessBoost).clamp(0.0, 1.0),
    );
    return lighter.toColor().withValues(alpha: AppTheme.glassOpacityElevated);
  }

  /// Creates an ImageFilter for standard blur effect.
  ///
  /// Uses 20px sigma blur, suitable for background glass layers.
  static ImageFilter get blurFilter => ImageFilter.blur(
        sigmaX: AppTheme.glassBlur,
        sigmaY: AppTheme.glassBlur,
      );

  /// Creates an ImageFilter for strong blur effect.
  ///
  /// Uses 30px sigma blur, suitable for elevated elements like mini player.
  static ImageFilter get blurFilterStrong => ImageFilter.blur(
        sigmaX: AppTheme.glassBlurStrong,
        sigmaY: AppTheme.glassBlurStrong,
      );

  /// Creates an ImageFilter with custom blur sigma.
  static ImageFilter blurFilterCustom(double sigma) => ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
      );

  /// Inactive tab/nav item color (white with 35% opacity).
  ///
  /// This matches the iOS system style for inactive navigation items.
  static Color get inactiveColor => Colors.white.withValues(alpha: 0.35);

  /// Active text color (solid white).
  static Color get activeColor => Colors.white;
}

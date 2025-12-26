
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/presentation/providers/settings_notifier.dart';
import '../../theme/app_theme.dart';
import 'glass_styles.dart';

/// A frosted glass container widget with iOS-style backdrop blur effect.
///
/// This widget wraps content in a backdrop blur filter to create the
/// characteristic iOS frosted glass appearance. Colors are automatically
/// derived from the user's theme settings.
///
/// Usage:
/// ```dart
/// FrostedGlass(
///   child: Text('Content on glass'),
/// )
/// ```
///
/// For elevated elements (like mini player), use [isElevated]:
/// ```dart
/// FrostedGlass(
///   isElevated: true,
///   isStrong: true,
///   child: MiniPlayerContent(),
/// )
/// ```
class FrostedGlass extends ConsumerWidget {
  const FrostedGlass({
    super.key,
    this.child,
    this.isStrong = false,
    this.isElevated = false,
    this.borderRadius,
    this.padding,
  });

  /// The widget to display on top of the frosted glass.
  final Widget? child;

  /// Whether to use strong blur (30px) instead of standard (20px).
  ///
  /// Use strong blur for floating elements like mini player.
  final bool isStrong;

  /// Whether to use elevated glass color (slightly lighter + 85% opacity).
  ///
  /// Use elevated color for elements that need to stand out from
  /// the standard glass backdrop.
  final bool isElevated;

  /// Optional border radius for the glass container.
  final BorderRadius? borderRadius;

  /// Optional padding inside the glass container.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final backgroundColor = settings.backgroundColor;

    final glassColor = isElevated
        ? GlassStyles.glassBackgroundElevated(backgroundColor)
        : GlassStyles.glassBackground(backgroundColor);

    final filter = isStrong
        ? GlassStyles.blurFilterStrong
        : GlassStyles.blurFilter;

    Widget content = BackdropFilter(
      filter: filter,
      child: Container(
        decoration: BoxDecoration(
          color: glassColor,
          borderRadius: borderRadius,
        ),
        padding: padding,
        child: child,
      ),
    );

    // Constrain the blur area with ClipRect/ClipRRect for performance
    if (borderRadius != null) {
      content = ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    } else {
      content = ClipRect(child: content);
    }

    return content;
  }
}

/// A positioned frosted glass backdrop for use in Stack layouts.
///
/// This is a convenience widget for creating glass backdrop layers
/// that span a specific area of the screen.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     // Content
///     Positioned.fill(child: PageView(...)),
///     // Bottom glass backdrop
///     GlassBackdrop(
///       height: 49 + bottomSafeArea,
///       alignment: Alignment.bottomCenter,
///     ),
///   ],
/// )
/// ```
class GlassBackdrop extends ConsumerWidget {
  const GlassBackdrop({
    super.key,
    this.height,
    this.width,
    this.alignment = Alignment.topCenter,
    this.isStrong = false,
  });

  /// Height of the backdrop. If null, expands to fill available space.
  final double? height;

  /// Width of the backdrop. If null, expands to fill available space.
  final double? width;

  /// Alignment within the parent Stack.
  final Alignment alignment;

  /// Whether to use strong blur effect.
  final bool isStrong;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final backgroundColor = settings.backgroundColor;
    final glassColor = GlassStyles.glassBackground(backgroundColor);

    final filter = isStrong
        ? GlassStyles.blurFilterStrong
        : GlassStyles.blurFilter;

    return Align(
      alignment: alignment,
      child: ClipRect(
        child: BackdropFilter(
          filter: filter,
          child: Container(
            height: height,
            width: width ?? double.infinity,
            color: glassColor,
          ),
        ),
      ),
    );
  }
}

/// Helper widget that provides layout information for glass-based layouts.
///
/// Calculates the required padding for content to avoid being occluded
/// by floating glass elements (mini player, bottom nav).
class GlassLayoutInfo extends InheritedWidget {
  const GlassLayoutInfo({
    required super.child, required this.bottomContentPadding, required this.topContentPadding, super.key,
  });

  /// Padding needed at the bottom of content to avoid floating elements.
  final double bottomContentPadding;

  /// Padding needed at the top of content to avoid header/glass backdrop.
  final double topContentPadding;

  static GlassLayoutInfo? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GlassLayoutInfo>();
  }

  /// Calculates bottom content padding for MainShell.
  ///
  /// Includes: bottom nav height + safe area + mini player + margins
  static double calculateBottomPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomSafe = mediaQuery.padding.bottom;

    return AppTheme.bottomNavHeight +
        bottomSafe +
        AppTheme.miniPlayerHeight +
        AppTheme.miniPlayerMargin * 2;
  }

  /// Calculates top content padding for screens with glass header.
  ///
  /// Includes: safe area top + header height
  static double calculateTopPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topSafe = mediaQuery.padding.top;

    return topSafe + AppTheme.tabHeaderHeight;
  }

  @override
  bool updateShouldNotify(GlassLayoutInfo oldWidget) {
    return bottomContentPadding != oldWidget.bottomContentPadding ||
        topContentPadding != oldWidget.topContentPadding;
  }
}

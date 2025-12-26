import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'cached_image.dart';

/// A reusable user avatar widget with optional VIP badge overlay.
///
/// Displays a circular avatar with fallback to a person icon.
/// Can show a VIP badge in the bottom-right corner.
///
/// Source: Extracted from features/follow/presentation/widgets/following_card.dart
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.size = 48,
    this.showVipBadge = false,
    this.borderRadius,
    this.fallbackIcon,
    this.fallbackIconSize,
    this.backgroundColor,
  });

  /// Avatar image URL
  final String? avatarUrl;

  /// Avatar size (width and height)
  final double size;

  /// Whether to show VIP badge
  final bool showVipBadge;

  /// Custom border radius (defaults to circular)
  final BorderRadius? borderRadius;

  /// Custom fallback icon
  final IconData? fallbackIcon;

  /// Custom fallback icon size
  final double? fallbackIconSize;

  /// Background color for fallback
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(size);
    final effectiveFallbackIcon = fallbackIcon ?? CupertinoIcons.person_fill;
    final effectiveFallbackIconSize = fallbackIconSize ?? size / 2;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.surface;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? AppCachedImage(
                  imageUrl: avatarUrl,
                  width: size,
                  height: size,
                )
              : Container(
                  width: size,
                  height: size,
                  color: effectiveBackgroundColor,
                  child: Icon(
                    effectiveFallbackIcon,
                    size: effectiveFallbackIconSize,
                    color: AppColors.textTertiary,
                  ),
                ),
        ),
        // VIP badge overlay
        if (showVipBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.star_fill,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

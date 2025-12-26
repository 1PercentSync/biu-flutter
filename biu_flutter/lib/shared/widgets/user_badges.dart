import 'package:flutter/material.dart';

/// Verification icon for official accounts.
///
/// Shows different colors based on verification type:
/// - Type 0 (Personal): Amber
/// - Type 1 (Organization): Blue
///
/// Source: Extracted from features/follow/presentation/widgets/following_card.dart
class VerificationIcon extends StatelessWidget {
  const VerificationIcon({
    required this.type,
    super.key,
    this.size = 14,
  });

  /// Verification type (0 = personal, 1 = organization)
  final int type;

  /// Icon size
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified,
      size: size,
      color: type == 0 ? Colors.amber : Colors.blue,
    );
  }
}

/// VIP badge widget.
///
/// Displays a small pink badge with "VIP" text.
///
/// Source: Extracted from features/follow/presentation/widgets/following_card.dart
class VipBadge extends StatelessWidget {
  const VipBadge({
    super.key,
    this.fontSize = 10,
  });

  /// Font size for the badge text
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'VIP',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Mutual follow badge widget.
///
/// Displays a green badge indicating mutual follow status.
///
/// Source: Extracted from features/follow/presentation/widgets/following_card.dart
class MutualFollowBadge extends StatelessWidget {
  const MutualFollowBadge({
    super.key,
    this.fontSize = 10,
    this.label = '互关',
  });

  /// Font size for the badge text
  final double fontSize;

  /// Badge label text
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.green,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

/// Special attention badge widget.
///
/// Displays an orange badge indicating special attention status.
///
/// Source: Extracted from features/follow/presentation/widgets/following_card.dart
class SpecialAttentionBadge extends StatelessWidget {
  const SpecialAttentionBadge({
    super.key,
    this.fontSize = 10,
    this.label = '特别关注',
  });

  /// Font size for the badge text
  final double fontSize;

  /// Badge label text
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.orange,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

/// Generic badge widget with customizable colors.
///
/// Use this for custom badges not covered by specific badge widgets.
class GenericBadge extends StatelessWidget {
  const GenericBadge({
    required this.label,
    required this.color,
    super.key,
    this.fontSize = 10,
    this.backgroundOpacity = 0.2,
  });

  /// Badge label text
  final String label;

  /// Badge color (used for text and background)
  final Color color;

  /// Font size for the badge text
  final double fontSize;

  /// Background color opacity
  final double backgroundOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundOpacity),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

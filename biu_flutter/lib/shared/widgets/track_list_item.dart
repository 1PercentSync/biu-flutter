import 'package:flutter/material.dart';

import '../../core/extensions/duration_extensions.dart';
import '../theme/theme.dart';
import 'cached_image.dart';

/// A list item widget for displaying music/audio tracks.
///
/// Shows cover image, title, artist name, duration, and optional actions.
class TrackListItem extends StatelessWidget {
  const TrackListItem({
    required this.title,
    super.key,
    this.coverUrl,
    this.artistName,
    this.duration,
    this.playCount,
    this.isActive = false,
    this.isPlaying = false,
    this.onTap,
    this.onDoubleTap,
    this.onMorePressed,
  });

  /// Track title
  final String title;

  /// Cover image URL
  final String? coverUrl;

  /// Artist/owner name
  final String? artistName;

  /// Track duration in seconds
  final int? duration;

  /// Play count (optional)
  final int? playCount;

  /// Whether this track is currently active/selected
  final bool isActive;

  /// Whether this track is currently playing
  final bool isPlaying;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when double tapped
  final VoidCallback? onDoubleTap;

  /// Callback when more button is pressed
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: [
              // Cover image
              _buildCoverImage(),
              const SizedBox(width: 12),
              // Track info
              Expanded(
                child: _buildTrackInfo(context),
              ),
              // Duration and more button
              _buildTrailingSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AppCachedImage(
          imageUrl: coverUrl,
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        // Playing indicator overlay
        if (isActive && !isPlaying)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.pause,
              color: Colors.white,
              size: 20,
            ),
          ),
        if (isPlaying)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.graphic_eq,
              color: AppColors.primary,
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildTrackInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
        ),
        if (artistName != null) ...[
          const SizedBox(height: 4),
          // Artist name
          Text(
            artistName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrailingSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play count
        if (playCount != null && playCount! > 0) ...[
          Text(
            _formatPlayCount(playCount!),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(width: 16),
        ],
        // Duration
        if (duration != null) ...[
          Text(
            Duration(seconds: duration!).formatted,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
        // More button
        if (onMorePressed != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onMorePressed,
            icon: const Icon(
              Icons.more_vert,
              size: 20,
              color: AppColors.textTertiary,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ],
    );
  }

  String _formatPlayCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }
}

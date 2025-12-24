import 'package:flutter/material.dart';

import '../../core/extensions/duration_extensions.dart';
import '../../core/utils/number_utils.dart';
import '../theme/theme.dart';
import 'cached_image.dart';
import 'highlighted_text.dart';

/// A list item widget for displaying music/audio tracks.
///
/// Shows cover image, title, artist name, duration, and optional actions.
/// Supports highlighted titles (for search results) and clickable artist names.
///
/// Source: biu/src/components/music-list-item/index.tsx#MusicListItem
class TrackListItem extends StatelessWidget {
  const TrackListItem({
    required this.title,
    super.key,
    this.coverUrl,
    this.artistName,
    this.artistMid,
    this.duration,
    this.playCount,
    this.isActive = false,
    this.isPlaying = false,
    this.highlightTitle = false,
    this.onTap,
    this.onDoubleTap,
    this.onMorePressed,
    this.onArtistTap,
  });

  /// Track title (may contain HTML `<em>` tags if [highlightTitle] is true)
  final String title;

  /// Cover image URL
  final String? coverUrl;

  /// Artist/owner name
  final String? artistName;

  /// Artist/owner mid (user ID) for navigation
  ///
  /// Source: biu/src/components/music-list-item/index.tsx#ownerMid
  final int? artistMid;

  /// Track duration in seconds
  final int? duration;

  /// Play count (optional)
  final int? playCount;

  /// Whether this track is currently active/selected
  final bool isActive;

  /// Whether this track is currently playing
  final bool isPlaying;

  /// Whether title contains HTML highlight tags (from search results)
  ///
  /// Source: biu/src/components/music-list-item/index.tsx#isTitleIncludeHtmlTag
  final bool highlightTitle;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when double tapped
  final VoidCallback? onDoubleTap;

  /// Callback when more button is pressed
  final VoidCallback? onMorePressed;

  /// Callback when artist name is tapped
  ///
  /// If not provided but [artistMid] is set, tapping artist name has no effect.
  /// Typically used to navigate to user profile.
  final VoidCallback? onArtistTap;

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
    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isActive ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title - supports HTML highlight tags from search results
        // Source: biu/src/components/music-list-item/index.tsx#isTitleIncludeHtmlTag
        if (highlightTitle)
          HighlightedText(
            text: title,
            style: titleStyle,
            highlightStyle: titleStyle?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
          )
        else
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        if (artistName != null) ...[
          const SizedBox(height: 4),
          // Artist name - clickable when onArtistTap is provided
          // Source: biu/src/components/music-list-item/index.tsx#ownerMid
          _buildArtistName(context),
        ],
      ],
    );
  }

  Widget _buildArtistName(BuildContext context) {
    final artistWidget = Text(
      artistName ?? '未知',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            // Show underline hint when tappable
            decoration: onArtistTap != null ? TextDecoration.underline : null,
            decorationColor: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
    );

    if (onArtistTap != null) {
      return GestureDetector(
        onTap: onArtistTap,
        behavior: HitTestBehavior.opaque,
        child: artistWidget,
      );
    }

    return artistWidget;
  }

  Widget _buildTrailingSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play count
        // Source: biu/src/common/utils/number.ts#formatNumber
        if (playCount != null && playCount! > 0) ...[
          Text(
            NumberUtils.formatCompact(playCount),
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
}

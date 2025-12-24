import 'package:flutter/material.dart';

import '../../core/extensions/duration_extensions.dart';
import '../../core/utils/number_utils.dart';
import '../theme/theme.dart';
import 'cached_image.dart';
import 'highlighted_text.dart';

/// Action item for video card popup menu.
///
/// Used by [VideoCard] and [VideoListTile] for context menu actions.
class VideoCardAction {
  const VideoCardAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

/// A card widget for displaying video content.
///
/// Shows cover image, title, author, view count, duration, etc.
/// Mobile-adapted version with additional stats (danmaku count) and popup menu actions.
/// Supports highlighted titles (for search results) and clickable owner names.
///
/// Source: biu/src/components/mv-card/index.tsx#MVCard
/// Source: biu/src/components/image-card/index.tsx#ImageCard
class VideoCard extends StatelessWidget {
  const VideoCard({
    required this.title,
    super.key,
    this.coverUrl,
    this.ownerName,
    this.ownerMid,
    this.ownerAvatar,
    this.duration,
    this.viewCount,
    this.danmakuCount,
    this.pubDate,
    this.isActive = false,
    this.highlightTitle = false,
    this.onTap,
    this.onLongPress,
    this.onOwnerTap,
    this.actions,
  });

  /// Video title (may contain HTML `<em>` tags if [highlightTitle] is true)
  final String title;

  /// Cover image URL
  final String? coverUrl;

  /// Owner/author name
  final String? ownerName;

  /// Owner/author mid (user ID) for navigation
  ///
  /// Source: biu/src/components/mv-card/index.tsx (via MVAction ownerMid)
  final int? ownerMid;

  /// Owner avatar URL
  final String? ownerAvatar;

  /// Video duration in seconds
  final int? duration;

  /// View count
  final int? viewCount;

  /// Danmaku (bullet comments) count
  final int? danmakuCount;

  /// Publish date (timestamp in seconds)
  final int? pubDate;

  /// Whether this video is currently active/selected
  final bool isActive;

  /// Whether title contains HTML highlight tags (from search results)
  ///
  /// Source: biu/src/components/mv-card/index.tsx#isTitleIncludeHtmlTag
  final bool highlightTitle;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  /// Callback when owner name is tapped
  final VoidCallback? onOwnerTap;

  /// Actions to show in popup menu
  final List<VideoCardAction>? actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.contentBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: isActive
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image with duration overlay
              _buildCoverSection(context),
              // Info section
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildInfoSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          AppCachedImage(
            imageUrl: coverUrl,
            fileType: FileType.video,
          ),
          // Duration badge
          if (duration != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  Duration(seconds: duration!).formatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          // Actions menu button
          if (actions != null && actions!.isNotEmpty)
            Positioned(
              right: 4,
              top: 4,
              child: _buildActionsButton(context),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsButton(BuildContext context) {
    return PopupMenuButton<VideoCardAction>(
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.more_vert,
          color: Colors.white,
          size: 18,
        ),
      ),
      padding: EdgeInsets.zero,
      iconSize: 26,
      position: PopupMenuPosition.under,
      onSelected: (action) => action.onTap(),
      itemBuilder: (context) => actions!
          .map(
            (action) => PopupMenuItem<VideoCardAction>(
              value: action,
              child: Row(
                children: [
                  Icon(action.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(action.label),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.3,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title - supports HTML highlight tags from search results
        // Source: biu/src/components/mv-card/index.tsx#isTitleIncludeHtmlTag
        if (highlightTitle)
          HighlightedText(
            text: title,
            style: titleStyle,
            maxLines: 2,
          )
        else
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        const SizedBox(height: 8),
        // Owner and stats
        Row(
          children: [
            // Owner avatar (optional)
            if (ownerAvatar != null) ...[
              ClipOval(
                child: AppCachedImage(
                  imageUrl: ownerAvatar,
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 6),
            ],
            // Owner name - clickable when onOwnerTap is provided
            if (ownerName != null)
              Expanded(
                child: _buildOwnerName(context),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Stats row
        _buildStatsRow(context),
      ],
    );
  }

  Widget _buildOwnerName(BuildContext context) {
    final ownerWidget = Text(
      ownerName!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            decoration: onOwnerTap != null ? TextDecoration.underline : null,
            decorationColor: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
    );

    if (onOwnerTap != null) {
      return GestureDetector(
        onTap: onOwnerTap,
        behavior: HitTestBehavior.opaque,
        child: ownerWidget,
      );
    }

    return ownerWidget;
  }

  Widget _buildStatsRow(BuildContext context) {
    final statStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textTertiary,
        );

    return Row(
      children: [
        // View count
        if (viewCount != null) ...[
          const Icon(
            Icons.play_arrow,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 2),
          Text(
            NumberUtils.formatCompact(viewCount),
            style: statStyle,
          ),
          const SizedBox(width: 12),
        ],
        // Danmaku count
        if (danmakuCount != null) ...[
          const Icon(
            Icons.comment,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 2),
          Text(
            NumberUtils.formatCompact(danmakuCount),
            style: statStyle,
          ),
        ],
      ],
    );
  }

}

/// A list tile variant for video display.
///
/// Horizontal layout suitable for lists, showing video info in a row format.
/// Flutter-only: provides an alternative layout to VideoCard for list views.
/// Supports highlighted titles (for search results) and clickable owner names.
class VideoListTile extends StatelessWidget {
  const VideoListTile({
    required this.title,
    super.key,
    this.coverUrl,
    this.ownerName,
    this.ownerMid,
    this.ownerAvatar,
    this.duration,
    this.viewCount,
    this.danmakuCount,
    this.pubDate,
    this.isActive = false,
    this.highlightTitle = false,
    this.onTap,
    this.onLongPress,
    this.onOwnerTap,
    this.actions,
  });

  /// Video title (may contain HTML `<em>` tags if [highlightTitle] is true)
  final String title;

  /// Cover image URL
  final String? coverUrl;

  /// Owner/author name
  final String? ownerName;

  /// Owner/author mid (user ID) for navigation
  final int? ownerMid;

  /// Owner avatar URL
  final String? ownerAvatar;

  /// Video duration in seconds
  final int? duration;

  /// View count
  final int? viewCount;

  /// Danmaku (bullet comments) count
  final int? danmakuCount;

  /// Publish date (timestamp in seconds)
  final int? pubDate;

  /// Whether this video is currently active/selected
  final bool isActive;

  /// Whether title contains HTML highlight tags (from search results)
  final bool highlightTitle;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  /// Callback when owner name is tapped
  final VoidCallback? onOwnerTap;

  /// Actions to show in popup menu
  final List<VideoCardAction>? actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.contentBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: isActive
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image with duration
              _buildCover(context),
              const SizedBox(width: 12),
              // Info section
              Expanded(child: _buildInfo(context)),
              // Actions menu button
              if (actions != null && actions!.isNotEmpty)
                _buildActionsButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 68,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            child: AppCachedImage(
              imageUrl: coverUrl,
              fileType: FileType.video,
            ),
          ),
          // Duration badge
          if (duration != null)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  Duration(seconds: duration!).formatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsButton(BuildContext context) {
    return PopupMenuButton<VideoCardAction>(
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textTertiary,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      iconSize: 24,
      position: PopupMenuPosition.under,
      onSelected: (action) => action.onTap(),
      itemBuilder: (context) => actions!
          .map(
            (action) => PopupMenuItem<VideoCardAction>(
              value: action,
              child: Row(
                children: [
                  Icon(action.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(action.label),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.3,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title - supports HTML highlight tags from search results
        if (highlightTitle)
          HighlightedText(
            text: title,
            style: titleStyle,
            maxLines: 2,
          )
        else
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        const SizedBox(height: 6),
        // Owner - clickable when onOwnerTap is provided
        if (ownerName != null) _buildOwnerName(context),
        const SizedBox(height: 4),
        // Stats row
        _buildStatsRow(context),
      ],
    );
  }

  Widget _buildOwnerName(BuildContext context) {
    final ownerWidget = Text(
      ownerName!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            decoration: onOwnerTap != null ? TextDecoration.underline : null,
            decorationColor: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
    );

    if (onOwnerTap != null) {
      return GestureDetector(
        onTap: onOwnerTap,
        behavior: HitTestBehavior.opaque,
        child: ownerWidget,
      );
    }

    return ownerWidget;
  }

  Widget _buildStatsRow(BuildContext context) {
    final statStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textTertiary,
        );

    return Row(
      children: [
        // View count
        if (viewCount != null) ...[
          const Icon(
            Icons.play_arrow,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 2),
          Text(
            NumberUtils.formatCompact(viewCount),
            style: statStyle,
          ),
          const SizedBox(width: 12),
        ],
        // Danmaku count
        if (danmakuCount != null) ...[
          const Icon(
            Icons.comment,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 2),
          Text(
            NumberUtils.formatCompact(danmakuCount),
            style: statStyle,
          ),
        ],
      ],
    );
  }

}

import 'package:flutter/material.dart';

import '../../core/extensions/duration_extensions.dart';
import '../../core/utils/number_utils.dart';
import '../theme/theme.dart';
import 'cached_image.dart';
import 'highlighted_text.dart';

/// Action item for video card popup menu.
///
/// Used by [VideoCard] for context menu actions.
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
    this.aspectRatio = 16 / 9,
    this.footer,
    this.onTap,
    this.onLongPress,
    this.onOwnerTap,
    this.actions,
    this.actionWidget,
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

  /// Cover image aspect ratio (default: 16/9 for video, use 1.0 for square audio covers)
  ///
  /// Source: biu/src/components/mv-card/index.tsx#coverHeight (converted to aspectRatio)
  final double aspectRatio;

  /// Optional custom footer widget (replaces default stats row)
  ///
  /// Source: biu/src/components/mv-card/index.tsx#footer
  final Widget? footer;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  /// Callback when owner name is tapped
  final VoidCallback? onOwnerTap;

  /// Actions to show in popup menu on cover
  final List<VideoCardAction>? actions;

  /// Action widget displayed next to title (e.g., MediaActionMenu)
  ///
  /// Alternative to [actions] which shows popup menu on cover.
  /// Source: biu/src/components/mv-card/index.tsx#titleExtra
  final Widget? actionWidget;

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
              // Info section - use Expanded to prevent overflow
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _buildInfoSection(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title row with optional action widget
        // Source: biu/src/components/mv-card/index.tsx#titleExtra
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: highlightTitle
                    ? HighlightedText(
                        text: title,
                        style: titleStyle,
                        maxLines: 2,
                      )
                    : Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
              ),
              if (actionWidget != null) actionWidget!,
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Owner and stats
        Row(
          children: [
            // Owner avatar (optional)
            if (ownerAvatar != null) ...[
              ClipOval(
                child: AppCachedImage(
                  imageUrl: ownerAvatar,
                  width: 18,
                  height: 18,
                ),
              ),
              const SizedBox(width: 4),
            ],
            // Owner name - clickable when onOwnerTap is provided
            if (ownerName != null)
              Expanded(
                child: _buildOwnerName(context),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Stats row or custom footer
        if (footer != null)
          footer!
        else
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

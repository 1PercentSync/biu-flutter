import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'cached_image.dart';
import 'highlighted_text.dart';

/// A card widget for displaying video/song content (iOS-style).
///
/// Shows cover image, title, and author in a minimal design.
/// - No background container
/// - Cover with configurable aspect ratio and border radius
/// - Title: 13px, weight 500
/// - Author: 12px, 60% opacity
/// - Action widget aligned right
///
/// Source: prototype/home_tabs_prototype.html (song-card)
class VideoCard extends StatelessWidget {
  const VideoCard({
    required this.title,
    super.key,
    this.coverUrl,
    this.ownerName,
    this.isActive = false,
    this.highlightTitle = false,
    this.aspectRatio = 1.0,
    this.onTap,
    this.onLongPress,
    this.onOwnerTap,
    this.actionWidget,
  });

  /// Video/song title
  final String title;

  /// Cover image URL
  final String? coverUrl;

  /// Owner/author name
  final String? ownerName;

  /// Whether this item is currently active/selected
  final bool isActive;

  /// Whether title contains HTML highlight tags (from search results)
  final bool highlightTitle;

  /// Cover image aspect ratio (default: 1.0 for square)
  final double aspectRatio;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  /// Callback when owner name is tapped
  final VoidCallback? onOwnerTap;

  /// Action widget displayed next to title (e.g., MediaActionMenu)
  final Widget? actionWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          AspectRatio(
            aspectRatio: aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: AppCachedImage(
                imageUrl: coverUrl,
                fileType: FileType.video,
              ),
            ),
          ),
          // Info section - minimal padding
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title - 13px, weight 500
                      if (highlightTitle)
                        HighlightedText(
                          text: title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          maxLines: 1,
                        )
                      else
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      // Owner - 12px, 60% opacity
                      if (ownerName != null)
                        GestureDetector(
                          onTap: onOwnerTap,
                          child: Text(
                            ownerName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                              height: 1.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Action widget
                if (actionWidget != null) actionWidget!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'cached_image.dart';
import 'highlighted_text.dart';

/// A list item widget for displaying music/audio tracks (iOS-style).
///
/// Shows cover image, title, and artist in a minimal design.
/// - 48x48 cover
/// - Gap 10px
/// - Title: 15px
/// - Artist: 13px, 60% opacity
/// - Bottom divider (0.5px, 8% opacity)
///
/// Source: prototype/home_tabs_prototype.html (song-list-item)
class TrackListItem extends StatelessWidget {
  const TrackListItem({
    required this.title,
    super.key,
    this.coverUrl,
    this.artistName,
    this.isActive = false,
    this.highlightTitle = false,
    this.showDivider = true,
    this.onTap,
    this.onArtistTap,
    this.trailingAction,
  });

  /// Track title
  final String title;

  /// Cover image URL
  final String? coverUrl;

  /// Artist/owner name
  final String? artistName;

  /// Whether this track is currently active/selected
  final bool isActive;

  /// Whether title contains HTML highlight tags (from search results)
  final bool highlightTitle;

  /// Show bottom divider
  final bool showDivider;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when artist name is tapped
  final VoidCallback? onArtistTap;

  /// Custom trailing action widget (e.g., MediaActionMenu)
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Cover image (48x48)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            child: AppCachedImage(
              imageUrl: coverUrl,
              width: 48,
              height: 48,
            ),
          ),
          const SizedBox(width: 10),
          // Content with divider
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: showDivider
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                          width: 0.5,
                        ),
                      ),
                    )
                  : null,
              child: Row(
                children: [
                  // Text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title - 15px
                        if (highlightTitle)
                          HighlightedText(
                            text: title,
                            style: TextStyle(
                              fontSize: 15,
                              color: isActive ? AppColors.primary : Colors.white,
                            ),
                            maxLines: 1,
                          )
                        else
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              color: isActive ? AppColors.primary : Colors.white,
                            ),
                          ),
                        const SizedBox(height: 1),
                        // Artist - 13px, 60% opacity
                        if (artistName != null)
                          GestureDetector(
                            onTap: onArtistTap,
                            child: Text(
                              artistName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Trailing action
                  if (trailingAction != null) trailingAction!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/app_settings.dart';
import 'track_list_item.dart';
import 'video_card.dart';

/// Unified media item widget that adapts to display mode.
///
/// Switches between card and list display based on [displayMode].
/// Provides a single interface for rendering media content consistently
/// across features.
///
/// For action menus, pass a [MediaActionMenu] widget as [actionWidget].
/// It will be rendered appropriately for each display mode.
///
/// Source: biu/src/components/media-item/index.tsx
class MediaItem extends StatelessWidget {
  const MediaItem({
    required this.displayMode,
    required this.title,
    super.key,
    // Content props
    this.coverUrl,
    this.ownerName,
    this.ownerMid,
    this.ownerAvatar,
    this.duration,
    this.playCount,
    this.viewCount,
    this.danmakuCount,
    this.pubDate,
    this.isActive = false,
    this.isPlaying = false,
    this.highlightTitle = false,
    this.aspectRatio = 16 / 9,
    this.footer,
    // Actions
    this.actionWidget,
    this.cardActions,
    // Callbacks
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onOwnerTap,
  });

  // ── Display props ─────────────────────────────────────────────

  /// Display mode: card or list
  final DisplayMode displayMode;

  /// Cover image aspect ratio (default: 16/9 for video, use 1.0 for square audio)
  final double aspectRatio;

  /// Custom footer widget for card mode (replaces default stats row)
  final Widget? footer;

  // ── Content props ─────────────────────────────────────────────

  /// Media title
  final String title;

  /// Cover image URL
  final String? coverUrl;

  /// Owner/author name
  final String? ownerName;

  /// Owner/author mid (user ID)
  final int? ownerMid;

  /// Owner avatar URL
  final String? ownerAvatar;

  /// Duration in seconds
  final int? duration;

  /// Play count (for audio)
  final int? playCount;

  /// View count (for video)
  final int? viewCount;

  /// Danmaku (bullet comments) count
  final int? danmakuCount;

  /// Publish date (timestamp in seconds)
  final int? pubDate;

  /// Whether this item is currently active/selected
  final bool isActive;

  /// Whether this item is currently playing (for list mode audio visualization)
  final bool isPlaying;

  /// Whether title contains HTML highlight tags (from search results)
  final bool highlightTitle;

  // ── Actions ───────────────────────────────────────────────────

  /// Action widget (e.g., MediaActionMenu)
  ///
  /// Renders as:
  /// - List mode: Trailing action in [TrackListItem.trailingAction]
  ///   Source: biu/src/components/music-list-item/index.tsx renders `<MVAction />`
  /// - Card mode: Next to title in [VideoCard.actionWidget]
  ///   Source: biu/src/components/image-card/index.tsx uses `titleExtra` prop
  final Widget? actionWidget;

  /// Actions for card mode popup menu (displayed on cover)
  ///
  /// Alternative to [actionWidget] for card mode.
  final List<VideoCardAction>? cardActions;

  // ── Callbacks ─────────────────────────────────────────────────

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when double tapped (for list mode)
  final VoidCallback? onDoubleTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  /// Callback when owner name is tapped
  final VoidCallback? onOwnerTap;

  @override
  Widget build(BuildContext context) {
    if (displayMode == DisplayMode.list) {
      return _buildListItem(context);
    }
    return _buildCardItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    return TrackListItem(
      title: title,
      coverUrl: coverUrl,
      artistName: ownerName,
      artistMid: ownerMid,
      duration: duration,
      playCount: playCount ?? viewCount,
      isActive: isActive,
      isPlaying: isPlaying,
      highlightTitle: highlightTitle,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onArtistTap: onOwnerTap,
      trailingAction: actionWidget,
    );
  }

  Widget _buildCardItem(BuildContext context) {
    return VideoCard(
      title: title,
      coverUrl: coverUrl,
      ownerName: ownerName,
      ownerMid: ownerMid,
      ownerAvatar: ownerAvatar,
      duration: duration,
      viewCount: viewCount ?? playCount,
      danmakuCount: danmakuCount,
      pubDate: pubDate,
      isActive: isActive,
      highlightTitle: highlightTitle,
      aspectRatio: aspectRatio,
      footer: footer,
      onTap: onTap,
      onLongPress: onLongPress,
      onOwnerTap: onOwnerTap,
      actions: cardActions,
      actionWidget: actionWidget,
    );
  }
}

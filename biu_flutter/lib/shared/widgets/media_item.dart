import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/app_settings.dart';
import 'track_list_item.dart';
import 'video_card.dart';

/// Unified media item widget that adapts to display mode.
///
/// Switches between card and list display based on [displayMode].
/// Uses iOS-style minimal design matching prototype.
///
/// Source: prototype/home_tabs_prototype.html
/// Source: biu/src/components/media-item/index.tsx
class MediaItem extends StatelessWidget {
  const MediaItem({
    required this.displayMode,
    required this.title,
    super.key,
    this.coverUrl,
    this.ownerName,
    this.isActive = false,
    this.highlightTitle = false,
    this.aspectRatio = 1.0,
    this.showDivider = true,
    this.actionWidget,
    this.onTap,
    this.onLongPress,
    this.onOwnerTap,
  });

  /// Display mode: card or list
  final DisplayMode displayMode;

  /// Media title
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

  /// Show bottom divider in list mode
  final bool showDivider;

  /// Action widget (e.g., MediaActionMenu)
  final Widget? actionWidget;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  /// Callback when owner name is tapped
  final VoidCallback? onOwnerTap;

  @override
  Widget build(BuildContext context) {
    if (displayMode == DisplayMode.list) {
      return _buildListItem();
    }
    return _buildCardItem();
  }

  Widget _buildListItem() {
    return TrackListItem(
      title: title,
      coverUrl: coverUrl,
      artistName: ownerName,
      isActive: isActive,
      highlightTitle: highlightTitle,
      showDivider: showDivider,
      onTap: onTap,
      onArtistTap: onOwnerTap,
      trailingAction: actionWidget,
    );
  }

  Widget _buildCardItem() {
    return VideoCard(
      title: title,
      coverUrl: coverUrl,
      ownerName: ownerName,
      isActive: isActive,
      highlightTitle: highlightTitle,
      aspectRatio: aspectRatio,
      onTap: onTap,
      onLongPress: onLongPress,
      onOwnerTap: onOwnerTap,
      actionWidget: actionWidget,
    );
  }
}

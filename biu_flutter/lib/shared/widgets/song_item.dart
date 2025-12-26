import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/app_settings.dart';
import 'media_action_menu.dart';
import 'media_item.dart';

/// Unified song item widget for music display (iOS-style).
///
/// Wraps MediaItem with song-specific defaults (1:1 aspect ratio).
/// Used for HotSong, RecommendedSong, and similar music data.
///
/// Source: prototype/home_tabs_prototype.html
/// Source: biu/src/pages/music-rank/index.tsx
class SongItem extends StatelessWidget {
  const SongItem({
    required this.displayMode,
    required this.title,
    required this.author,
    required this.bvid,
    super.key,
    this.aid,
    this.cid,
    this.cover,
    this.onTap,
    this.onLongPress,
  });

  /// Display mode: card or list
  final DisplayMode displayMode;

  /// Song title
  final String title;

  /// Author/artist name
  final String author;

  /// Video bvid
  final String bvid;

  /// Video aid (optional)
  final String? aid;

  /// Video cid (optional)
  final String? cid;

  /// Cover image URL
  final String? cover;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return MediaItem(
      displayMode: displayMode,
      title: title,
      coverUrl: cover,
      ownerName: author,
      aspectRatio: 1.0,
      actionWidget: _buildActionMenu(),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _buildActionMenu() {
    return MediaActionMenu(
      title: title,
      bvid: bvid,
      aid: aid,
      cid: cid,
      cover: cover,
      ownerName: author,
      iconSize: displayMode == DisplayMode.card ? 18 : 20,
    );
  }
}

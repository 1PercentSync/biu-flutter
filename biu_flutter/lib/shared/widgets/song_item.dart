import 'package:flutter/material.dart';

import '../../core/utils/number_utils.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../theme/theme.dart';
import 'media_action_menu.dart';
import 'media_item.dart';

/// Unified song item widget for music display.
///
/// Wraps MediaItem with song-specific defaults (1:1 aspect ratio, play count badge).
/// Used for HotSong, RecommendedSong, and similar music data.
///
/// Source: biu/src/components/media-item/index.tsx (music mode)
/// Source: biu/src/pages/music-rank/index.tsx
/// Source: biu/src/pages/music-recommend/index.tsx
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
    this.playCount,
    this.isActive = false,
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

  /// Play count
  final int? playCount;

  /// Whether this song is currently playing/selected
  final bool isActive;

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
      playCount: playCount,
      isActive: isActive,
      aspectRatio: 1, // Square cover for music
      footer: displayMode == DisplayMode.card ? _buildCardFooter(context) : null,
      actionWidget: _buildActionMenu(),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  /// Card mode footer with play count badge style
  /// Source: biu/src/components/mv-card/index.tsx (music variant)
  Widget _buildCardFooter(BuildContext context) {
    return Row(
      children: [
        // Play count with icon
        if (playCount != null && playCount! > 0) ...[
          const Icon(
            Icons.play_arrow,
            size: 14,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 2),
          Text(
            NumberUtils.formatCompact(playCount),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ],
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

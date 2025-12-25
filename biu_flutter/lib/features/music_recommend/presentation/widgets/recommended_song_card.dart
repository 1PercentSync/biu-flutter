import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../data/models/recommended_song.dart';

/// A card widget for displaying recommended song.
/// Source: biu/src/pages/music-recommend/index.tsx (MediaItem component)
class RecommendedSongCard extends StatelessWidget {
  const RecommendedSongCard({
    required this.song,
    super.key,
    this.isActive = false,
    this.onTap,
    this.onLongPress,
  });

  /// The recommended song data
  final RecommendedSong song;

  /// Whether this song is currently playing
  final bool isActive;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cover image
              _buildCoverSection(),
              // Info section
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildInfoSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection() {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          AppCachedImage(
            imageUrl: song.cover,
          ),
          // Play count badge (bottom left like source)
          Positioned(
            left: 8,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_arrow,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    song.playCountFormatted,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title with action menu
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                song.musicTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
              ),
            ),
            MediaActionMenu(
              title: song.musicTitle,
              bvid: song.bvid,
              aid: song.aid,
              cover: song.cover,
              ownerName: song.author,
              iconSize: 18,
            ),
          ],
        ),
        const SizedBox(height: 2),
        // Author
        Text(
          song.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

/// A list tile variant for recommended song display.
class RecommendedSongListTile extends StatelessWidget {
  const RecommendedSongListTile({
    required this.song,
    super.key,
    this.isActive = false,
    this.onTap,
    this.onLongPress,
  });

  /// The recommended song data
  final RecommendedSong song;

  /// Whether this song is currently playing
  final bool isActive;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            border: const Border(
              bottom: BorderSide(
                color: AppColors.divider,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Cover image
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusSmall),
                child: AppCachedImage(
                  imageUrl: song.cover,
                  width: 48,
                  height: 48,
                ),
              ),
              const SizedBox(width: 12),
              // Song info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.musicTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Play count
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  song.playCountFormatted,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ),
              // Action menu
              MediaActionMenu(
                title: song.musicTitle,
                bvid: song.bvid,
                aid: song.aid,
                cover: song.cover,
                ownerName: song.author,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

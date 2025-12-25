import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/hot_song.dart';

/// A card widget for displaying hot song from music rank.
class HotSongCard extends StatelessWidget {
  const HotSongCard({
    required this.song,
    super.key,
    this.rank,
    this.isActive = false,
    this.onTap,
    this.onLongPress,
  });

  /// The hot song data
  final HotSong song;

  /// Rank number (1-based)
  final int? rank;

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
            children: [
              // Cover image with rank badge
              _buildCoverSection(),
              // Info section - use Expanded to take remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildInfoSection(context),
                ),
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
          // Rank badge
          if (rank != null)
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getRankColor(rank!),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          // Play count badge
          if (song.totalVv != null)
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
      children: [
        // Title
        Text(
          song.musicTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
        ),
        const SizedBox(height: 4),
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

  /// Get rank badge color based on position
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFF6B6B); // Red/gold for #1
      case 2:
        return const Color(0xFFFF9F43); // Orange for #2
      case 3:
        return const Color(0xFFFFD93D); // Yellow for #3
      default:
        return Colors.black.withValues(alpha: 0.6);
    }
  }
}

/// A list tile variant for hot song display.
class HotSongListTile extends StatelessWidget {
  const HotSongListTile({
    required this.song,
    super.key,
    this.rank,
    this.isActive = false,
    this.onTap,
    this.onLongPress,
  });

  /// The hot song data
  final HotSong song;

  /// Rank number (1-based)
  final int? rank;

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
              // Rank number
              if (rank != null)
                SizedBox(
                  width: 32,
                  child: Text(
                    rank.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: rank! <= 3
                          ? _getRankColor(rank!)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
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
              if (song.totalVv != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        song.playCountFormatted,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFF6B6B);
      case 2:
        return const Color(0xFFFF9F43);
      case 3:
        return const Color(0xFFFFD93D);
      default:
        return AppColors.textSecondary;
    }
  }
}

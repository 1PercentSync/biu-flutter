import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/player/presentation/providers/playlist_notifier.dart';
import '../../../features/player/presentation/providers/playlist_state.dart';
import '../../theme/theme.dart';
import '../cached_image.dart';

/// Mini playbar widget that shows at the bottom of the screen.
///
/// Displays current track info, progress, and basic controls.
class MiniPlaybar extends ConsumerWidget {
  const MiniPlaybar({
    super.key,
    this.onTap,
  });

  /// Callback when the playbar is tapped (to expand to full player)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistState = ref.watch(playlistProvider);
    final currentItem = playlistState.currentItem;

    // Don't show if no current track
    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppTheme.miniPlaybarHeight,
        decoration: const BoxDecoration(
          color: AppColors.contentBackground,
          border: Border(
            top: BorderSide(
              color: AppColors.divider,
            ),
          ),
        ),
        child: Column(
          children: [
            // Progress bar at top
            _buildProgressBar(playlistState),
            // Playbar content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Cover image
                    _buildCoverImage(currentItem.displayCover),
                    const SizedBox(width: 12),
                    // Track info
                    Expanded(
                      child: _buildTrackInfo(
                        context,
                        currentItem.displayTitle,
                        currentItem.ownerName,
                      ),
                    ),
                    // Controls
                    _buildControls(ref, playlistState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(PlaylistState playlistState) {
    final duration = playlistState.duration ?? 0.0;
    final currentTime = playlistState.currentTime;
    final progress = duration > 0 ? (currentTime / duration).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      height: 2,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppColors.progressBackground,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildCoverImage(String? coverUrl) {
    return AppCachedImage(
      imageUrl: coverUrl,
      width: 44,
      height: 44,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
    );
  }

  Widget _buildTrackInfo(BuildContext context, String title, String? artist) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (artist != null) ...[
          const SizedBox(height: 2),
          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildControls(WidgetRef ref, PlaylistState playlistState) {
    final notifier = ref.read(playlistProvider.notifier);
    final isPlaying = playlistState.isPlaying;
    final isLoading = playlistState.isLoading;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause button
        IconButton(
          onPressed: isLoading ? null : notifier.togglePlay,
          icon: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.textPrimary,
                ),
        ),
        // Next button
        IconButton(
          onPressed: playlistState.length > 1 ? notifier.next : null,
          icon: Icon(
            Icons.skip_next,
            color: playlistState.length > 1
                ? AppColors.textPrimary
                : AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

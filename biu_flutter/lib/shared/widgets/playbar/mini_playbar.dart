import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/player/presentation/providers/playlist_notifier.dart';
import '../../../features/player/presentation/providers/playlist_state.dart';
import '../../../features/settings/presentation/providers/settings_notifier.dart';
import '../../theme/theme.dart';
import '../cached_image.dart';
import '../glass/glass_styles.dart';

/// iOS-style floating mini playbar with frosted glass effect.
///
/// Displays current track info and basic controls in a floating container
/// with backdrop blur. Designed to be positioned above bottom navigation
/// in a Stack layout.
///
/// Source: biu/src/layout/playbar/left/index.tsx#Left
/// Source: prototype/home_tabs_prototype.html (iOS-native design)
///
/// NOTE: This widget imports from features/player/ which is technically
/// a cross-layer dependency (shared -> features). This is accepted because:
/// 1. Source project has same pattern: layout/playbar/ imports from store/play-list.ts
/// 2. Player state is a cross-cutting concern used by many features
/// 3. Playbar widgets are inherently player-dependent by design
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

    final settings = ref.watch(settingsNotifierProvider);
    final primaryColor = settings.primaryColor;
    final backgroundColor = settings.backgroundColor;
    final coverRadius = settings.borderRadius;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.miniPlayerRadius),
        child: BackdropFilter(
          filter: GlassStyles.blurFilterStrong,
          child: Container(
            height: AppTheme.miniPlayerHeight,
            decoration: BoxDecoration(
              color: GlassStyles.glassBackgroundElevated(backgroundColor),
              borderRadius: BorderRadius.circular(AppTheme.miniPlayerRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingSmall,
            ),
            child: Row(
              children: [
                // Cover image
                _buildCoverImage(currentItem.displayCover, coverRadius),
                const SizedBox(width: 10),
                // Track info (title only in compact mode)
                Expanded(
                  child: _buildTrackInfo(context, currentItem.displayTitle),
                ),
                // Controls
                _buildControls(ref, playlistState, primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? coverUrl, double borderRadius) {
    return AppCachedImage(
      imageUrl: coverUrl,
      width: AppTheme.miniPlayerCoverSize,
      height: AppTheme.miniPlayerCoverSize,
      borderRadius: BorderRadius.circular(borderRadius.clamp(0, 8)),
    );
  }

  Widget _buildTrackInfo(BuildContext context, String title) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  Widget _buildControls(
    WidgetRef ref,
    PlaylistState playlistState,
    Color primaryColor,
  ) {
    final notifier = ref.read(playlistProvider.notifier);
    final isPlaying = playlistState.isPlaying;
    final isLoading = playlistState.isLoading;
    final canSkip = playlistState.length > 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        _buildControlButton(
          icon: Icons.skip_previous,
          onPressed: canSkip ? notifier.prev : null,
          enabled: canSkip,
        ),
        // Play/Pause button
        _buildPlayPauseButton(
          isPlaying: isPlaying,
          isLoading: isLoading,
          primaryColor: primaryColor,
          onPressed: isLoading ? null : notifier.togglePlay,
        ),
        // Next button
        _buildControlButton(
          icon: Icons.skip_next,
          onPressed: canSkip ? notifier.next : null,
          enabled: canSkip,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 28,
          color: enabled ? Colors.white : Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton({
    required bool isPlaying,
    required bool isLoading,
    required Color primaryColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onPressed,
        icon: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryColor,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 28,
                color: Colors.white,
              ),
      ),
    );
  }
}

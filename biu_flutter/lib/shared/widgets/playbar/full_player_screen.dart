import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/audio.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../features/player/domain/entities/play_item.dart';
import '../../../features/player/presentation/providers/playlist_notifier.dart';
import '../../../features/player/presentation/providers/playlist_state.dart';
import '../../theme/theme.dart';
import '../audio_visualizer.dart';
import '../cached_image.dart';

/// Full-screen player widget.
///
/// Shows large cover image, detailed controls, progress slider, and playlist.
/// Source: biu/src/layout/playbar/center/index.tsx#Center
/// Source: biu/src/layout/playbar/right/index.tsx#Right
/// Source: biu/src/layout/playbar/right/play-list-drawer/* (playlist sheet)
class FullPlayerScreen extends ConsumerStatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen> {
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistProvider);
    final currentItem = playlistState.currentItem;

    if (currentItem == null) {
      return const Scaffold(
        body: Center(
          child: Text('No track playing'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, currentItem),
      body: SafeArea(
        child: Column(
          children: [
            // Cover image section with visualizer
            Expanded(
              flex: 3,
              child: _buildCoverSection(currentItem, playlistState.isPlaying),
            ),
            // Track info and controls
            Expanded(
              flex: 2,
              child: _buildControlsSection(context, playlistState, currentItem),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, PlayItem currentItem) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        children: [
          Text(
            'Now Playing',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            currentItem.ownerName ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.playlist_play),
          onPressed: () => _showPlaylistSheet(context),
        ),
      ],
    );
  }

  Widget _buildCoverSection(PlayItem currentItem, bool isPlaying) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cover image
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AppCachedImage(
                    imageUrl: currentItem.displayCover,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Audio visualizer
            // Note: Simulated animation since just_audio doesn't support FFT data
            SizedBox(
              height: 40,
              child: AudioVisualizer(
                isPlaying: isPlaying,
                barCount: 48,
                maxHeight: 0.9,
                primaryColor: AppColors.primary,
                secondaryColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsSection(
    BuildContext context,
    PlaylistState playlistState,
    PlayItem currentItem,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Track info
          _buildTrackInfo(context, currentItem),
          const SizedBox(height: 24),
          // Progress slider
          _buildProgressSlider(playlistState),
          const SizedBox(height: 24),
          // Main controls
          _buildMainControls(playlistState),
          const SizedBox(height: 16),
          // Secondary controls
          _buildSecondaryControls(playlistState),
        ],
      ),
    );
  }

  Widget _buildTrackInfo(BuildContext context, PlayItem currentItem) {
    return Column(
      children: [
        // Title
        Text(
          currentItem.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Artist
        Text(
          currentItem.ownerName ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        // Quality badges
        if (currentItem.isLossless == true || currentItem.isDolby == true) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentItem.isLossless == true)
                _buildBadge('Lossless'),
              if (currentItem.isDolby == true) ...[
                const SizedBox(width: 8),
                _buildBadge('Dolby'),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressSlider(PlaylistState playlistState) {
    final notifier = ref.read(playlistProvider.notifier);
    final duration = playlistState.duration ?? 0.0;
    final currentTime = _isDragging ? _dragValue : playlistState.currentTime;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.progressBackground,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: currentTime.clamp(0.0, duration > 0 ? duration : 1.0),
            max: duration > 0 ? duration : 1.0,
            onChangeStart: (value) {
              setState(() {
                _isDragging = true;
                _dragValue = value;
              });
            },
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
            },
            onChangeEnd: (value) {
              notifier.seek(value);
              setState(() {
                _isDragging = false;
              });
            },
          ),
        ),
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Duration(seconds: currentTime.round()).formatted,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              Text(
                Duration(seconds: duration.round()).formatted,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainControls(PlaylistState playlistState) {
    final notifier = ref.read(playlistProvider.notifier);
    final isPlaying = playlistState.isPlaying;
    final isLoading = playlistState.isLoading;
    final canSkip = playlistState.length > 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          onPressed: canSkip ? notifier.prev : null,
          icon: Icon(
            Icons.skip_previous,
            size: 32,
            color: canSkip ? AppColors.textPrimary : AppColors.textDisabled,
          ),
        ),
        const SizedBox(width: 24),
        // Play/Pause button
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: isLoading ? null : notifier.togglePlay,
            icon: isLoading
                ? const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
          ),
        ),
        const SizedBox(width: 24),
        // Next button
        IconButton(
          onPressed: canSkip ? notifier.next : null,
          icon: Icon(
            Icons.skip_next,
            size: 32,
            color: canSkip ? AppColors.textPrimary : AppColors.textDisabled,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryControls(PlaylistState playlistState) {
    final notifier = ref.read(playlistProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Play mode button
        IconButton(
          onPressed: notifier.togglePlayMode,
          icon: Icon(
            _getPlayModeIcon(playlistState.playMode),
            color: AppColors.textSecondary,
          ),
          tooltip: _getPlayModeTooltip(playlistState.playMode),
        ),
        // Mute button
        IconButton(
          onPressed: notifier.toggleMute,
          icon: Icon(
            playlistState.isMuted ? Icons.volume_off : Icons.volume_up,
            color: AppColors.textSecondary,
          ),
        ),
        // Rate button
        TextButton(
          onPressed: _showRateDialog,
          child: Text(
            '${playlistState.rate}x',
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPlayModeIcon(PlayMode mode) {
    switch (mode) {
      case PlayMode.sequence:
        return Icons.playlist_play;
      case PlayMode.loop:
        return Icons.repeat;
      case PlayMode.single:
        return Icons.repeat_one;
      case PlayMode.random:
        return Icons.shuffle;
    }
  }

  String _getPlayModeTooltip(PlayMode mode) {
    switch (mode) {
      case PlayMode.sequence:
        return 'Sequential';
      case PlayMode.loop:
        return 'Loop All';
      case PlayMode.single:
        return 'Repeat One';
      case PlayMode.random:
        return 'Shuffle';
    }
  }

  void _showRateDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _RateDialog(),
    );
  }

  void _showPlaylistSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _PlaylistSheet(),
    );
  }
}

/// Dialog for selecting playback rate
class _RateDialog extends ConsumerWidget {
  static const List<double> rates = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRate = ref.watch(playlistProvider).rate;
    final notifier = ref.read(playlistProvider.notifier);

    return AlertDialog(
      title: const Text('Playback Speed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: rates.map((rate) {
          return ListTile(
            title: Text('${rate}x'),
            trailing: rate == currentRate
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              notifier.setRate(rate);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }
}

/// Bottom sheet showing current playlist
class _PlaylistSheet extends ConsumerWidget {
  const _PlaylistSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistState = ref.watch(playlistProvider);
    final notifier = ref.read(playlistProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Playlist (${playlistState.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      notifier.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            // Playlist
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: playlistState.length,
                itemBuilder: (context, index) {
                  final item = playlistState.list[index];
                  final isActive = item.id == playlistState.playId;

                  return ListTile(
                    leading: AppCachedImage(
                      imageUrl: item.displayCover,
                      width: 48,
                      height: 48,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    title: Text(
                      item.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? AppColors.primary : null,
                      ),
                    ),
                    subtitle: Text(
                      item.ownerName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => notifier.delPage(item.id),
                    ),
                    onTap: () => notifier.playListItem(item.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/audio.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../features/favorites/presentation/widgets/folder_select_sheet.dart';
import '../../../features/player/domain/entities/play_item.dart';
import '../../../features/player/presentation/providers/playlist_notifier.dart';
import '../../../features/player/presentation/providers/playlist_state.dart';
import '../../theme/theme.dart';
import '../cached_image.dart';

/// Full-screen player widget.
///
/// Shows large cover image, detailed controls, progress slider, and playlist.
/// Source: biu/src/layout/playbar/center/index.tsx#Center
/// Source: biu/src/layout/playbar/right/index.tsx#Right
/// Source: biu/src/layout/playbar/right/play-list-drawer/* (playlist sheet)
///
/// NOTE: This widget imports from features/player/ and features/favorites/
/// which is technically a cross-layer dependency (shared -> features).
/// This is accepted because:
/// 1. Source project has same pattern: layout/playbar/ imports from store/play-list.ts
/// 2. Player state is a cross-cutting concern used by many features
/// 3. Playbar widgets are inherently player-dependent by design
/// 4. The favorites import is for FolderSelectSheet, which provides quick-add
///    functionality matching biu/src/layout/playbar/right/mv-fav-folder-select.tsx
/// See: openspec/changes/align-parity-report-decisions/tasks.md (Phase 5.2)
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
          child: Text('暂无播放'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, currentItem),
      body: SafeArea(
        child: Column(
          children: [
            // Cover image section
            Expanded(
              flex: 3,
              child: _buildCoverSection(currentItem),
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
    final playlistState = ref.watch(playlistProvider);
    final hasMultiPart = currentItem.hasMultiPart && (currentItem.totalPage ?? 0) > 1;

    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.chevron_down),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // Open in browser button
        // Source: biu/src/layout/playbar/left/index.tsx - click title opens browser
        IconButton(
          icon: const Icon(CupertinoIcons.globe),
          onPressed: () => _openInBrowser(currentItem),
          tooltip: '在浏览器中打开',
        ),
        // Video page list button (for multi-part videos)
        // Source: biu/src/layout/playbar/left/video-page-list/index.tsx
        if (hasMultiPart)
          IconButton(
            icon: const Icon(CupertinoIcons.list_bullet),
            onPressed: () => _showVideoPageListSheet(context, currentItem, playlistState),
            tooltip: '分P ${currentItem.pageIndex ?? 1}/${currentItem.totalPage ?? 1}',
          ),
        // Quick favorite button
        // Source: biu/src/layout/playbar/right/mv-fav-folder-select.tsx
        IconButton(
          icon: const Icon(CupertinoIcons.star),
          onPressed: () => _showFavoriteSheet(context, currentItem),
          tooltip: '添加到收藏夹',
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.list_bullet),
          onPressed: () => _showPlaylistSheet(context),
        ),
      ],
    );
  }

  /// Open the current item in browser
  /// Source: biu/src/common/utils/url.ts#openBiliVideoLink
  Future<void> _openInBrowser(PlayItem item) async {
    String url;
    if (item.type == PlayDataType.mv) {
      final pageParam = (item.pageIndex ?? 0) > 1 ? '?p=${item.pageIndex}' : '';
      url = 'https://www.bilibili.com/video/${item.bvid}$pageParam';
    } else {
      url = 'https://www.bilibili.com/audio/au${item.sid}';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Show video page list sheet for multi-part videos
  /// Source: biu/src/layout/playbar/left/video-page-list/index.tsx
  void _showVideoPageListSheet(
    BuildContext context,
    PlayItem currentItem,
    PlaylistState playlistState,
  ) {
    // Get all pages with same bvid from playlist
    final pages = playlistState.list
        .where((item) => item.bvid == currentItem.bvid)
        .toList()
      ..sort((a, b) => (a.pageIndex ?? 0).compareTo(b.pageIndex ?? 0));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.contentBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _VideoPageListSheet(
        pages: pages,
        currentPlayId: playlistState.playId,
        onPageTap: (pageItem) {
          ref.read(playlistProvider.notifier).playListItem(pageItem.id);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Show folder select sheet for quick favorite
  /// Source: biu/src/layout/playbar/right/mv-fav-folder-select.tsx
  void _showFavoriteSheet(BuildContext context, PlayItem currentItem) {
    // Get resource ID based on type
    String resourceId;
    if (currentItem.type == PlayDataType.mv) {
      resourceId = currentItem.aid ?? '';
    } else {
      final sid = currentItem.sid;
      resourceId = sid?.toString() ?? '';
    }

    if (resourceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法添加到收藏')),
      );
      return;
    }

    FolderSelectSheet.show(
      context: context,
      resourceId: resourceId,
      title: '添加到收藏夹',
    );
  }

  Widget _buildCoverSection(PlayItem currentItem) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate max size: fill one axis while maintaining 1:1 ratio
            // with a maximum limit of 400px
            const maxSize = 400.0;
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;
            final size = [availableWidth, availableHeight, maxSize].reduce(
              (a, b) => a < b ? a : b,
            );

            return Container(
              width: size,
              height: size,
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
            );
          },
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Track info
            _buildTrackInfo(context, currentItem),
            const SizedBox(height: 16),
            // Progress slider
            _buildProgressSlider(playlistState),
            const SizedBox(height: 16),
            // Main controls
            _buildMainControls(playlistState),
            const SizedBox(height: 8),
            // Secondary controls
            _buildSecondaryControls(playlistState),
          ],
        ),
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
        // Artist - clickable to navigate to profile
        // Source: biu/src/layout/playbar/left/index.tsx - click owner navigates to user page
        if (currentItem.ownerName != null && currentItem.ownerName!.isNotEmpty)
          GestureDetector(
            onTap: () {
              if (currentItem.ownerMid != null) {
                Navigator.of(context).pop(); // Close full player first
                context.push(AppRoutes.userSpacePath(currentItem.ownerMid!));
              }
            },
            child: Text(
              currentItem.ownerName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    decoration: currentItem.ownerMid != null
                        ? TextDecoration.underline
                        : null,
                    decorationColor: AppColors.textSecondary,
                  ),
            ),
          ),
        // Quality badges
        if (currentItem.isLossless == true || currentItem.isDolby == true) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentItem.isLossless == true)
                _buildBadge('无损'),
              if (currentItem.isDolby == true) ...[
                const SizedBox(width: 8),
                _buildBadge('杜比'),
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
            CupertinoIcons.backward_fill,
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
                    isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
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
            CupertinoIcons.forward_fill,
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
        return CupertinoIcons.list_bullet;
      case PlayMode.loop:
        return CupertinoIcons.repeat;
      case PlayMode.single:
        return CupertinoIcons.repeat_1;
      case PlayMode.random:
        return CupertinoIcons.shuffle;
    }
  }

  String _getPlayModeTooltip(PlayMode mode) {
    switch (mode) {
      case PlayMode.sequence:
        return '顺序播放';
      case PlayMode.loop:
        return '列表循环';
      case PlayMode.single:
        return '单曲循环';
      case PlayMode.random:
        return '随机播放';
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
      title: const Text('播放速度'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: rates.map((rate) {
          return ListTile(
            title: Text('${rate}x'),
            trailing: rate == currentRate
                ? const Icon(CupertinoIcons.checkmark, color: AppColors.primary)
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
                    '播放列表 (${playlistState.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      notifier.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('清空'),
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
                      icon: const Icon(CupertinoIcons.xmark, size: 20),
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

/// Bottom sheet showing video parts for multi-part videos
/// Source: biu/src/layout/playbar/left/video-page-list/index.tsx
class _VideoPageListSheet extends StatefulWidget {
  const _VideoPageListSheet({
    required this.pages,
    required this.currentPlayId,
    required this.onPageTap,
  });

  final List<PlayItem> pages;
  final String? currentPlayId;
  final void Function(PlayItem) onPageTap;

  @override
  State<_VideoPageListSheet> createState() => _VideoPageListSheetState();
}

class _VideoPageListSheetState extends State<_VideoPageListSheet> {
  final _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlayItem> get _filteredPages {
    if (_searchKeyword.isEmpty) return widget.pages;
    final lowerKeyword = _searchKeyword.toLowerCase();
    return widget.pages.where((item) {
      final title = item.pageTitle ?? item.title;
      return title.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
            // Header with search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '分P列表',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  // Search input
                  SizedBox(
                    width: 150,
                    height: 32,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜索分P',
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(CupertinoIcons.search, size: 16),
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      style: const TextStyle(fontSize: 12),
                      onChanged: (value) => setState(() => _searchKeyword = value),
                    ),
                  ),
                ],
              ),
            ),
            // Pages list
            Expanded(
              child: _filteredPages.isEmpty
                  ? const Center(
                      child: Text(
                        '没有匹配的分P',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filteredPages.length,
                      itemBuilder: (context, index) {
                        final item = _filteredPages[index];
                        final isActive = item.id == widget.currentPlayId;

                        return ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.pageIndex ?? index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight:
                                    isActive ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          title: Text(
                            item.pageTitle ?? item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive ? AppColors.primary : null,
                              fontWeight:
                                  isActive ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          trailing: isActive
                              ? const Icon(
                                  CupertinoIcons.play_circle,
                                  color: AppColors.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () => widget.onPageTap(item),
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

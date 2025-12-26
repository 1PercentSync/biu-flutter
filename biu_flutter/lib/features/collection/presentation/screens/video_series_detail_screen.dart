import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/global_snackbar.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../../player/player.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../data/datasources/collection_remote_datasource.dart';
import '../../data/models/video_series_detail.dart';

const _uuid = Uuid();

/// Video series detail screen
/// Source: biu/src/pages/video-collection/video-series.tsx
class VideoSeriesDetailScreen extends ConsumerStatefulWidget {
  const VideoSeriesDetailScreen({
    required this.seasonId,
    super.key,
  });

  final int seasonId;

  @override
  ConsumerState<VideoSeriesDetailScreen> createState() =>
      _VideoSeriesDetailScreenState();
}

class _VideoSeriesDetailScreenState
    extends ConsumerState<VideoSeriesDetailScreen> {
  final _datasource = CollectionRemoteDatasource();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  VideoSeriesDetailData? _data;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Search and filter state
  String _keyword = '';
  String _order = ''; // '', 'play', 'collect', 'time'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _datasource.getVideoSeriesDetail(
        seasonId: widget.seasonId,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _data = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
              response.message.isNotEmpty ? response.message : 'Failed to load';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Get filtered and sorted media list
  List<SeriesMediaItem> get _filteredMedias {
    if (_data == null) return [];

    var result = _data!.medias.toList();

    // Filter by keyword
    if (_keyword.isNotEmpty) {
      final lowercaseKeyword = _keyword.toLowerCase();
      result = result
          .where((item) => item.title.toLowerCase().contains(lowercaseKeyword))
          .toList();
    }

    // Sort by order
    switch (_order) {
      case 'play':
        result.sort((a, b) => b.cntInfo.play.compareTo(a.cntInfo.play));
        break;
      case 'collect':
        result.sort((a, b) => b.cntInfo.collect.compareTo(a.cntInfo.collect));
        break;
      case 'time':
        result.sort((a, b) => b.pubtime.compareTo(a.pubtime));
        break;
      default:
        // Keep original order
        break;
    }

    return result;
  }

  void _playAll() {
    final medias = _filteredMedias;
    if (medias.isEmpty) {
      GlobalSnackbar.showError('没有可播放的内容');
      return;
    }

    final playItems = medias.map(_mediaToPlayItem).toList();
    ref.read(playlistProvider.notifier).playList(playItems);
  }

  void _addAllToPlaylist() {
    final medias = _filteredMedias;
    if (medias.isEmpty) {
      GlobalSnackbar.showError('没有可添加的内容');
      return;
    }

    final playItems = medias.map(_mediaToPlayItem).toList();
    ref.read(playlistProvider.notifier).addList(playItems);
    GlobalSnackbar.showSuccess('已添加 ${playItems.length} 个视频到播放列表');
  }

  void _showHeaderActionMenu(BuildContext context, VideoSeriesInfo info) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.contentBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                info.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 1),
            // Add to playlist
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('添加到播放列表'),
              onTap: () {
                Navigator.pop(context);
                _addAllToPlaylist();
              },
            ),
            // Collect (favorite)
            ListTile(
              leading: const Icon(Icons.star_border, color: AppColors.primary),
              title: const Text('收藏', style: TextStyle(color: AppColors.primary)),
              onTap: () {
                Navigator.pop(context);
                GlobalSnackbar.showInfo('收藏功能开发中');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _playMedia(SeriesMediaItem media) {
    ref.read(playlistProvider.notifier).play(_mediaToPlayItem(media));
  }

  PlayItem _mediaToPlayItem(SeriesMediaItem media) {
    // Don't pass ownerMid for videos to trigger fetching all pages
    // Source: biu/src/store/play-list.ts:527-535
    return PlayItem(
      id: _uuid.v4(),
      title: media.title,
      type: PlayDataType.mv,
      bvid: media.bvid,
      aid: media.id.toString(),
      cover: media.cover,
      ownerName: media.upper.name,
      // ownerMid intentionally omitted to trigger multi-part fetch
      duration: media.duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayMode = ref.watch(displayModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildError()
              : _buildContent(displayMode),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DisplayMode displayMode) {
    final info = _data!.info;
    final medias = _filteredMedias;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar with back button
        const SliverAppBar(
          floating: true,
          snap: true,
        ),
        // Header info section
        SliverToBoxAdapter(
          child: _buildHeader(info),
        ),
        // Search and filter bar
        SliverToBoxAdapter(
          child: _buildSearchFilter(),
        ),
        // Media list/grid
        if (medias.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                '没有找到视频',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else if (displayMode == DisplayMode.card)
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final media = medias[index];
                  return _MediaCardItem(
                    media: media,
                    onTap: () => _playMedia(media),
                  );
                },
                childCount: medias.length,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final media = medias[index];
                return _MediaListItem(
                  media: media,
                  onTap: () => _playMedia(media),
                );
              },
              childCount: medias.length,
            ),
          ),
        // Bottom padding for player bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeader(VideoSeriesInfo info) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppCachedImage(
              imageUrl: info.cover,
              width: 120,
              height: 120,
            ),
          ),
          const SizedBox(width: 16),
          // Info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  info.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Description
                if (info.intro.isNotEmpty) ...[
                  Text(
                    info.intro,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                // Creator info
                GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.userSpacePath(info.upper.mid),
                  ),
                  child: Text(
                    info.upper.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                // Stats
                Text(
                  '视频合集 · ${info.mediaCount} 个视频',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  children: [
                    if (info.mediaCount > 0)
                      ElevatedButton.icon(
                        onPressed: _playAll,
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('播放全部'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Action menu button
                    IconButton(
                      onPressed: () => _showHeaderActionMenu(context, info),
                      icon: const Icon(Icons.more_horiz),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search input
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索视频...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (value) {
                  setState(() {
                    _keyword = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sort dropdown
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _order,
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                style: Theme.of(context).textTheme.bodyMedium,
                items: const [
                  DropdownMenuItem(
                    value: '',
                    child: Text('默认排序'),
                  ),
                  DropdownMenuItem(
                    value: 'play',
                    child: Text('播放量'),
                  ),
                  DropdownMenuItem(
                    value: 'collect',
                    child: Text('收藏数'),
                  ),
                  DropdownMenuItem(
                    value: 'time',
                    child: Text('发布时间'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _order = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Media list item widget
/// Source: biu/src/components/music-list-item/index.tsx
class _MediaListItem extends StatelessWidget {
  const _MediaListItem({
    required this.media,
    required this.onTap,
  });

  final SeriesMediaItem media;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Square thumbnail
            SizedBox(
              width: 48,
              height: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                child: AppCachedImage(
                  imageUrl: media.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    media.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Creator name
                  Text(
                    media.upper.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Play count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                NumberUtils.formatCompact(media.cntInfo.play),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            // Duration
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                media.formattedDuration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ),
            // Action menu
            MediaActionMenu(
              title: media.title,
              bvid: media.bvid,
              aid: media.id.toString(),
              cover: media.cover,
              ownerName: media.upper.name,
              ownerMid: media.upper.mid,
            ),
          ],
        ),
      ),
    );
  }
}

/// Media card item widget for grid view
class _MediaCardItem extends StatelessWidget {
  const _MediaCardItem({
    required this.media,
    required this.onTap,
  });

  final SeriesMediaItem media;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.contentBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover image with play count badge
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.borderRadius),
                    ),
                    child: AppCachedImage(
                      imageUrl: media.cover,
                    ),
                  ),
                  // Play count badge
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
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
                            NumberUtils.formatCompact(media.cntInfo.play),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Video info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with action menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          media.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      MediaActionMenu(
                        title: media.title,
                        bvid: media.bvid,
                        aid: media.id.toString(),
                        cover: media.cover,
                        ownerName: media.upper.name,
                        ownerMid: media.upper.mid,
                        iconSize: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Footer: author and duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          media.upper.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        media.formattedDuration,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

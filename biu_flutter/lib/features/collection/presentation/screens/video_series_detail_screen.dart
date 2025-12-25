import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/global_snackbar.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../player/player.dart';
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

  void _playMedia(SeriesMediaItem media) {
    final playItem = _mediaToPlayItem(media);
    ref.read(playlistProvider.notifier).play(playItem);
  }

  PlayItem _mediaToPlayItem(SeriesMediaItem media) {
    return PlayItem(
      id: _uuid.v4(),
      title: media.title,
      type: PlayDataType.mv,
      bvid: media.bvid,
      aid: media.id.toString(),
      cover: media.cover,
      ownerName: media.upper.name,
      ownerMid: media.upper.mid,
      duration: media.duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildError()
              : _buildContent(),
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

  Widget _buildContent() {
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
        // Media list
        if (medias.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                '没有找到视频',
                style: TextStyle(color: AppColors.textSecondary),
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
                    IconButton(
                      onPressed: _addAllToPlaylist,
                      icon: const Icon(Icons.playlist_add),
                      tooltip: '添加到播放列表',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with duration
            SizedBox(
              width: 120,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppCachedImage(
                        imageUrl: media.cover,
                      ),
                    ),
                    // Duration badge
                    Positioned(
                      right: 4,
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
                        child: Text(
                          media.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    media.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Creator name
                  Text(
                    media.upper.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Stats row
                  Row(
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatNumber(media.cntInfo.play),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(media.publishDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
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

  String _formatNumber(int num) {
    if (num >= 100000000) {
      return '${(num / 100000000).toStringAsFixed(1)}亿';
    } else if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(1)}万';
    }
    return num.toString();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

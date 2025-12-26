import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../data/datasources/user_profile_remote_datasource.dart';
import '../../data/models/video_series.dart';

/// Video series (seasons/collections) tab for user profile.
///
/// Displays user's video series in a grid or list layout based on displayMode.
/// Source: biu/src/pages/user-profile/video-series.tsx
class VideoSeriesTab extends ConsumerStatefulWidget {
  const VideoSeriesTab({
    required this.mid,
    super.key,
  });

  final int mid;

  @override
  ConsumerState<VideoSeriesTab> createState() => _VideoSeriesTabState();
}

class _VideoSeriesTabState extends ConsumerState<VideoSeriesTab> {
  final List<VideoSeriesItem> _items = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  late final UserProfileRemoteDataSource _datasource;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _datasource = UserProfileRemoteDataSource();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentPage = 1;
    });

    try {
      final response = await _datasource.getSeasonsSeriesList(
        mid: widget.mid,
        pageNum: _currentPage,
      );

      if (response.isSuccess && response.data?.itemsList != null) {
        final itemsList = response.data!.itemsList!;
        setState(() {
          _items
            ..clear()
            ..addAll(itemsList.allItems);
          _totalPages = itemsList.page?.totalPages ?? 1;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response.message.isNotEmpty
              ? response.message
              : 'Failed to load video series';
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

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _datasource.getSeasonsSeriesList(
        mid: widget.mid,
        pageNum: _currentPage + 1,
      );

      if (response.isSuccess && response.data?.itemsList != null) {
        final itemsList = response.data!.itemsList!;
        setState(() {
          _items.addAll(itemsList.allItems);
          _currentPage++;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayMode = ref.watch(displayModeProvider);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return ErrorState(
        message: _errorMessage,
        onRetry: _loadData,
      );
    }

    if (_items.isEmpty) {
      return const EmptyState(
        icon: Icon(
          Icons.video_library_outlined,
          size: 48,
          color: Color(0xFF9CA3AF),
        ),
        title: '暂无视频合集',
        message: '暂无可用的视频合集',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: displayMode == DisplayMode.card
          ? _buildGridView()
          : _buildListView(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = _items[index];
        return _VideoSeriesCard(
          item: item,
          onTap: () => _onSeriesTap(item),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = _items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _VideoSeriesListTile(
            item: item,
            onTap: () => _onSeriesTap(item),
          ),
        );
      },
    );
  }

  void _onSeriesTap(VideoSeriesItem item) {
    // Navigate to collection detail
    // Source: biu/src/pages/user-profile/video-series.tsx:71
    // navigate(`/collection/${item.id}?type=${CollectionType.VideoSeries}`)
    context.push(AppRoutes.collectionPath(item.id, type: 'video_series'));
  }
}

/// Card widget for displaying a video series item.
/// Source: biu/src/pages/user-profile/video-series.tsx:104-116
class _VideoSeriesCard extends StatelessWidget {
  const _VideoSeriesCard({
    required this.item,
    required this.onTap,
  });

  final VideoSeriesItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AppCachedImage(
                imageUrl: item.cover,
                fileType: FileType.video,
              ),
            ),
            // Series info - use Expanded to fill remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title - flexible to allow shrinking
                    Flexible(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Footer: date and count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.ctime.toDateString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        Text(
                          '${item.total}个视频',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List tile widget for displaying a video series item.
class _VideoSeriesListTile extends StatelessWidget {
  const _VideoSeriesListTile({
    required this.item,
    required this.onTap,
  });

  final VideoSeriesItem item;
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Square thumbnail
              SizedBox(
                width: 64,
                height: 64,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                  child: AppCachedImage(
                    imageUrl: item.cover,
                    fileType: FileType.video,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Series info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Video count and date (like source)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.total}个视频',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        Text(
                          item.ctime.toDateString(),
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
      ),
    );
  }
}

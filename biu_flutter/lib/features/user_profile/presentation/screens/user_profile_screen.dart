import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../shared/theme/theme.dart';
import '../../../auth/auth.dart';
import '../../../player/player.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../data/models/space_arc_search.dart';
import '../providers/user_profile_notifier.dart';
import '../providers/user_profile_state.dart';
import '../widgets/dynamic_list.dart';
import '../widgets/space_info_header.dart';
import '../widgets/user_favorites_tab.dart';
import '../widgets/video_post_card.dart';
import '../widgets/video_series_tab.dart';

const _uuid = Uuid();

/// Tab definition for user profile
class _ProfileTab {
  const _ProfileTab({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;
}

/// User profile screen
/// Reference: biu/src/pages/user-profile/index.tsx
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({
    required this.mid,
    super.key,
  });

  final int mid;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _scrollController = ScrollController();
  final _keywordController = TextEditingController();

  /// Debounce timer for keyword search
  Timer? _keywordDebounceTimer;
  static const _keywordDebounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _keywordDebounceTimer?.cancel();
    _scrollController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(userProfileProvider(widget.mid).notifier).loadMoreVideos();
    }
  }

  /// Build visible tabs based on current state
  /// Source: biu/src/pages/user-profile/index.tsx:96-118
  List<_ProfileTab> _buildTabs(
    UserProfileState state,
    int? currentUserId,
    bool isSelf,
  ) {
    final showFavorites = isSelf || state.shouldShowFavoritesTab(currentUserId);
    return <_ProfileTab>[
      const _ProfileTab(key: 'dynamic', label: '动态'),
      const _ProfileTab(key: 'video', label: '投稿'),
      if (showFavorites) const _ProfileTab(key: 'favorites', label: '收藏夹'),
      const _ProfileTab(key: 'union', label: '合集'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileProvider(widget.mid));
    final authState = ref.watch(authNotifierProvider);
    final displayMode = ref.watch(displayModeProvider);
    final isSelf = authState.user?.mid == widget.mid;
    final currentUserId = authState.user?.mid;

    // Source: biu/src/pages/user-profile/index.tsx:120-126
    // Show loading spinner while userInfo is loading
    if (state.isLoadingInfo && state.spaceInfo == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Build tabs - computed on each render like source project
    final visibleTabs = _buildTabs(state, currentUserId, isSelf);

    return Scaffold(
      body: state.spaceInfo == null
          ? const Center(child: Text('加载失败'))
          : DefaultTabController(
              length: visibleTabs.length,
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // App bar
                  const SliverAppBar(
                    floating: true,
                    snap: true,
                    forceElevated: false,
                  ),
                  // Header
                  SliverToBoxAdapter(
                    child: SpaceInfoHeader(
                      spaceInfo: state.spaceInfo!,
                      relationStat: state.relationStat,
                      relationData: state.relationData,
                      isSelf: isSelf,
                      isLoggedIn: authState.isAuthenticated,
                      onFollowTap: authState.isAuthenticated
                          ? () => ref
                              .read(userProfileProvider(widget.mid).notifier)
                              .toggleFollow()
                          : null,
                    ),
                  ),
                  // Blocked view or Tab bar
                  if (state.isBlocked)
                    const SliverFillRemaining(
                      child: Center(child: Text('该用户已被拉黑')),
                    )
                  else
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(
                        TabBar(
                          tabs: visibleTabs
                              .map((tab) => Tab(text: tab.label))
                              .toList(),
                          indicatorColor: AppColors.primary,
                          labelColor: AppColors.textPrimary,
                          unselectedLabelColor: AppColors.textTertiary,
                        ),
                      ),
                    ),
                ],
                body: state.isBlocked
                    ? const SizedBox.shrink()
                    : TabBarView(
                        children: visibleTabs.map((tab) {
                          switch (tab.key) {
                            case 'dynamic':
                              return DynamicList(mid: widget.mid);
                            case 'video':
                              return _buildVideosContent(
                                  context, state, displayMode);
                            case 'favorites':
                              return UserFavoritesTab(mid: widget.mid);
                            case 'union':
                              return VideoSeriesTab(mid: widget.mid);
                            default:
                              return const SizedBox.shrink();
                          }
                        }).toList(),
                      ),
              ),
            ),
    );
  }

  Widget _buildVideosContent(
    BuildContext context,
    UserProfileState state,
    DisplayMode displayMode,
  ) {
    return Column(
      children: [
        _buildSearchFilter(context, state),
        Expanded(
          child: displayMode == DisplayMode.card
              ? _buildVideosGrid(context, state)
              : _buildVideosList(context, state),
        ),
      ],
    );
  }

  Widget _buildSearchFilter(BuildContext context, UserProfileState state) {
    return ColoredBox(
      color: AppColors.contentBackground,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Search input
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: _keywordController,
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
                    _keywordDebounceTimer?.cancel();
                    _keywordDebounceTimer = Timer(_keywordDebounceDuration, () {
                      ref
                          .read(userProfileProvider(widget.mid).notifier)
                          .setVideoKeyword(value);
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
                  value: state.videoOrder,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  style: Theme.of(context).textTheme.bodyMedium,
                  items: const [
                    DropdownMenuItem(
                      value: 'pubdate',
                      child: Text('最新'),
                    ),
                    DropdownMenuItem(
                      value: 'click',
                      child: Text('最多播放'),
                    ),
                    DropdownMenuItem(
                      value: 'stow',
                      child: Text('最多收藏'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(userProfileProvider(widget.mid).notifier)
                          .setVideoOrder(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosGrid(BuildContext context, UserProfileState state) {
    if (state.isLoadingVideos && (state.videos?.isEmpty ?? true)) {
      return const Center(child: CircularProgressIndicator());
    }

    final videos = state.videos ?? [];

    if (videos.isEmpty) {
      return _buildEmptyVideos();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: videos.length + (state.hasMoreVideos ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == videos.length) {
          if (state.isLoadingMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final video = videos[index];
        return VideoPostCard(
          video: video,
          onTap: () => _playVideo(video),
        );
      },
    );
  }

  Widget _buildVideosList(BuildContext context, UserProfileState state) {
    if (state.isLoadingVideos && (state.videos?.isEmpty ?? true)) {
      return const Center(child: CircularProgressIndicator());
    }

    final videos = state.videos ?? [];

    if (videos.isEmpty) {
      return _buildEmptyVideos();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: videos.length + (state.hasMoreVideos ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == videos.length) {
          if (state.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        }

        final video = videos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: VideoPostListTile(
            video: video,
            onTap: () => _playVideo(video),
          ),
        );
      },
    );
  }

  Widget _buildEmptyVideos() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            '暂无视频',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _playVideo(SpaceArcVListItem video) {
    final playItem = PlayItem(
      id: _uuid.v4(),
      title: video.title,
      type: PlayDataType.mv,
      bvid: video.bvid,
      aid: video.aid.toString(),
      cover: video.pic,
      ownerName: video.author,
      ownerMid: video.mid,
      duration: video.durationSeconds,
    );

    ref.read(playlistProvider.notifier).play(playItem);
  }
}

/// Delegate for pinned tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.contentBackground,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

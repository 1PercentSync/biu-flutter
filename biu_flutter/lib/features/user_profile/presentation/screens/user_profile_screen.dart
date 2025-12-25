import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../shared/theme/theme.dart';
import '../../../auth/auth.dart';
import '../../../player/player.dart';
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
    this.hidden = false,
  });

  final String key;
  final String label;
  final bool hidden;
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

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final _scrollController = ScrollController();
  final _keywordController = TextEditingController();
  int _currentTabIndex = 0;
  List<_ProfileTab> _visibleTabs = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more based on current tab key
      // Note: dynamic and union tabs manage their own scroll loading
      if (_currentTabIndex < _visibleTabs.length) {
        final tabKey = _visibleTabs[_currentTabIndex].key;
        if (tabKey == 'video') {
          ref.read(userProfileProvider(widget.mid).notifier).loadMoreVideos();
        } else if (tabKey == 'favorites') {
          ref.read(userProfileProvider(widget.mid).notifier).loadMoreFolders();
        }
      }
    }
  }

  void _updateTabs(UserProfileState state, int? currentUserId, bool isSelf) {
    // Build tabs based on privacy settings
    // Source: biu/src/pages/user-profile/index.tsx:96-118
    final newTabs = <_ProfileTab>[
      const _ProfileTab(key: 'dynamic', label: '动态'),
      const _ProfileTab(key: 'video', label: '视频'),
      _ProfileTab(
        key: 'favorites',
        label: '收藏',
        hidden: !isSelf && !state.shouldShowFavoritesTab(currentUserId),
      ),
      const _ProfileTab(key: 'union', label: '合集'),
    ].where((tab) => !tab.hidden).toList();

    // Only update if tabs changed
    if (_visibleTabs.length != newTabs.length ||
        _tabController == null ||
        _tabController!.length != newTabs.length) {
      setState(() {
        _visibleTabs = newTabs;
        _tabController?.dispose();
        _tabController = TabController(
          length: newTabs.length,
          vsync: this,
        );
        _tabController!.addListener(() {
          setState(() {
            _currentTabIndex = _tabController!.index;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileProvider(widget.mid));
    final authState = ref.watch(authNotifierProvider);
    final isSelf = authState.user?.mid == widget.mid;
    final currentUserId = authState.user?.mid;

    // Update tabs when privacy settings are loaded
    if (state.spacePrivacy != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTabs(state, currentUserId, isSelf);
      });
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(userProfileProvider(widget.mid).notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(state.spaceInfo?.name ?? '用户'),
            ),
            // Header
            if (state.spaceInfo != null)
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
              )
            else if (state.isLoadingInfo)
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            // Blocked view
            if (state.isBlocked)
              const SliverFillRemaining(
                child: Center(
                  child: Text('该用户已被拉黑'),
                ),
              )
            else if (_tabController != null && _visibleTabs.isNotEmpty) ...[
              // Tab bar
              SliverToBoxAdapter(
                child: _buildTabBar(context),
              ),
              // Tab content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: _visibleTabs.map((tab) {
                    switch (tab.key) {
                      case 'dynamic':
                        return DynamicList(mid: widget.mid);
                      case 'video':
                        return _buildVideosContent(context, state);
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return ColoredBox(
      color: AppColors.contentBackground,
      child: TabBar(
        controller: _tabController,
        tabs: _visibleTabs.map((tab) => Tab(text: tab.label)).toList(),
        indicatorColor: AppColors.primary,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildVideosContent(BuildContext context, UserProfileState state) {
    return Column(
      children: [
        _buildSearchFilter(context, state),
        Expanded(
          child: _buildVideosGrid(context, state),
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
                  onSubmitted: (value) {
                    ref
                        .read(userProfileProvider(widget.mid).notifier)
                        .setVideoKeyword(value);
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
              'No videos found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: videos.length + (state.hasMoreVideos ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the end
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../../../shared/widgets/song_item.dart';
import '../../../artist_rank/data/models/musician.dart';
import '../../../artist_rank/presentation/providers/artist_rank_notifier.dart';
import '../../../artist_rank/presentation/providers/artist_rank_state.dart';
import '../../../artist_rank/presentation/widgets/musician_card.dart';
import '../../../music_rank/music_rank.dart';
import '../../../music_recommend/data/models/recommended_song.dart';
import '../../../music_recommend/presentation/providers/music_recommend_notifier.dart';
import '../../../music_recommend/presentation/providers/music_recommend_state.dart';
import '../../../player/player.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';

/// Tab-based home screen with iOS-style swipeable tabs.
///
/// Displays three tabs:
/// - 热歌精选 (Hot Songs) - Music rank hot songs
/// - 音乐大咖 (Artists) - Artist rank musicians
/// - 音乐推荐 (Recommendations) - Music recommendations
///
/// Source: prototype/home_tabs_prototype.html (iOS-native design)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  int _currentTab = 0;

  static const List<String> _tabLabels = ['热歌精选', '音乐大咖', '音乐推荐'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topSafeArea = mediaQuery.padding.top;
    final headerHeight = topSafeArea + AppTheme.tabHeaderHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Page content (with top padding for header)
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _HotSongsTab(topPadding: headerHeight),
                _ArtistsTab(topPadding: headerHeight),
                _RecommendTab(topPadding: headerHeight),
              ],
            ),
          ),

          // Top frosted glass backdrop
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: const GlassBackdrop(
              alignment: Alignment.topCenter,
            ),
          ),

          // Tab header (on top of glass)
          Positioned(
            top: topSafeArea,
            left: 0,
            right: 0,
            child: _AdaptiveTabHeader(
              tabs: _tabLabels,
              currentIndex: _currentTab,
              onTap: _onTabTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// Adaptive tab header that auto-sizes font based on available width.
class _AdaptiveTabHeader extends StatelessWidget {
  const _AdaptiveTabHeader({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.tabHeaderHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fontSize = _calculateOptimalFontSize(
              containerWidth: constraints.maxWidth,
              tabs: tabs,
            );

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final label = entry.value;
                final isActive = index == currentIndex;

                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? GlassStyles.activeColor
                          : GlassStyles.inactiveColor,
                    ),
                    child: Text(label),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  double _calculateOptimalFontSize({
    required double containerWidth,
    required List<String> tabs,
  }) {
    // Binary search for the largest font size that fits
    const minSize = AppTheme.tabFontSizeMin;
    const maxSize = AppTheme.tabFontSizeMax;
    const minGap = AppTheme.tabMinGap;

    double optimalSize = minSize;

    for (double size = maxSize; size >= minSize; size -= 1) {
      double totalWidth = 0;

      for (final tab in tabs) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: tab,
            style: TextStyle(fontSize: size, fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        totalWidth += textPainter.width;
      }

      // Add gaps between tabs
      totalWidth += minGap * (tabs.length - 1);

      if (totalWidth <= containerWidth) {
        optimalSize = size;
        break;
      }
    }

    return optimalSize;
  }
}

/// Hot Songs tab content (热歌精选).
class _HotSongsTab extends ConsumerWidget {
  const _HotSongsTab({required this.topPadding});

  final double topPadding;
  static const _uuid = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(musicRankProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(musicRankProvider.notifier).refresh(),
      edgeOffset: topPadding,
      child: CustomScrollView(
        slivers: [
          // Top padding for header
          SliverToBoxAdapter(
            child: SizedBox(height: topPadding),
          ),
          // Content
          _buildContent(context, ref, state),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MusicRankState state,
  ) {
    if (state.isLoading && state.songs.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingState(message: '加载热歌中...'),
      );
    }

    if (state.hasError && state.songs.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '加载失败',
          message: state.errorMessage,
          onRetry: () => ref.read(musicRankProvider.notifier).load(),
        ),
      );
    }

    if (state.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '暂无数据',
          message: '当前没有热门歌曲。',
        ),
      );
    }

    final displayMode = ref.watch(displayModeProvider);

    if (displayMode == DisplayMode.list) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = state.songs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SongItem(
                  displayMode: displayMode,
                  title: song.musicTitle,
                  author: song.author,
                  bvid: song.bvid,
                  aid: song.aid,
                  cid: song.cid,
                  cover: song.cover,
                  playCount: song.totalVv,
                  onTap: () => _playSong(ref, song),
                ),
              );
            },
            childCount: state.songs.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.74,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final song = state.songs[index];
            return SongItem(
              displayMode: displayMode,
              title: song.musicTitle,
              author: song.author,
              bvid: song.bvid,
              aid: song.aid,
              cid: song.cid,
              cover: song.cover,
              playCount: song.totalVv,
              onTap: () => _playSong(ref, song),
            );
          },
          childCount: state.songs.length,
        ),
      ),
    );
  }

  void _playSong(WidgetRef ref, HotSong song) {
    final playItem = PlayItem(
      id: _uuid.v4(),
      title: song.musicTitle,
      type: PlayDataType.mv,
      bvid: song.bvid,
      aid: song.aid,
      cid: song.cid,
      cover: song.cover,
      ownerName: song.author,
    );
    ref.read(playlistProvider.notifier).play(playItem);
  }
}

/// Artists tab content (音乐大咖).
class _ArtistsTab extends ConsumerStatefulWidget {
  const _ArtistsTab({required this.topPadding});

  final double topPadding;

  @override
  ConsumerState<_ArtistsTab> createState() => _ArtistsTabState();
}

class _ArtistsTabState extends ConsumerState<_ArtistsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(artistRankProvider);
      if (state.musicians.isEmpty && !state.isLoading) {
        ref.read(artistRankProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(artistRankProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(artistRankProvider.notifier).refresh(),
      edgeOffset: widget.topPadding,
      child: _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, ArtistRankState state) {
    if (state.isLoading && state.musicians.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: widget.topPadding)),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: LoadingState(message: '加载音乐人中...'),
          ),
        ],
      );
    }

    if (state.hasError && state.musicians.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: widget.topPadding)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              title: '加载失败',
              message: state.errorMessage,
              action: ElevatedButton(
                onPressed: () => ref.read(artistRankProvider.notifier).load(),
                child: const Text('重试'),
              ),
            ),
          ),
        ],
      );
    }

    if (state.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: widget.topPadding)),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icon(Icons.music_note, size: 48, color: AppColors.textTertiary),
              title: '暂无数据',
              message: '暂无音乐人数据',
            ),
          ),
        ],
      );
    }

    return _buildGrid(context, state.musicians);
  }

  Widget _buildGrid(BuildContext context, List<Musician> musicians) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: widget.topPadding)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              // Avatar 1:1 + name ~24px = aspect ratio ~0.82
              childAspectRatio: 0.82,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final musician = musicians[index];
                return ArtistAvatarCard(
                  musician: musician,
                  onTap: () => context.push(AppRoutes.userSpacePath(musician.uid)),
                );
              },
              childCount: musicians.length,
            ),
          ),
        ),
      ],
    );
  }
}

/// Recommendations tab content (音乐推荐).
class _RecommendTab extends ConsumerStatefulWidget {
  const _RecommendTab({required this.topPadding});

  final double topPadding;

  @override
  ConsumerState<_RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends ConsumerState<_RecommendTab>
    with AutomaticKeepAliveClientMixin {
  static const _uuid = Uuid();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      ref.read(musicRecommendProvider.notifier).loadMore();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= maxScroll - 200;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(musicRecommendProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(musicRecommendProvider.notifier).refresh(),
      edgeOffset: widget.topPadding,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: widget.topPadding)),
          _buildContent(context, state),
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (!state.hasMore && state.songs.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '没有更多了',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, MusicRecommendState state) {
    if (state.isLoading && state.songs.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingState(message: '加载推荐中...'),
      );
    }

    if (state.hasError && state.songs.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '加载失败',
          message: state.errorMessage,
          onRetry: () => ref.read(musicRecommendProvider.notifier).load(),
        ),
      );
    }

    if (state.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '暂无推荐',
          message: '暂时没有音乐推荐',
        ),
      );
    }

    final displayMode = ref.watch(displayModeProvider);

    if (displayMode == DisplayMode.list) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = state.songs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SongItem(
                  displayMode: displayMode,
                  title: song.musicTitle,
                  author: song.author,
                  bvid: song.bvid,
                  aid: song.aid,
                  cid: song.cid,
                  cover: song.cover,
                  playCount: song.playCount,
                  onTap: () => _playSong(song),
                ),
              );
            },
            childCount: state.songs.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.74,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final song = state.songs[index];
            return SongItem(
              displayMode: displayMode,
              title: song.musicTitle,
              author: song.author,
              bvid: song.bvid,
              aid: song.aid,
              cid: song.cid,
              cover: song.cover,
              playCount: song.playCount,
              onTap: () => _playSong(song),
            );
          },
          childCount: state.songs.length,
        ),
      ),
    );
  }

  void _playSong(RecommendedSong song) {
    final playItem = PlayItem(
      id: _uuid.v4(),
      title: song.musicTitle,
      type: PlayDataType.mv,
      bvid: song.bvid,
      aid: song.aid,
      cid: song.cid,
      cover: song.cover,
      ownerName: song.author,
    );
    ref.read(playlistProvider.notifier).play(playItem);
  }
}

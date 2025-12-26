import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/song_item.dart';
import '../../../player/player.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../data/models/recommended_song.dart';
import '../providers/music_recommend_notifier.dart';
import '../providers/music_recommend_state.dart';

/// Music recommend screen displaying recommended songs with infinite scroll.
/// Source: biu/src/pages/music-recommend/index.tsx
class MusicRecommendScreen extends ConsumerStatefulWidget {
  const MusicRecommendScreen({super.key});

  @override
  ConsumerState<MusicRecommendScreen> createState() =>
      _MusicRecommendScreenState();
}

class _MusicRecommendScreenState extends ConsumerState<MusicRecommendScreen> {
  static const _uuid = Uuid();
  final _scrollController = ScrollController();

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
    // Load more when 200px from bottom
    return currentScroll >= maxScroll - 200;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(musicRecommendProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(musicRecommendProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            const SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              title: Text('音乐推荐'),
            ),
            // Content
            _buildContent(context, state),
            // Loading more indicator
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            // No more items indicator
            if (!state.hasMore && state.songs.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No more items',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
      // List view mode
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

    // Grid view mode (default)
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          // Cover 1:1 + info ~70px = ~270px for 200px width
          // Aspect ratio = 200/270 ≈ 0.74
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../music_rank/music_rank.dart';
import '../../../player/player.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';

/// Home screen displaying music hot rank.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _uuid = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicRankState = ref.watch(musicRankProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(musicRankProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              title: const Text('Hot Songs'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.recommend_outlined),
                  tooltip: 'Music Recommend',
                  onPressed: () => context.push(AppRoutes.musicRecommend),
                ),
                IconButton(
                  icon: const Icon(Icons.people_outline),
                  tooltip: 'Music Artists',
                  onPressed: () => context.push(AppRoutes.artistRank),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: musicRankState.isLoading
                      ? null
                      : () => ref.read(musicRankProvider.notifier).refresh(),
                ),
              ],
            ),
            // Content
            _buildContent(context, ref, musicRankState),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, MusicRankState state) {
    if (state.isLoading && state.songs.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingState(message: 'Loading hot songs...'),
      );
    }

    if (state.hasError && state.songs.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: 'Failed to load',
          message: state.errorMessage,
          onRetry: () => ref.read(musicRankProvider.notifier).load(),
        ),
      );
    }

    if (state.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: 'No songs',
          message: 'No hot songs available at the moment.',
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
                child: HotSongListTile(
                  song: song,
                  rank: index + 1,
                  onTap: () => _playSong(ref, song),
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
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final song = state.songs[index];
            return HotSongCard(
              song: song,
              rank: index + 1,
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

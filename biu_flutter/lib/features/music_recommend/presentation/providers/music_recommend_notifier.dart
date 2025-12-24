import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/music_recommend_remote_datasource.dart';
import 'music_recommend_state.dart';

/// Provider for music recommend datasource.
final musicRecommendDataSourceProvider =
    Provider<MusicRecommendRemoteDataSource>((ref) {
  return MusicRecommendRemoteDataSource();
});

/// Provider for music recommend state.
/// Source: biu/src/pages/music-recommend/index.tsx (state logic)
final musicRecommendProvider =
    StateNotifierProvider<MusicRecommendNotifier, MusicRecommendState>((ref) {
  final dataSource = ref.watch(musicRecommendDataSourceProvider);
  return MusicRecommendNotifier(dataSource);
});

/// Notifier for music recommend screen with pagination.
/// Source: biu/src/pages/music-recommend/index.tsx
class MusicRecommendNotifier extends StateNotifier<MusicRecommendState> {
  MusicRecommendNotifier(this._dataSource) : super(const MusicRecommendState()) {
    load();
  }

  final MusicRecommendRemoteDataSource _dataSource;

  /// Load initial page of music recommendations.
  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentPage: 1,
    );

    try {
      final songs = await _dataSource.getMusicRecommend();
      state = state.copyWith(
        songs: songs,
        isLoading: false,
        currentPage: 1,
        hasMore: songs.length >= MusicRecommendRemoteDataSource.defaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more music recommendations (next page).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final newSongs = await _dataSource.getMusicRecommend(pn: nextPage);

      // Deduplicate songs based on id
      final existingIds = state.songs.map((s) => s.id).toSet();
      final uniqueNewSongs =
          newSongs.where((s) => !existingIds.contains(s.id)).toList();

      state = state.copyWith(
        songs: [...state.songs, ...uniqueNewSongs],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore:
            newSongs.length >= MusicRecommendRemoteDataSource.defaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh music recommendations (reset to first page).
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final songs = await _dataSource.getMusicRecommend();
      state = state.copyWith(
        songs: songs,
        isRefreshing: false,
        currentPage: 1,
        hasMore: songs.length >= MusicRecommendRemoteDataSource.defaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }
}

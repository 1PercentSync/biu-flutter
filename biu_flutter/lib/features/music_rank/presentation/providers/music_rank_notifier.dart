import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/music_rank_remote_datasource.dart';
import 'music_rank_state.dart';

/// Provider for music rank datasource.
final musicRankDataSourceProvider = Provider<MusicRankRemoteDataSource>((ref) {
  return MusicRankRemoteDataSource();
});

/// Provider for music rank state.
final musicRankProvider =
    StateNotifierProvider<MusicRankNotifier, MusicRankState>((ref) {
  final dataSource = ref.watch(musicRankDataSourceProvider);
  return MusicRankNotifier(dataSource);
});

/// Notifier for music rank screen.
class MusicRankNotifier extends StateNotifier<MusicRankState> {
  MusicRankNotifier(this._dataSource) : super(const MusicRankState()) {
    load();
  }

  final MusicRankRemoteDataSource _dataSource;

  /// Load music hot rank.
  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final songs = await _dataSource.getMusicHotRank();
      state = state.copyWith(
        songs: songs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh music hot rank.
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final songs = await _dataSource.getMusicHotRank();
      state = state.copyWith(
        songs: songs,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }
}

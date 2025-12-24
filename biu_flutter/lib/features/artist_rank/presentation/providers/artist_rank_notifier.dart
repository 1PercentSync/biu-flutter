import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/artist_rank_remote_datasource.dart';
import 'artist_rank_state.dart';

/// Provider for artist rank datasource
final artistRankDataSourceProvider = Provider<ArtistRankRemoteDataSource>((ref) {
  return ArtistRankRemoteDataSource();
});

/// Provider for artist rank state
final artistRankProvider =
    StateNotifierProvider<ArtistRankNotifier, ArtistRankState>((ref) {
  final dataSource = ref.watch(artistRankDataSourceProvider);
  return ArtistRankNotifier(dataSource);
});

/// Notifier for artist rank screen
class ArtistRankNotifier extends StateNotifier<ArtistRankState> {
  ArtistRankNotifier(this._dataSource) : super(const ArtistRankState());

  final ArtistRankRemoteDataSource _dataSource;

  /// Load musicians
  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final musicians = await _dataSource.getAllMusicians();
      state = state.copyWith(
        musicians: musicians,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh musicians
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
    );

    try {
      final musicians = await _dataSource.getAllMusicians();
      state = state.copyWith(
        musicians: musicians,
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/history_remote_datasource.dart';
import 'history_state.dart';

/// Provider for history datasource
final historyDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) {
  return HistoryRemoteDataSource();
});

/// Provider for history state
final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final dataSource = ref.watch(historyDataSourceProvider);
  return HistoryNotifier(dataSource);
});

/// Notifier for history screen
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._dataSource) : super(const HistoryState());

  final HistoryRemoteDataSource _dataSource;

  /// Load initial history list
  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isNotLoggedIn: false,
    );

    try {
      final response = await _dataSource.getHistoryCursor(
        
      );

      state = state.copyWith(
        items: response.list,
        cursor: response.cursor,
        hasMore: response.hasMore,
        isLoading: false,
      );
    } on HistoryNotLoggedInException {
      state = state.copyWith(
        isLoading: false,
        isNotLoggedIn: true,
        errorMessage: 'Please login to view history',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more history items
  Future<void> loadMore() async {
    if (!state.canLoadMore || state.cursor == null) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final cursor = state.cursor!;
      final response = await _dataSource.getHistoryCursor(
        max: cursor.max,
        business: cursor.business,
        viewAt: cursor.viewAt,
      );

      state = state.copyWith(
        items: [...state.items, ...response.list],
        cursor: response.cursor,
        hasMore: response.hasMore,
        isLoadingMore: false,
      );
    } on HistoryNotLoggedInException {
      state = state.copyWith(
        isLoadingMore: false,
        isNotLoggedIn: true,
        errorMessage: 'Please login to view history',
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh history list
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      clearCursor: true,
      isNotLoggedIn: false,
    );

    try {
      final response = await _dataSource.getHistoryCursor(
        
      );

      state = state.copyWith(
        items: response.list,
        cursor: response.cursor,
        hasMore: response.hasMore,
        isRefreshing: false,
      );
    } on HistoryNotLoggedInException {
      state = state.copyWith(
        isRefreshing: false,
        isNotLoggedIn: true,
        items: [],
        errorMessage: 'Please login to view history',
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear and reset state
  void reset() {
    state = const HistoryState();
  }
}

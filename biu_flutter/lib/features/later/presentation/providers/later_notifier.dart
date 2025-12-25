import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/later_remote_datasource.dart';
import '../../data/models/watch_later_item.dart';
import 'later_state.dart';

/// Provider for later datasource
final laterDataSourceProvider = Provider<LaterRemoteDataSource>((ref) {
  return LaterRemoteDataSource();
});

/// Provider for later state
final laterProvider = StateNotifierProvider<LaterNotifier, LaterState>((ref) {
  final dataSource = ref.watch(laterDataSourceProvider);
  return LaterNotifier(dataSource);
});

/// Notifier for watch later screen
class LaterNotifier extends StateNotifier<LaterState> {
  LaterNotifier(this._dataSource) : super(const LaterState());

  final LaterRemoteDataSource _dataSource;

  static const int _pageSize = 20;

  /// Load initial watch later list
  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isNotLoggedIn: false,
    );

    try {
      final response = await _dataSource.getWatchLaterList();

      final hasMore = response.list.length >= _pageSize &&
          response.list.length < response.count;

      state = state.copyWith(
        items: response.list,
        totalCount: response.count,
        currentPage: 1,
        hasMore: hasMore,
        isLoading: false,
      );
    } on LaterNotLoggedInException {
      state = state.copyWith(
        isLoading: false,
        isNotLoggedIn: true,
        errorMessage: 'Please login to view watch later',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more watch later items
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _dataSource.getWatchLaterList(
        pn: nextPage,
      );

      final newItems = [...state.items, ...response.list];
      final hasMore =
          response.list.length >= _pageSize && newItems.length < response.count;

      state = state.copyWith(
        items: newItems,
        currentPage: nextPage,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    } on LaterNotLoggedInException {
      state = state.copyWith(
        isLoadingMore: false,
        isNotLoggedIn: true,
        errorMessage: 'Please login to view watch later',
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh watch later list
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      isNotLoggedIn: false,
    );

    try {
      final response = await _dataSource.getWatchLaterList();

      final hasMore = response.list.length >= _pageSize &&
          response.list.length < response.count;

      state = state.copyWith(
        items: response.list,
        totalCount: response.count,
        currentPage: 1,
        hasMore: hasMore,
        isRefreshing: false,
      );
    } on LaterNotLoggedInException {
      state = state.copyWith(
        isRefreshing: false,
        isNotLoggedIn: true,
        items: [],
        errorMessage: 'Please login to view watch later',
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Remove item from watch later list
  Future<bool> removeItem(WatchLaterItem item) async {
    try {
      final success = await _dataSource.removeFromWatchLater(aid: item.aid);
      if (success) {
        // Remove item from local state
        final updatedItems =
            state.items.where((i) => i.aid != item.aid).toList();
        state = state.copyWith(
          items: updatedItems,
          totalCount: state.totalCount - 1,
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Add item to watch later list
  Future<bool> addItem({int? aid, String? bvid}) async {
    try {
      final success = await _dataSource.addToWatchLater(
        aid: aid,
        bvid: bvid,
      );
      if (success) {
        // Refresh to get updated list
        await refresh();
      }
      return success;
    } on LaterListFullException {
      state = state.copyWith(errorMessage: 'Watch later list is full');
      return false;
    } on LaterVideoNotExistException {
      state = state.copyWith(errorMessage: 'Video has been deleted');
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Clear all watched videos from watch later
  Future<bool> clearWatched() async {
    try {
      final success = await _dataSource.clearWatchedFromWatchLater();
      if (success) {
        await refresh();
      }
      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Clear and reset state
  void reset() {
    state = const LaterState();
  }
}

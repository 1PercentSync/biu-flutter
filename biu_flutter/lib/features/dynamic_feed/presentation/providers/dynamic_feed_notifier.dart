import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/dynamic_feed_remote_datasource.dart';
import 'dynamic_feed_state.dart';

/// Notifier for dynamic feed state management.
///
/// Handles loading, pagination, and refresh of dynamic feed.
/// Source: biu/src/components/dynamic-feed/index.tsx
class DynamicFeedNotifier extends StateNotifier<DynamicFeedState> {
  DynamicFeedNotifier() : super(const DynamicFeedState());

  final _datasource = DynamicFeedRemoteDataSource();

  /// Load initial data or more data
  Future<void> load({bool refresh = false}) async {
    // Prevent duplicate loading
    if (state.isLoading) return;

    // Don't load more if no more data
    if (!refresh && state.isInitialized && !state.hasMore) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final response = await _datasource.getDynamicFeedAll(
        offset: refresh ? null : state.offset,
      );

      if (!response.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          error: response.message,
        );
        return;
      }

      final data = response.data;
      if (data == null) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
        );
        return;
      }

      // Get all video items (matching source project behavior)
      final newItems = data.items;

      state = state.copyWith(
        items: refresh ? newItems : [...state.items, ...newItems],
        offset: data.offset,
        updateBaseline: data.updateBaseline ?? state.updateBaseline,
        hasMore: data.hasMore,
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: e.toString(),
      );
    }
  }

  /// Refresh the feed
  Future<void> refresh() => load(refresh: true);

  /// Load more items
  Future<void> loadMore() => load();

  /// Clear the state
  void clear() {
    state = const DynamicFeedState();
  }
}

/// Provider for dynamic feed state.
final dynamicFeedProvider =
    StateNotifierProvider<DynamicFeedNotifier, DynamicFeedState>((ref) {
  return DynamicFeedNotifier();
});

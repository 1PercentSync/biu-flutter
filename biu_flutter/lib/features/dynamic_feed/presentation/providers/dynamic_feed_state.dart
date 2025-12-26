import '../../../user_profile/data/models/dynamic_item.dart';

/// State for dynamic feed.
///
/// Source: biu/src/components/dynamic-feed/index.tsx
class DynamicFeedState {
  const DynamicFeedState({
    this.items = const [],
    this.offset,
    this.updateBaseline,
    this.hasMore = true,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  /// List of dynamic items
  final List<DynamicItem> items;

  /// Pagination offset for loading more
  final String? offset;

  /// Update baseline for checking new dynamics
  final String? updateBaseline;

  /// Whether there are more items to load
  final bool hasMore;

  /// Whether currently loading
  final bool isLoading;

  /// Whether initial load has completed
  final bool isInitialized;

  /// Error message if any
  final String? error;

  /// Check if list is empty after initialization
  bool get isEmpty => isInitialized && items.isEmpty && !isLoading;

  /// Check if there's an error
  bool get hasError => error != null;

  DynamicFeedState copyWith({
    List<DynamicItem>? items,
    String? offset,
    String? updateBaseline,
    bool? hasMore,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    bool clearError = false,
  }) {
    return DynamicFeedState(
      items: items ?? this.items,
      offset: offset ?? this.offset,
      updateBaseline: updateBaseline ?? this.updateBaseline,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

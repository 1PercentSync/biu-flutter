import '../../data/models/history_item.dart';

/// State for history screen
class HistoryState {
  const HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.cursor,
    this.errorMessage,
    this.isNotLoggedIn = false,
  });

  final List<HistoryItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;
  final HistoryCursorInfo? cursor;
  final String? errorMessage;
  final bool isNotLoggedIn;

  bool get hasError => errorMessage != null;
  bool get isEmpty => items.isEmpty && !isLoading && !isLoadingMore;
  bool get canLoadMore => hasMore && !isLoading && !isLoadingMore;

  HistoryState copyWith({
    List<HistoryItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
    HistoryCursorInfo? cursor,
    String? errorMessage,
    bool? isNotLoggedIn,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isNotLoggedIn: isNotLoggedIn ?? this.isNotLoggedIn,
    );
  }
}

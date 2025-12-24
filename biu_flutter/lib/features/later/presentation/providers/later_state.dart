import '../../data/models/watch_later_item.dart';

/// State for watch later screen
class LaterState {
  const LaterState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.totalCount = 0,
    this.errorMessage,
    this.isNotLoggedIn = false,
  });

  final List<WatchLaterItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;
  final bool isNotLoggedIn;

  bool get hasError => errorMessage != null;
  bool get isEmpty => items.isEmpty && !isLoading && !isLoadingMore;
  bool get canLoadMore => hasMore && !isLoading && !isLoadingMore;

  LaterState copyWith({
    List<WatchLaterItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
    bool? isNotLoggedIn,
    bool clearError = false,
  }) {
    return LaterState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isNotLoggedIn: isNotLoggedIn ?? this.isNotLoggedIn,
    );
  }
}

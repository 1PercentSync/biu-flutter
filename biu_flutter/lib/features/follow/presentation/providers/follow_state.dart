import '../../data/models/following_user.dart';

/// State for follow list screen
class FollowState {
  const FollowState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.totalCount = 0,
    this.errorMessage,
    this.isNotLoggedIn = false,
    this.isPrivate = false,
  });

  final List<FollowingUser> users;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;
  final bool isNotLoggedIn;
  final bool isPrivate;

  bool get hasError => errorMessage != null;
  bool get isEmpty => users.isEmpty && !isLoading && !isLoadingMore;
  bool get canLoadMore => hasMore && !isLoading && !isLoadingMore;

  FollowState copyWith({
    List<FollowingUser>? users,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
    bool? isNotLoggedIn,
    bool? isPrivate,
    bool clearError = false,
  }) {
    return FollowState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isNotLoggedIn: isNotLoggedIn ?? this.isNotLoggedIn,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}

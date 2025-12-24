import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/datasources/follow_remote_datasource.dart';
import '../../data/models/following_user.dart';
import 'follow_state.dart';

/// Provider for follow datasource
final followDataSourceProvider = Provider<FollowRemoteDataSource>((ref) {
  return FollowRemoteDataSource();
});

/// Provider for follow state
final followProvider = StateNotifierProvider<FollowNotifier, FollowState>((ref) {
  final dataSource = ref.watch(followDataSourceProvider);
  final authState = ref.watch(authNotifierProvider);
  return FollowNotifier(dataSource, authState.user?.mid);
});

/// Notifier for follow list screen
class FollowNotifier extends StateNotifier<FollowState> {
  FollowNotifier(this._dataSource, this._currentUserMid) : super(const FollowState());

  final FollowRemoteDataSource _dataSource;
  final int? _currentUserMid;

  static const int _pageSize = 20;

  /// Load initial followings list
  Future<void> load() async {
    if (state.isLoading) return;

    if (_currentUserMid == null) {
      state = state.copyWith(
        isLoading: false,
        isNotLoggedIn: true,
        errorMessage: 'Please login to view followings',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isNotLoggedIn: false,
      isPrivate: false,
    );

    try {
      final response = await _dataSource.getFollowings(
        vmid: _currentUserMid!,
        pn: 1,
        ps: _pageSize,
      );

      final hasMore = response.list.length >= _pageSize &&
          response.list.length < response.total;

      state = state.copyWith(
        users: response.list,
        totalCount: response.total,
        currentPage: 1,
        hasMore: hasMore,
        isLoading: false,
      );
    } on FollowNotLoggedInException {
      state = state.copyWith(
        isLoading: false,
        isNotLoggedIn: true,
        errorMessage: 'Please login to view followings',
      );
    } on FollowPrivacyException {
      state = state.copyWith(
        isLoading: false,
        isPrivate: true,
        errorMessage: 'User has enabled privacy settings',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more followings
  Future<void> loadMore() async {
    if (!state.canLoadMore || _currentUserMid == null) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _dataSource.getFollowings(
        vmid: _currentUserMid!,
        pn: nextPage,
        ps: _pageSize,
      );

      final newUsers = [...state.users, ...response.list];
      final hasMore =
          response.list.length >= _pageSize && newUsers.length < response.total;

      state = state.copyWith(
        users: newUsers,
        currentPage: nextPage,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    } on FollowNotLoggedInException {
      state = state.copyWith(
        isLoadingMore: false,
        isNotLoggedIn: true,
        errorMessage: 'Please login to view followings',
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh followings list
  Future<void> refresh() async {
    if (state.isRefreshing || _currentUserMid == null) return;

    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      isNotLoggedIn: false,
      isPrivate: false,
    );

    try {
      final response = await _dataSource.getFollowings(
        vmid: _currentUserMid!,
        pn: 1,
        ps: _pageSize,
      );

      final hasMore = response.list.length >= _pageSize &&
          response.list.length < response.total;

      state = state.copyWith(
        users: response.list,
        totalCount: response.total,
        currentPage: 1,
        hasMore: hasMore,
        isRefreshing: false,
      );
    } on FollowNotLoggedInException {
      state = state.copyWith(
        isRefreshing: false,
        isNotLoggedIn: true,
        users: [],
        errorMessage: 'Please login to view followings',
      );
    } on FollowPrivacyException {
      state = state.copyWith(
        isRefreshing: false,
        isPrivate: true,
        errorMessage: 'User has enabled privacy settings',
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Unfollow a user
  Future<bool> unfollowUser(FollowingUser user) async {
    try {
      final success = await _dataSource.unfollowUser(user.mid);
      if (success) {
        // Remove user from local state
        final updatedUsers =
            state.users.where((u) => u.mid != user.mid).toList();
        state = state.copyWith(
          users: updatedUsers,
          totalCount: state.totalCount - 1,
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Follow a user
  Future<bool> followUser(int mid) async {
    try {
      final success = await _dataSource.followUser(mid);
      if (success) {
        // Refresh to get updated list
        await refresh();
      }
      return success;
    } on FollowLimitException {
      state = state.copyWith(errorMessage: 'Follow limit reached (max 2000)');
      return false;
    } on FollowSelfException {
      state = state.copyWith(errorMessage: 'Cannot follow yourself');
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Clear and reset state
  void reset() {
    state = const FollowState();
  }
}

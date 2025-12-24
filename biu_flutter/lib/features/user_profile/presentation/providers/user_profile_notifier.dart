import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/auth.dart';
import '../../../follow/data/datasources/follow_remote_datasource.dart';
import '../../data/datasources/user_profile_remote_datasource.dart';
import '../../data/models/space_relation.dart';
import 'user_profile_state.dart';

/// Provider for user profile data source
final userProfileDataSourceProvider = Provider<UserProfileRemoteDataSource>(
  (ref) => UserProfileRemoteDataSource(),
);

/// Provider for user profile notifier with mid parameter
final userProfileProvider =
    StateNotifierProvider.family<UserProfileNotifier, UserProfileState, int>(
  (ref, mid) => UserProfileNotifier(
    ref.watch(userProfileDataSourceProvider),
    ref.watch(followDataSourceProvider),
    ref.watch(authNotifierProvider.select((s) => s.isAuthenticated)),
    mid,
  ),
);

/// Provider for follow data source
final followDataSourceProvider = Provider<FollowRemoteDataSource>(
  (ref) => FollowRemoteDataSource(),
);

/// Notifier for user profile state
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier(
    this._dataSource,
    this._followDataSource,
    this._isLoggedIn,
    this._mid,
  ) : super(UserProfileState(mid: _mid)) {
    _init();
  }

  final UserProfileRemoteDataSource _dataSource;
  final FollowRemoteDataSource _followDataSource;
  final bool _isLoggedIn;
  final int _mid;

  /// Initialize profile data
  Future<void> _init() async {
    await loadProfile();
    await loadVideos();
  }

  /// Load user profile info
  Future<void> loadProfile() async {
    state = state.copyWith(isLoadingInfo: true, clearError: true);

    try {
      // Load space info
      final spaceInfo = await _dataSource.getSpaceAccInfo(mid: _mid);

      // Load relation stat
      final relationStat = await _dataSource.getRelationStat(vmid: _mid);

      // Load relation data if logged in
      SpaceRelationData? relationData;
      if (_isLoggedIn) {
        try {
          relationData = await _dataSource.getSpaceRelation(mid: _mid);
        } catch (e) {
          // Ignore relation errors, may not be logged in
        }
      }

      state = state.copyWith(
        spaceInfo: spaceInfo,
        relationStat: relationStat,
        relationData: relationData,
        isLoadingInfo: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingInfo: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load user videos
  Future<void> loadVideos({bool refresh = true}) async {
    if (refresh) {
      state = state.copyWith(isLoadingVideos: true, clearError: true);
    }

    try {
      final data = await _dataSource.getSpaceVideos(
        mid: _mid,
        pn: 1,
        keyword: state.videoKeyword.isNotEmpty ? state.videoKeyword : null,
        order: state.videoOrder,
      );

      state = state.copyWith(
        videos: data.list.vlist,
        videoPage: data.page,
        isLoadingVideos: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingVideos: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more videos
  Future<void> loadMoreVideos() async {
    if (state.isLoadingMore || !state.hasMoreVideos) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = (state.videoPage?.pn ?? 0) + 1;
      final data = await _dataSource.getSpaceVideos(
        mid: _mid,
        pn: nextPage,
        keyword: state.videoKeyword.isNotEmpty ? state.videoKeyword : null,
        order: state.videoOrder,
      );

      final currentVideos = state.videos ?? [];
      state = state.copyWith(
        videos: [...currentVideos, ...data.list.vlist],
        videoPage: data.page,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Set video search keyword
  void setVideoKeyword(String keyword) {
    if (state.videoKeyword != keyword) {
      state = state.copyWith(videoKeyword: keyword);
      loadVideos();
    }
  }

  /// Set video sort order
  void setVideoOrder(String order) {
    if (state.videoOrder != order) {
      state = state.copyWith(videoOrder: order);
      loadVideos();
    }
  }

  /// Toggle follow status
  Future<bool> toggleFollow() async {
    if (!_isLoggedIn) return false;

    try {
      if (state.isFollowing) {
        await _followDataSource.unfollowUser(_mid);
      } else {
        await _followDataSource.followUser(_mid);
      }

      // Refresh relation data
      final relationData = await _dataSource.getSpaceRelation(mid: _mid);
      final relationStat = await _dataSource.getRelationStat(vmid: _mid);

      state = state.copyWith(
        relationData: relationData,
        relationStat: relationStat,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadProfile();
    await loadVideos();
  }
}

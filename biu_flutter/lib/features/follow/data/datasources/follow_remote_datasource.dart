import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/following_user.dart';

/// Response from followings API
class FollowingsResponse {
  const FollowingsResponse({
    required this.total,
    required this.list,
  });

  factory FollowingsResponse.fromJson(Map<String, dynamic> json) {
    final listData = json['list'] as List<dynamic>?;

    return FollowingsResponse(
      total: json['total'] as int? ?? 0,
      list: listData
              ?.map((e) => FollowingUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final int total;
  final List<FollowingUser> list;
}

/// User relation action types
enum UserRelationAction {
  /// Follow a user
  follow(1),

  /// Unfollow a user
  unfollow(2),

  /// Block a user
  block(5),

  /// Unblock a user
  unblock(6),

  /// Remove from fans
  removeFan(7);

  const UserRelationAction(this.value);
  final int value;
}

/// Remote data source for follow/relation API calls
///
/// Source: biu/src/service/relation-followings.ts#getRelationFollowings
/// Source: biu/src/service/relation-modify.ts#postRelationModify
class FollowRemoteDataSource {
  FollowRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Default page size for followings list
  static const int defaultPageSize = 20;

  /// Get user's followings list
  /// GET /x/relation/followings
  ///
  /// [vmid] - Target user mid (required)
  /// [orderType] - Sort type: '' (by follow time), 'attention' (by most visited)
  /// [pn] - Page number, default 1 (other users can only view first 100)
  /// [ps] - Page size, default 50
  Future<FollowingsResponse> getFollowings({
    required int vmid,
    String orderType = '',
    int pn = 1,
    int ps = defaultPageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/relation/followings',
      queryParameters: {
        'vmid': vmid,
        if (orderType.isNotEmpty) 'order_type': orderType,
        'pn': pn,
        'ps': ps,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch followings');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';

      // Handle specific error codes
      switch (code) {
        case -101:
          throw FollowNotLoggedInException();
        case -352:
          throw FollowRequestBlockedException();
        case -400:
          throw Exception('Request error');
        case 22115:
          throw FollowPrivacyException();
        default:
          throw Exception('API error: $message (code: $code)');
      }
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      return const FollowingsResponse(total: 0, list: []);
    }

    return FollowingsResponse.fromJson(responseData);
  }

  /// Modify user relation (follow/unfollow/block)
  /// POST /x/relation/modify
  ///
  /// [fid] - Target user mid (required)
  /// [act] - Action code (required)
  /// [reSrc] - Follow source code (optional)
  Future<bool> modifyRelation({
    required int fid,
    required UserRelationAction action,
    int? reSrc,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/x/relation/modify',
      data: {
        'fid': fid,
        'act': action.value,
        if (reSrc != null) 're_src': reSrc,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to modify relation');
    }

    final code = data['code'] as int?;
    if (code == 0) {
      return true;
    }

    final message = data['message'] as String? ?? 'Unknown error';

    // Handle specific error codes
    switch (code) {
      case -101:
        throw FollowNotLoggedInException();
      case -111:
        throw Exception('CSRF verification failed');
      case -400:
        throw Exception('Request error');
      case 22001:
        throw FollowSelfException();
      case 22002:
        throw FollowLimitException();
      case 22003:
        throw FollowNotAllowedException();
      case 22013:
        throw FollowAccountAbnormalException();
      case 22014:
        throw Exception('Already blocked, cannot follow');
      default:
        throw Exception('API error: $message (code: $code)');
    }
  }

  /// Follow a user
  Future<bool> followUser(int mid) async {
    return modifyRelation(fid: mid, action: UserRelationAction.follow);
  }

  /// Unfollow a user
  Future<bool> unfollowUser(int mid) async {
    return modifyRelation(fid: mid, action: UserRelationAction.unfollow);
  }
}

/// Exception thrown when user is not logged in
class FollowNotLoggedInException implements Exception {
  @override
  String toString() => 'Not logged in';
}

/// Exception thrown when request is blocked
class FollowRequestBlockedException implements Exception {
  @override
  String toString() => 'Request blocked';
}

/// Exception thrown when user has privacy settings
class FollowPrivacyException implements Exception {
  @override
  String toString() => 'User has enabled privacy settings';
}

/// Exception thrown when trying to follow self
class FollowSelfException implements Exception {
  @override
  String toString() => 'Cannot follow yourself';
}

/// Exception thrown when follow limit reached
class FollowLimitException implements Exception {
  @override
  String toString() => 'Follow limit reached (max 2000)';
}

/// Exception thrown when follow is not allowed
class FollowNotAllowedException implements Exception {
  @override
  String toString() => 'Follow not allowed';
}

/// Exception thrown when account is abnormal
class FollowAccountAbnormalException implements Exception {
  @override
  String toString() => 'Account status abnormal';
}

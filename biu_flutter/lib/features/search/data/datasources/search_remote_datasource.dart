import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/search_result.dart';

/// Search order types for video search
enum SearchVideoOrder {
  totalRank('totalrank', 'Comprehensive'),
  click('click', 'Most Played'),
  pubdate('pubdate', 'Latest'),
  dm('dm', 'Most Danmaku'),
  stow('stow', 'Most Favorited'),
  scores('scores', 'Most Reviewed');

  const SearchVideoOrder(this.value, this.label);
  final String value;
  final String label;
}

/// Duration filter for video search
enum SearchVideoDuration {
  all(0, 'All'),
  lessThan10(1, '<10 min'),
  between10And30(2, '10-30 min'),
  between30And60(3, '30-60 min'),
  moreThan60(4, '>60 min');

  const SearchVideoDuration(this.value, this.label);
  final int value;
  final String label;
}

/// Remote data source for search-related API calls
///
/// Source: biu/src/service/main-suggest.ts#getMainSuggest (search suggestions)
/// Source: biu/src/service/web-interface-search-all.ts#getSearchAll
/// Source: biu/src/service/web-interface-search-type.ts#getSearchType
class SearchRemoteDataSource {
  SearchRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Comprehensive search
  /// GET /x/web-interface/wbi/search/all/v2
  Future<SearchAllResult> searchAll({
    required String keyword,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/web-interface/wbi/search/all/v2',
      queryParameters: {
        'keyword': keyword,
      },
      options: Options(extra: {'useWbi': true}),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to search');
    }

    final searchData = data['data'] as Map<String, dynamic>?;
    if (searchData == null) {
      throw Exception('Search data is null');
    }

    return SearchAllResult.fromJson(searchData);
  }

  /// Search by type - Video
  /// GET /x/web-interface/wbi/search/type
  Future<SearchTypeResult<SearchVideoItem>> searchVideo({
    required String keyword,
    int page = 1,
    int pageSize = 24,
    SearchVideoOrder order = SearchVideoOrder.totalRank,
    SearchVideoDuration duration = SearchVideoDuration.all,
    int tids = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/web-interface/wbi/search/type',
      queryParameters: {
        'keyword': keyword,
        'search_type': 'video',
        'page': page,
        'page_size': pageSize,
        'order': order.value,
        'duration': duration.value,
        'tids': tids,
      },
      options: Options(extra: {'useWbi': true}),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to search videos');
    }

    final searchData = data['data'] as Map<String, dynamic>?;
    if (searchData == null) {
      throw Exception('Search data is null');
    }

    final result = (searchData['result'] as List<dynamic>?)
            ?.map((e) => SearchVideoItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return SearchTypeResult<SearchVideoItem>(
      seid: searchData['seid']?.toString() ?? '',
      page: searchData['page'] as int? ?? page,
      pageSize: searchData['pagesize'] as int? ?? pageSize,
      numResults: searchData['numResults'] as int? ?? 0,
      numPages: searchData['numPages'] as int? ?? 0,
      result: result,
    );
  }

  /// Search by type - User
  /// GET /x/web-interface/wbi/search/type
  Future<SearchTypeResult<SearchUserItem>> searchUser({
    required String keyword,
    int page = 1,
    int pageSize = 24,
    String order = '0',
    int orderSort = 0,
    int userType = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/web-interface/wbi/search/type',
      queryParameters: {
        'keyword': keyword,
        'search_type': 'bili_user',
        'page': page,
        'page_size': pageSize,
        'order': order,
        'order_sort': orderSort,
        'user_type': userType,
      },
      options: Options(extra: {'useWbi': true}),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to search users');
    }

    final searchData = data['data'] as Map<String, dynamic>?;
    if (searchData == null) {
      throw Exception('Search data is null');
    }

    final result = (searchData['result'] as List<dynamic>?)
            ?.map((e) => SearchUserItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return SearchTypeResult<SearchUserItem>(
      seid: searchData['seid']?.toString() ?? '',
      page: searchData['page'] as int? ?? page,
      pageSize: searchData['pagesize'] as int? ?? pageSize,
      numResults: searchData['numResults'] as int? ?? 0,
      numPages: searchData['numPages'] as int? ?? 0,
      result: result,
    );
  }

  /// Get search suggestions
  /// GET /x/web-interface/search/suggest
  Future<List<String>> getSearchSuggestions({
    required String keyword,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/web-interface/search/suggest',
      queryParameters: {
        'term': keyword,
        'main_ver': 'v1',
        'highlight': '',
      },
    );

    final data = response.data;
    if (data == null) {
      return [];
    }

    final result = data['result'] as Map<String, dynamic>?;
    if (result == null) return [];

    final tag = result['tag'] as List<dynamic>?;
    if (tag == null) return [];

    return tag
        .map((e) => (e as Map<String, dynamic>)['value'] as String?)
        .where((e) => e != null)
        .cast<String>()
        .toList();
  }

  /// Get hot search keywords
  /// GET /x/web-interface/search/square
  Future<List<String>> getHotSearchKeywords() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/web-interface/wbi/search/square',
      queryParameters: {
        'limit': 10,
        'platform': 'web',
      },
      options: Options(extra: {'useWbi': true}),
    );

    final data = response.data;
    if (data == null) {
      return [];
    }

    final dataObj = data['data'] as Map<String, dynamic>?;
    final trendingObj = dataObj?['trending'] as Map<String, dynamic>?;
    final trending = trendingObj?['list'] as List<dynamic>?;
    if (trending == null) return [];

    return trending
        .map((e) => (e as Map<String, dynamic>)['keyword'] as String?)
        .where((e) => e != null)
        .cast<String>()
        .toList();
  }
}

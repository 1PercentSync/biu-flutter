import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/search_result.dart';
import '../models/search_suggest.dart';

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
/// Source: biu/src/service/web-interface-search-type.ts#getSearchType
class SearchRemoteDataSource {
  SearchRemoteDataSource({Dio? dio, Dio? searchDio})
      : _dio = dio ?? DioClient.instance.dio,
        _searchDio = searchDio ?? DioClient.instance.searchDio;

  final Dio _dio;
  final Dio _searchDio;

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

  /// Get search suggestions from search.bilibili.com
  /// GET https://s.search.bilibili.com/main/suggest
  ///
  /// Source: biu/src/service/main-suggest.ts#getSearchSuggestMain
  Future<List<SearchSuggestItem>> getSearchSuggestions({
    required String keyword,
    int? userId,
  }) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    developer.log('Calling search suggest API for: $keyword', name: 'SearchDataSource');

    // Source: biu/src/layout/navbar/search/index.tsx:38
    // Only term and userid are passed in source project
    final response = await _searchDio.get<Map<String, dynamic>>(
      '/main/suggest',
      queryParameters: {
        'term': keyword,
        if (userId != null) 'userid': userId,
      },
    );

    developer.log('Response: ${response.data}', name: 'SearchDataSource');

    final data = response.data;
    if (data == null) {
      developer.log('Response data is null', name: 'SearchDataSource');
      return [];
    }

    final result = data['result'] as Map<String, dynamic>?;
    if (result == null) {
      developer.log('result field is null, keys: ${data.keys}', name: 'SearchDataSource');
      return [];
    }

    final tag = result['tag'] as List<dynamic>?;
    if (tag == null) {
      developer.log('tag field is null, result keys: ${result.keys}', name: 'SearchDataSource');
      return [];
    }

    developer.log('Found ${tag.length} suggestions', name: 'SearchDataSource');
    return tag
        .map((e) => SearchSuggestItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Hot search keywords feature removed - not in source project.
  // Source project (biu/Electron) does not have hot search/trending feature.
  // See: openspec/changes/align-parity-report-decisions/specs/search/spec.md
}

import '../../../../core/network/api/base_api_service.dart';
import '../models/folder_response.dart';
import '../models/resource_response.dart';

/// Remote data source for favorites API.
///
/// Consolidates multiple source services into Clean Architecture DataSource pattern.
/// Source: biu/src/service/fav-*.ts (multiple files consolidated)
class FavoritesRemoteDataSource extends BaseApiService {
  FavoritesRemoteDataSource() : super();

  /// Get folders created by a user.
  /// Source: biu/src/service/fav-folder-created-list.ts#getFavFolderCreatedList
  Future<CreatedFolderListResponse> getCreatedFolders({
    required int upMid,
    int pageSize = 20,
    int pageNum = 1,
  }) async {
    final data = await get<Map<String, dynamic>>(
      '/x/v3/fav/folder/created/list',
      queryParameters: {
        'up_mid': upMid,
        'ps': pageSize,
        'pn': pageNum,
      },
      options: const BiliRequestOptions(useWbi: true),
    );

    final responseData = data['data'];
    if (responseData == null) {
      return const CreatedFolderListResponse(count: 0, list: [], hasMore: false);
    }

    return CreatedFolderListResponse.fromJson(responseData as Map<String, dynamic>);
  }

  /// Get folders collected by a user.
  /// Source: biu/src/service/fav-folder-collected-list.ts#getFavFolderCollectedList
  Future<CollectedFolderListResponse> getCollectedFolders({
    required int upMid,
    int pageSize = 20,
    int pageNum = 1,
  }) async {
    final data = await get<Map<String, dynamic>>(
      '/x/v3/fav/folder/collected/list',
      queryParameters: {
        'up_mid': upMid,
        'ps': pageSize,
        'pn': pageNum,
        'platform': 'web',
      },
    );

    final responseData = data['data'];
    if (responseData == null) {
      return const CollectedFolderListResponse(count: 0, list: [], hasMore: false);
    }

    return CollectedFolderListResponse.fromJson(responseData as Map<String, dynamic>);
  }

  /// Get all created folders (for resource selection).
  /// Source: biu/src/service/fav-folder-created-list-all.ts#getFavFolderCreatedListAll
  Future<AllCreatedFolderListResponse> getAllCreatedFolders({
    required int upMid,
    int? resourceId,
    int resourceType = 2,
  }) async {
    final queryParams = <String, dynamic>{
      'up_mid': upMid,
      'type': resourceType,
    };
    if (resourceId != null) {
      queryParams['rid'] = resourceId;
    }

    final data = await get<Map<String, dynamic>>(
      '/x/v3/fav/folder/created/list-all',
      queryParameters: queryParams,
    );

    final responseData = data['data'];
    if (responseData == null) {
      return const AllCreatedFolderListResponse(count: 0, list: []);
    }

    return AllCreatedFolderListResponse.fromJson(responseData as Map<String, dynamic>);
  }

  /// Get folder info.
  /// Source: biu/src/service/fav-folder-info.ts#getFavFolderInfo
  Future<FolderDetailModel?> getFolderInfo(int mediaId) async {
    final data = await get<Map<String, dynamic>>(
      '/x/v3/fav/folder/info',
      queryParameters: {
        'media_id': mediaId,
      },
    );

    final responseData = data['data'];
    if (responseData == null) {
      return null;
    }

    return FolderDetailModel.fromJson(responseData as Map<String, dynamic>);
  }

  /// Get resources in a folder.
  /// Source: biu/src/service/fav-resource.ts#getFavResource
  Future<FolderResourceListResponse> getFolderResources({
    required String mediaId,
    int pageSize = 20,
    int pageNum = 1,
    String order = 'mtime',
    String keyword = '',
  }) async {
    final queryParameters = <String, dynamic>{
      'media_id': mediaId,
      'ps': pageSize,
      'pn': pageNum,
      'order': order,
      'platform': 'web',
    };

    if (keyword.isNotEmpty) {
      queryParameters['keyword'] = keyword;
    }

    final data = await get<Map<String, dynamic>>(
      '/x/v3/fav/resource/list',
      queryParameters: queryParameters,
    );

    final responseData = data['data'];
    if (responseData == null) {
      throw Exception('Failed to get folder resources');
    }

    return FolderResourceListResponse.fromJson(responseData as Map<String, dynamic>);
  }

  /// Create a new folder.
  /// Source: biu/src/service/fav-folder-add.ts#postFavFolderAdd
  Future<FolderDetailModel> createFolder({
    required String title,
    String intro = '',
    bool isPublic = true,
  }) async {
    final data = await post<Map<String, dynamic>>(
      '/x/v3/fav/folder/add',
      data: {
        'title': title,
        'intro': intro,
        'privacy': isPublic ? 0 : 1,
      },
      options: const BiliRequestOptions(useCSRF: true),
    );

    final responseData = data['data'];
    if (responseData == null) {
      throw Exception('Failed to create folder');
    }

    return FolderDetailModel.fromJson(responseData as Map<String, dynamic>);
  }

  /// Edit an existing folder.
  /// Source: biu/src/service/fav-folder-edit.ts#postFavFolderEdit
  Future<FolderDetailModel> editFolder({
    required int mediaId,
    required String title,
    String intro = '',
    bool isPublic = true,
  }) async {
    final data = await post<Map<String, dynamic>>(
      '/x/v3/fav/folder/edit',
      data: {
        'media_id': mediaId,
        'title': title,
        'intro': intro,
        'privacy': isPublic ? 0 : 1,
      },
      options: const BiliRequestOptions(useCSRF: true),
    );

    final responseData = data['data'];
    if (responseData == null) {
      throw Exception('Failed to edit folder');
    }

    return FolderDetailModel.fromJson(responseData as Map<String, dynamic>);
  }

  /// Delete folders.
  /// Source: biu/src/service/fav-folder-del.ts#postFavFolderDel
  Future<void> deleteFolders(List<int> mediaIds) async {
    await post<Map<String, dynamic>>(
      '/x/v3/fav/folder/del',
      data: {
        'media_ids': mediaIds.join(','),
      },
      options: const BiliRequestOptions(useCSRF: true),
    );
  }

  /// Add/remove resource from folders.
  /// Source: biu/src/service/fav-folder-deal.ts#postFavFolderDeal
  Future<void> dealResource({
    required String resourceId,
    String addMediaIds = '',
    String delMediaIds = '',
    int resourceType = 2,
  }) async {
    await post<Map<String, dynamic>>(
      '/x/v3/fav/resource/deal',
      data: {
        'rid': resourceId,
        'add_media_ids': addMediaIds,
        'del_media_ids': delMediaIds,
        'type': resourceType,
        'platform': 'web',
        'ga': 1,
        'gaia_source': 'web_normal',
      },
      options: const BiliRequestOptions(useCSRF: true),
    );
  }

  /// Collect (subscribe to) a folder.
  /// Source: biu/src/service/fav-folder-fav.ts#postFavFolderFav
  Future<void> collectFolder(int mediaId) async {
    await post<Map<String, dynamic>>(
      '/x/v3/fav/folder/fav',
      data: {
        'media_id': mediaId,
        'platform': 'web',
      },
      options: const BiliRequestOptions(useCSRF: true),
    );
  }

  /// Uncollect (unsubscribe from) a folder.
  /// Source: biu/src/service/fav-folder-unfav.ts#postFavFolderUnfav
  Future<void> uncollectFolder(int mediaId) async {
    await post<Map<String, dynamic>>(
      '/x/v3/fav/folder/unfav',
      data: {
        'media_id': mediaId,
        'platform': 'web',
      },
      options: const BiliRequestOptions(useCSRF: true),
    );
  }

  /// Batch delete resources from a folder.
  /// Source: biu/src/service/fav-resource-batch-del.ts#postFavResourceBatchDel
  ///
  /// [resources] is a comma-separated string of "id:type" pairs, e.g., "123:2,456:2"
  /// Types: 2=video, 12=audio, 21=video collection
  Future<void> batchDeleteResources({
    required int mediaId,
    required String resources,
  }) async {
    await post<Map<String, dynamic>>(
      '/x/v3/fav/resource/batch-del',
      data: {
        'media_id': mediaId,
        'resources': resources,
        'platform': 'web',
      },
      options: const BiliRequestOptions(useCSRF: true),
    );
  }

  /// Batch move resources from one folder to another.
  /// Source: biu/src/service/fav-resource-move.ts#postFavResourceMove
  ///
  /// [resources] is a comma-separated string of "id:type" pairs, e.g., "123:2,456:2"
  /// Types: 2=video, 12=audio, 21=video collection
  Future<void> batchMoveResources({
    required int srcMediaId,
    required int tarMediaId,
    required int mid,
    required String resources,
  }) async {
    await post<Map<String, dynamic>>(
      '/x/v3/fav/resource/move',
      data: {
        'src_media_id': srcMediaId,
        'tar_media_id': tarMediaId,
        'mid': mid,
        'resources': resources,
        'platform': 'web',
      },
      options: const BiliRequestOptions(useCSRF: true),
    );
  }

  /// Batch copy resources from one folder to another.
  /// Source: biu/src/service/fav-resource-copy.ts#postFavResourceCopy
  ///
  /// [resources] is a comma-separated string of "id:type" pairs, e.g., "123:2,456:2"
  /// Types: 2=video, 12=audio, 21=video collection
  Future<void> batchCopyResources({
    required int srcMediaId,
    required int tarMediaId,
    required int mid,
    required String resources,
  }) async {
    await post<Map<String, dynamic>>(
      '/x/v3/fav/resource/copy',
      data: {
        'src_media_id': srcMediaId,
        'tar_media_id': tarMediaId,
        'mid': mid,
        'resources': resources,
        'platform': 'web',
      },
      options: const BiliRequestOptions(useCSRF: true),
    );
  }

  /// Clean (remove) all invalid/deleted resources from a folder.
  /// Source: biu/src/service/fav-resource-clean.ts#postFavResourceClean
  Future<void> cleanInvalidResources(int mediaId) async {
    await post<Map<String, dynamic>>(
      '/x/v3/fav/resource/clean',
      data: {
        'media_id': mediaId,
      },
      options: const BiliRequestOptions(useCSRF: true),
    );
  }
}

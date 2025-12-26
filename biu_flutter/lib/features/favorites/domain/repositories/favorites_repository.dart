import '../entities/fav_media.dart';
import '../entities/favorites_folder.dart';

/// Repository interface for favorites operations.
abstract class FavoritesRepository {
  /// Get folders created by a user.
  Future<FolderListResult> getCreatedFolders({
    required int upMid,
    int pageSize = 20,
    int pageNum = 1,
  });

  /// Get folders collected by a user.
  Future<FolderListResult> getCollectedFolders({
    required int upMid,
    int pageSize = 20,
    int pageNum = 1,
  });

  /// Get all created folders (used for folder selection).
  Future<List<FavoritesFolder>> getAllCreatedFolders({
    required int upMid,
    int? resourceId,
    int resourceType = 2,
  });

  /// Get folder info by id.
  Future<FavoritesFolder?> getFolderInfo(int mediaId);

  /// Get resources in a folder.
  Future<FolderResourceResult> getFolderResources({
    required String mediaId,
    int pageSize = 20,
    int pageNum = 1,
    String order = 'mtime',
    String keyword = '',
  });

  /// Create a new folder.
  Future<FavoritesFolder> createFolder({
    required String title,
    String intro = '',
    bool isPublic = true,
  });

  /// Edit an existing folder.
  Future<FavoritesFolder> editFolder({
    required int mediaId,
    required String title,
    String intro = '',
    bool isPublic = true,
  });

  /// Delete folders.
  Future<void> deleteFolders(List<int> mediaIds);

  /// Add a resource to folders.
  Future<void> addResourceToFolders({
    required String resourceId,
    required List<int> addFolderIds,
    List<int> removeFolderIds = const [],
    int resourceType = 2,
  });

  /// Collect (subscribe to) a folder.
  Future<void> collectFolder(int mediaId);

  /// Uncollect (unsubscribe from) a folder.
  Future<void> uncollectFolder(int mediaId);

  /// Check if a resource is in user's folders.
  Future<List<int>> getResourceFavoriteStatus({
    required int resourceId,
    required int upMid,
    int resourceType = 2,
  });

  /// Batch delete resources from a folder.
  Future<void> batchDeleteResources({
    required int mediaId,
    required String resources,
  });

  /// Batch move resources from one folder to another.
  Future<void> batchMoveResources({
    required int srcMediaId,
    required int tarMediaId,
    required int mid,
    required String resources,
  });

  /// Batch copy resources from one folder to another.
  Future<void> batchCopyResources({
    required int srcMediaId,
    required int tarMediaId,
    required int mid,
    required String resources,
  });

  /// Clean (remove) all invalid/deleted resources from a folder.
  Future<void> cleanInvalidResources(int mediaId);

  /// Get all resources in a folder (all pages).
  /// Used for "Play All" which should play entire folder, not just search results.
  /// Source: biu/src/pages/video-collection/utils.ts#getAllFavMedia
  Future<List<FavMedia>> getAllFolderResources({
    required String mediaId,
    required int totalCount,
    String order = 'mtime',
  });
}

/// Result for folder list queries.
class FolderListResult {
  const FolderListResult({
    required this.folders,
    required this.total,
    required this.hasMore,
  });

  final List<FavoritesFolder> folders;
  final int total;
  final bool hasMore;
}

/// Result for folder resource queries.
class FolderResourceResult {
  const FolderResourceResult({
    required this.folder,
    required this.medias,
    required this.hasMore,
  });

  final FavoritesFolder folder;
  final List<FavMedia> medias;
  final bool hasMore;
}

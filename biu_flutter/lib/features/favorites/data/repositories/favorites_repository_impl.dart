import '../../domain/entities/favorites_folder.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

/// Implementation of [FavoritesRepository].
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({
    FavoritesRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? FavoritesRemoteDataSource();

  final FavoritesRemoteDataSource _remoteDataSource;

  @override
  Future<FolderListResult> getCreatedFolders({
    required int upMid,
    int pageSize = 20,
    int pageNum = 1,
  }) async {
    final response = await _remoteDataSource.getCreatedFolders(
      upMid: upMid,
      pageSize: pageSize,
      pageNum: pageNum,
    );

    return FolderListResult(
      folders: response.list.map((e) => e.toEntity()).toList(),
      total: response.count,
      hasMore: response.hasMore,
    );
  }

  @override
  Future<FolderListResult> getCollectedFolders({
    required int upMid,
    int pageSize = 20,
    int pageNum = 1,
  }) async {
    final response = await _remoteDataSource.getCollectedFolders(
      upMid: upMid,
      pageSize: pageSize,
      pageNum: pageNum,
    );

    return FolderListResult(
      folders: response.list.map((e) => e.toEntity()).toList(),
      total: response.count,
      hasMore: response.hasMore,
    );
  }

  @override
  Future<List<FavoritesFolder>> getAllCreatedFolders({
    required int upMid,
    int? resourceId,
    int resourceType = 2,
  }) async {
    final response = await _remoteDataSource.getAllCreatedFolders(
      upMid: upMid,
      resourceId: resourceId,
      resourceType: resourceType,
    );

    return response.list.map((e) => FavoritesFolder(
      id: e.id,
      fid: e.fid,
      mid: e.mid,
      attr: e.attr,
      title: e.title,
      cover: '',
      upper: FolderUpper(mid: e.mid, name: ''),
      mediaCount: e.mediaCount,
      ctime: 0,
      mtime: 0,
      favState: e.favState,
    )).toList();
  }

  @override
  Future<FavoritesFolder?> getFolderInfo(int mediaId) async {
    final response = await _remoteDataSource.getFolderInfo(mediaId);
    return response?.toEntity();
  }

  @override
  Future<FolderResourceResult> getFolderResources({
    required String mediaId,
    int pageSize = 20,
    int pageNum = 1,
    String order = 'mtime',
  }) async {
    final response = await _remoteDataSource.getFolderResources(
      mediaId: mediaId,
      pageSize: pageSize,
      pageNum: pageNum,
      order: order,
    );

    return FolderResourceResult(
      folder: response.info.toEntity(),
      medias: response.medias.map((e) => e.toEntity()).toList(),
      hasMore: response.hasMore,
    );
  }

  @override
  Future<FavoritesFolder> createFolder({
    required String title,
    String intro = '',
    bool isPublic = true,
  }) async {
    final response = await _remoteDataSource.createFolder(
      title: title,
      intro: intro,
      isPublic: isPublic,
    );
    return response.toEntity();
  }

  @override
  Future<FavoritesFolder> editFolder({
    required int mediaId,
    required String title,
    String intro = '',
    bool isPublic = true,
  }) async {
    final response = await _remoteDataSource.editFolder(
      mediaId: mediaId,
      title: title,
      intro: intro,
      isPublic: isPublic,
    );
    return response.toEntity();
  }

  @override
  Future<void> deleteFolders(List<int> mediaIds) async {
    await _remoteDataSource.deleteFolders(mediaIds);
  }

  @override
  Future<void> addResourceToFolders({
    required String resourceId,
    required List<int> addFolderIds,
    List<int> removeFolderIds = const [],
    int resourceType = 2,
  }) async {
    await _remoteDataSource.dealResource(
      resourceId: resourceId,
      addMediaIds: addFolderIds.join(','),
      delMediaIds: removeFolderIds.join(','),
      resourceType: resourceType,
    );
  }

  @override
  Future<void> collectFolder(int mediaId) async {
    await _remoteDataSource.collectFolder(mediaId);
  }

  @override
  Future<void> uncollectFolder(int mediaId) async {
    await _remoteDataSource.uncollectFolder(mediaId);
  }

  @override
  Future<List<int>> getResourceFavoriteStatus({
    required int resourceId,
    required int upMid,
    int resourceType = 2,
  }) async {
    final response = await _remoteDataSource.getAllCreatedFolders(
      upMid: upMid,
      resourceId: resourceId,
      resourceType: resourceType,
    );

    return response.list
        .where((e) => e.isFavorited)
        .map((e) => e.id)
        .toList();
  }
}

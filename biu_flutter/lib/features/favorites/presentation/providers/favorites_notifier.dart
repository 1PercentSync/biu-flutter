import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/auth.dart';
import '../../domain/entities/fav_media.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import 'favorites_state.dart';

/// Provider for the favorites repository.
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl();
});

/// Provider for favorites list state.
final favoritesListProvider =
    StateNotifierProvider<FavoritesListNotifier, FavoritesListState>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return FavoritesListNotifier(repository, user?.mid);
});

/// Provider for folder detail state.
final folderDetailProvider = StateNotifierProvider.family<FolderDetailNotifier,
    FolderDetailState, int>((ref, folderId) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return FolderDetailNotifier(repository, folderId);
});

/// Provider for folder select state.
final folderSelectProvider = StateNotifierProvider.family<FolderSelectNotifier,
    FolderSelectState, String>((ref, resourceId) {
  final repository = ref.watch(favoritesRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return FolderSelectNotifier(repository, user?.mid, resourceId);
});

/// Notifier for managing favorites list.
class FavoritesListNotifier extends StateNotifier<FavoritesListState> {
  final FavoritesRepository _repository;
  final int? _userMid;

  FavoritesListNotifier(this._repository, this._userMid)
      : super(const FavoritesListState()) {
    if (_userMid != null) {
      loadCreatedFolders();
      loadCollectedFolders();
    }
  }

  /// Load created folders.
  Future<void> loadCreatedFolders({bool refresh = false}) async {
    if (_userMid == null) return;
    if (state.isLoadingCreated) return;

    state = state.copyWith(
      isLoadingCreated: true,
      createdPageNum: refresh ? 1 : state.createdPageNum,
      clearError: true,
    );

    try {
      final result = await _repository.getCreatedFolders(
        upMid: _userMid,
        pageNum: refresh ? 1 : state.createdPageNum,
      );

      state = state.copyWith(
        createdFolders: refresh
            ? result.folders
            : [...state.createdFolders, ...result.folders],
        createdTotal: result.total,
        createdHasMore: result.hasMore,
        createdPageNum: (refresh ? 1 : state.createdPageNum) + 1,
        isLoadingCreated: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCreated: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load collected folders.
  Future<void> loadCollectedFolders({bool refresh = false}) async {
    if (_userMid == null) return;
    if (state.isLoadingCollected) return;

    state = state.copyWith(
      isLoadingCollected: true,
      collectedPageNum: refresh ? 1 : state.collectedPageNum,
      clearError: true,
    );

    try {
      final result = await _repository.getCollectedFolders(
        upMid: _userMid,
        pageNum: refresh ? 1 : state.collectedPageNum,
      );

      state = state.copyWith(
        collectedFolders: refresh
            ? result.folders
            : [...state.collectedFolders, ...result.folders],
        collectedTotal: result.total,
        collectedHasMore: result.hasMore,
        collectedPageNum: (refresh ? 1 : state.collectedPageNum) + 1,
        isLoadingCollected: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCollected: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more created folders.
  Future<void> loadMoreCreatedFolders() async {
    if (!state.createdHasMore || state.isLoadingCreated) return;
    await loadCreatedFolders();
  }

  /// Load more collected folders.
  Future<void> loadMoreCollectedFolders() async {
    if (!state.collectedHasMore || state.isLoadingCollected) return;
    await loadCollectedFolders();
  }

  /// Refresh all folders.
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true);

    await Future.wait([
      loadCreatedFolders(refresh: true),
      loadCollectedFolders(refresh: true),
    ]);

    state = state.copyWith(isRefreshing: false);
  }

  /// Create a new folder.
  Future<bool> createFolder({
    required String title,
    String intro = '',
    bool isPublic = true,
  }) async {
    try {
      final folder = await _repository.createFolder(
        title: title,
        intro: intro,
        isPublic: isPublic,
      );

      // Add to beginning of list
      state = state.copyWith(
        createdFolders: [folder, ...state.createdFolders],
        createdTotal: state.createdTotal + 1,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Delete folders.
  Future<bool> deleteFolders(List<int> mediaIds) async {
    try {
      await _repository.deleteFolders(mediaIds);

      // Remove from list
      state = state.copyWith(
        createdFolders: state.createdFolders
            .where((f) => !mediaIds.contains(f.id))
            .toList(),
        createdTotal: state.createdTotal - mediaIds.length,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Update a folder in the list.
  void updateFolder(int folderId, String title, String intro, bool isPublic) {
    state = state.copyWith(
      createdFolders: state.createdFolders.map((f) {
        if (f.id == folderId) {
          return f.copyWith(
            title: title,
            intro: intro,
            attr: isPublic ? (f.attr & ~1) : (f.attr | 1),
          );
        }
        return f;
      }).toList(),
    );
  }
}

/// Notifier for folder detail screen.
class FolderDetailNotifier extends StateNotifier<FolderDetailState> {
  final FavoritesRepository _repository;
  final int _folderId;

  FolderDetailNotifier(this._repository, this._folderId)
      : super(const FolderDetailState()) {
    load();
  }

  /// Load folder resources.
  Future<void> load({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: refresh || state.folder == null,
      pageNum: refresh ? 1 : state.pageNum,
      clearError: true,
    );

    try {
      final result = await _repository.getFolderResources(
        mediaId: _folderId.toString(),
        pageNum: refresh ? 1 : state.pageNum,
        order: state.order.value,
        keyword: state.keyword,
      );

      state = state.copyWith(
        folder: result.folder,
        medias: refresh ? result.medias : [...state.medias, ...result.medias],
        hasMore: result.hasMore,
        pageNum: (refresh ? 1 : state.pageNum) + 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more resources.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _repository.getFolderResources(
        mediaId: _folderId.toString(),
        pageNum: state.pageNum,
        order: state.order.value,
        keyword: state.keyword,
      );

      state = state.copyWith(
        medias: [...state.medias, ...result.medias],
        hasMore: result.hasMore,
        pageNum: state.pageNum + 1,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh folder resources.
  Future<void> refresh() => load(refresh: true);

  /// Set search keyword and reload.
  Future<void> setKeyword(String keyword) async {
    if (state.keyword == keyword) return;
    state = state.copyWith(keyword: keyword, medias: [], pageNum: 1);
    await load(refresh: true);
  }

  /// Set sort order and reload.
  Future<void> setOrder(FolderSortOrder order) async {
    if (state.order == order) return;
    state = state.copyWith(order: order, medias: [], pageNum: 1);
    await load(refresh: true);
  }

  /// Enter selection mode.
  void enterSelectionMode() {
    state = state.copyWith(isSelectionMode: true, selectedIds: {});
  }

  /// Exit selection mode.
  void exitSelectionMode() {
    state = state.copyWith(isSelectionMode: false, selectedIds: {});
  }

  /// Toggle selection of a media item.
  void toggleSelection(int mediaId) {
    final selectedIds = Set<int>.from(state.selectedIds);
    if (selectedIds.contains(mediaId)) {
      selectedIds.remove(mediaId);
    } else {
      selectedIds.add(mediaId);
    }
    state = state.copyWith(selectedIds: selectedIds);
  }

  /// Select all valid (non-invalid) items.
  void selectAll() {
    final selectedIds = state.medias
        .where((m) => !m.isInvalid)
        .map((m) => m.id)
        .toSet();
    state = state.copyWith(selectedIds: selectedIds);
  }

  /// Deselect all items.
  void deselectAll() {
    state = state.copyWith(selectedIds: {});
  }

  /// Build resource string for batch operations.
  String _buildResourceString(Set<int> mediaIds) {
    return state.medias
        .where((m) => mediaIds.contains(m.id))
        .map((m) => '${m.id}:${m.type}')
        .join(',');
  }

  /// Batch delete selected resources.
  Future<bool> batchDeleteSelected() async {
    if (!state.hasSelection) return false;

    try {
      final resources = _buildResourceString(state.selectedIds);
      await _repository.batchDeleteResources(
        mediaId: _folderId,
        resources: resources,
      );

      // Remove deleted items from local list
      final deletedIds = Set<int>.from(state.selectedIds);
      state = state.copyWith(
        medias: state.medias.where((m) => !deletedIds.contains(m.id)).toList(),
        selectedIds: {},
        isSelectionMode: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Batch move selected resources to another folder.
  Future<bool> batchMoveSelected({
    required int targetFolderId,
    required int userMid,
  }) async {
    if (!state.hasSelection) return false;

    try {
      final resources = _buildResourceString(state.selectedIds);
      await _repository.batchMoveResources(
        srcMediaId: _folderId,
        tarMediaId: targetFolderId,
        mid: userMid,
        resources: resources,
      );

      // Remove moved items from local list
      final movedIds = Set<int>.from(state.selectedIds);
      state = state.copyWith(
        medias: state.medias.where((m) => !movedIds.contains(m.id)).toList(),
        selectedIds: {},
        isSelectionMode: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Batch copy selected resources to another folder.
  Future<bool> batchCopySelected({
    required int targetFolderId,
    required int userMid,
  }) async {
    if (!state.hasSelection) return false;

    try {
      final resources = _buildResourceString(state.selectedIds);
      await _repository.batchCopyResources(
        srcMediaId: _folderId,
        tarMediaId: targetFolderId,
        mid: userMid,
        resources: resources,
      );

      // Exit selection mode (items stay in current folder)
      state = state.copyWith(
        selectedIds: {},
        isSelectionMode: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Clean invalid resources from the folder.
  Future<bool> cleanInvalidResources() async {
    try {
      await _repository.cleanInvalidResources(_folderId);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Get all medias from this folder (for play all).
  List<FavMedia> get allValidMedias =>
      state.medias.where((m) => !m.isInvalid).toList();
}

/// Notifier for folder selection.
class FolderSelectNotifier extends StateNotifier<FolderSelectState> {
  final FavoritesRepository _repository;
  final int? _userMid;
  final String _resourceId;

  FolderSelectNotifier(this._repository, this._userMid, this._resourceId)
      : super(const FolderSelectState()) {
    if (_userMid != null) {
      load();
    }
  }

  /// Load folders with favorite status.
  Future<void> load() async {
    if (_userMid == null) return;
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final folders = await _repository.getAllCreatedFolders(
        upMid: _userMid,
        resourceId: int.tryParse(_resourceId),
      );

      final selectedIds =
          folders.where((f) => f.favState == 1).map((f) => f.id).toList();

      state = state.copyWith(
        folders: folders,
        selectedIds: selectedIds,
        originalIds: List.from(selectedIds),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Toggle folder selection.
  void toggleSelection(int folderId) {
    final selectedIds = List<int>.from(state.selectedIds);
    if (selectedIds.contains(folderId)) {
      selectedIds.remove(folderId);
    } else {
      selectedIds.add(folderId);
    }
    state = state.copyWith(selectedIds: selectedIds);
  }

  /// Submit folder selection changes.
  Future<bool> submit() async {
    if (!state.hasChanges || state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final addIds = state.selectedIds
          .where((id) => !state.originalIds.contains(id))
          .toList();
      final removeIds = state.originalIds
          .where((id) => !state.selectedIds.contains(id))
          .toList();

      await _repository.addResourceToFolders(
        resourceId: _resourceId,
        addFolderIds: addIds,
        removeFolderIds: removeIds,
      );

      state = state.copyWith(
        originalIds: List.from(state.selectedIds),
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

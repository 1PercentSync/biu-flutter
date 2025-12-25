import '../../domain/entities/fav_media.dart';
import '../../domain/entities/favorites_folder.dart';

/// State for the favorites folder list.
class FavoritesListState {
  const FavoritesListState({
    this.createdFolders = const [],
    this.collectedFolders = const [],
    this.createdTotal = 0,
    this.collectedTotal = 0,
    this.createdHasMore = false,
    this.collectedHasMore = false,
    this.createdPageNum = 1,
    this.collectedPageNum = 1,
    this.isLoadingCreated = false,
    this.isLoadingCollected = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final List<FavoritesFolder> createdFolders;
  final List<FavoritesFolder> collectedFolders;
  final int createdTotal;
  final int collectedTotal;
  final bool createdHasMore;
  final bool collectedHasMore;
  final int createdPageNum;
  final int collectedPageNum;
  final bool isLoadingCreated;
  final bool isLoadingCollected;
  final bool isRefreshing;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  FavoritesListState copyWith({
    List<FavoritesFolder>? createdFolders,
    List<FavoritesFolder>? collectedFolders,
    int? createdTotal,
    int? collectedTotal,
    bool? createdHasMore,
    bool? collectedHasMore,
    int? createdPageNum,
    int? collectedPageNum,
    bool? isLoadingCreated,
    bool? isLoadingCollected,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesListState(
      createdFolders: createdFolders ?? this.createdFolders,
      collectedFolders: collectedFolders ?? this.collectedFolders,
      createdTotal: createdTotal ?? this.createdTotal,
      collectedTotal: collectedTotal ?? this.collectedTotal,
      createdHasMore: createdHasMore ?? this.createdHasMore,
      collectedHasMore: collectedHasMore ?? this.collectedHasMore,
      createdPageNum: createdPageNum ?? this.createdPageNum,
      collectedPageNum: collectedPageNum ?? this.collectedPageNum,
      isLoadingCreated: isLoadingCreated ?? this.isLoadingCreated,
      isLoadingCollected: isLoadingCollected ?? this.isLoadingCollected,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Sort order for folder resources.
enum FolderSortOrder {
  /// Sort by favorite time (most recent first)
  mtime('mtime', '收藏时间'),

  /// Sort by view count (most viewed first)
  view('view', '播放量'),

  /// Sort by publish time (most recent first)
  pubtime('pubtime', '发布时间');

  const FolderSortOrder(this.value, this.label);
  final String value;
  final String label;
}

/// State for folder detail screen.
class FolderDetailState {
  const FolderDetailState({
    this.folder,
    this.medias = const [],
    this.hasMore = false,
    this.pageNum = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.keyword = '',
    this.order = FolderSortOrder.mtime,
    this.isSelectionMode = false,
    this.selectedIds = const {},
  });

  final FavoritesFolder? folder;
  final List<FavMedia> medias;
  final bool hasMore;
  final int pageNum;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  /// Search keyword for filtering
  final String keyword;

  /// Sort order for resources
  final FolderSortOrder order;

  /// Whether multi-select mode is active
  final bool isSelectionMode;

  /// Selected media IDs in selection mode
  final Set<int> selectedIds;

  bool get hasError => errorMessage != null;

  /// Whether any items are selected
  bool get hasSelection => selectedIds.isNotEmpty;

  /// Number of selected items
  int get selectedCount => selectedIds.length;

  FolderDetailState copyWith({
    FavoritesFolder? folder,
    List<FavMedia>? medias,
    bool? hasMore,
    int? pageNum,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? keyword,
    FolderSortOrder? order,
    bool? isSelectionMode,
    Set<int>? selectedIds,
    bool clearError = false,
    bool clearFolder = false,
  }) {
    return FolderDetailState(
      folder: clearFolder ? null : (folder ?? this.folder),
      medias: medias ?? this.medias,
      hasMore: hasMore ?? this.hasMore,
      pageNum: pageNum ?? this.pageNum,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      keyword: keyword ?? this.keyword,
      order: order ?? this.order,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

/// State for folder selection modal.
class FolderSelectState {
  const FolderSelectState({
    this.folders = const [],
    this.selectedIds = const [],
    this.originalIds = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<FavoritesFolder> folders;
  final List<int> selectedIds;
  final List<int> originalIds;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  bool get hasChanges {
    if (selectedIds.length != originalIds.length) return true;
    final selectedSet = selectedIds.toSet();
    return !originalIds.every(selectedSet.contains);
  }

  FolderSelectState copyWith({
    List<FavoritesFolder>? folders,
    List<int>? selectedIds,
    List<int>? originalIds,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FolderSelectState(
      folders: folders ?? this.folders,
      selectedIds: selectedIds ?? this.selectedIds,
      originalIds: originalIds ?? this.originalIds,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

import '../../../favorites/data/models/folder_response.dart';
import '../../data/models/space_acc_info.dart';
import '../../data/models/space_arc_search.dart';
import '../../data/models/space_relation.dart';
import '../../data/models/space_setting.dart';

/// State for user profile screen
class UserProfileState {
  const UserProfileState({
    this.mid,
    this.spaceInfo,
    this.relationData,
    this.relationStat,
    this.spacePrivacy,
    this.videos,
    this.videoPage,
    this.videoKeyword = '',
    this.videoOrder = 'pubdate',
    this.userFolders,
    this.folderPage = 1,
    this.isLoadingInfo = true, // Default to true for initial loading state
    this.isLoadingVideos = false,
    this.isLoadingMore = false,
    this.isLoadingFolders = false,
    this.isLoadingMoreFolders = false,
    this.errorMessage,
  });

  /// Target user mid
  final int? mid;

  /// User space info
  final SpaceAccInfo? spaceInfo;

  /// Relation with current user
  final SpaceRelationData? relationData;

  /// Relation statistics
  final RelationStat? relationStat;

  /// Space privacy settings
  /// Source: biu/src/service/space-setting.ts#Privacy
  final SpacePrivacy? spacePrivacy;

  /// Videos list
  final List<SpaceArcVListItem>? videos;

  /// Video pagination info
  final SpaceArcSearchPage? videoPage;

  /// Video search keyword
  final String videoKeyword;

  /// Video sort order
  final String videoOrder;

  /// User's public folders
  /// Source: biu/src/pages/user-profile/favorites.tsx
  final List<FolderModel>? userFolders;

  /// Current folder page
  final int folderPage;

  /// Loading states
  final bool isLoadingInfo;
  final bool isLoadingVideos;
  final bool isLoadingMore;
  final bool isLoadingFolders;
  final bool isLoadingMoreFolders;

  /// Error message
  final String? errorMessage;

  /// Whether has more videos
  bool get hasMoreVideos => videoPage?.hasMore ?? false;

  /// Whether is blocked
  bool get isBlocked =>
      relationData?.relation.relation == UserRelation.blocked;

  /// Whether is following
  bool get isFollowing => relationData?.relation.isFollowing ?? false;

  /// Whether is mutual
  bool get isMutual => relationData?.relation.isMutual ?? false;

  /// Whether favorites tab should be visible
  /// If self or privacy allows, show the tab
  bool shouldShowFavoritesTab(int? currentUserId) {
    if (mid == currentUserId) return true; // Self always sees it
    return spacePrivacy?.isFavoritesVisible ?? false;
  }

  /// Copy with new values
  UserProfileState copyWith({
    int? mid,
    SpaceAccInfo? spaceInfo,
    SpaceRelationData? relationData,
    RelationStat? relationStat,
    SpacePrivacy? spacePrivacy,
    List<SpaceArcVListItem>? videos,
    SpaceArcSearchPage? videoPage,
    String? videoKeyword,
    String? videoOrder,
    List<FolderModel>? userFolders,
    int? folderPage,
    bool? isLoadingInfo,
    bool? isLoadingVideos,
    bool? isLoadingMore,
    bool? isLoadingFolders,
    bool? isLoadingMoreFolders,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserProfileState(
      mid: mid ?? this.mid,
      spaceInfo: spaceInfo ?? this.spaceInfo,
      relationData: relationData ?? this.relationData,
      relationStat: relationStat ?? this.relationStat,
      spacePrivacy: spacePrivacy ?? this.spacePrivacy,
      videos: videos ?? this.videos,
      videoPage: videoPage ?? this.videoPage,
      videoKeyword: videoKeyword ?? this.videoKeyword,
      videoOrder: videoOrder ?? this.videoOrder,
      userFolders: userFolders ?? this.userFolders,
      folderPage: folderPage ?? this.folderPage,
      isLoadingInfo: isLoadingInfo ?? this.isLoadingInfo,
      isLoadingVideos: isLoadingVideos ?? this.isLoadingVideos,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingFolders: isLoadingFolders ?? this.isLoadingFolders,
      isLoadingMoreFolders: isLoadingMoreFolders ?? this.isLoadingMoreFolders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

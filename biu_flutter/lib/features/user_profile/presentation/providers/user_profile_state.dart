import '../../data/models/space_acc_info.dart';
import '../../data/models/space_arc_search.dart';
import '../../data/models/space_relation.dart';

/// State for user profile screen
class UserProfileState {
  const UserProfileState({
    this.mid,
    this.spaceInfo,
    this.relationData,
    this.relationStat,
    this.videos,
    this.videoPage,
    this.videoKeyword = '',
    this.videoOrder = 'pubdate',
    this.isLoadingInfo = false,
    this.isLoadingVideos = false,
    this.isLoadingMore = false,
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

  /// Videos list
  final List<SpaceArcVListItem>? videos;

  /// Video pagination info
  final SpaceArcSearchPage? videoPage;

  /// Video search keyword
  final String videoKeyword;

  /// Video sort order
  final String videoOrder;

  /// Loading states
  final bool isLoadingInfo;
  final bool isLoadingVideos;
  final bool isLoadingMore;

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

  /// Copy with new values
  UserProfileState copyWith({
    int? mid,
    SpaceAccInfo? spaceInfo,
    SpaceRelationData? relationData,
    RelationStat? relationStat,
    List<SpaceArcVListItem>? videos,
    SpaceArcSearchPage? videoPage,
    String? videoKeyword,
    String? videoOrder,
    bool? isLoadingInfo,
    bool? isLoadingVideos,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserProfileState(
      mid: mid ?? this.mid,
      spaceInfo: spaceInfo ?? this.spaceInfo,
      relationData: relationData ?? this.relationData,
      relationStat: relationStat ?? this.relationStat,
      videos: videos ?? this.videos,
      videoPage: videoPage ?? this.videoPage,
      videoKeyword: videoKeyword ?? this.videoKeyword,
      videoOrder: videoOrder ?? this.videoOrder,
      isLoadingInfo: isLoadingInfo ?? this.isLoadingInfo,
      isLoadingVideos: isLoadingVideos ?? this.isLoadingVideos,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

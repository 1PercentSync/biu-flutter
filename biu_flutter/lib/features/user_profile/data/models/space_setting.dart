/// Space privacy settings model
///
/// Source: biu/src/service/space-setting.ts#Privacy
class SpacePrivacy {
  const SpacePrivacy({
    this.bangumi = 0,
    this.channel = 0,
    this.chargeVideo = 0,
    this.coinsVideo = 0,
    this.disableFollowing = 0,
    this.disableShowFans = 0,
    this.favVideo = 0,
    this.likesVideo = 0,
    this.groups = 0,
    this.tags = 0,
    this.userInfo = 0,
  });

  factory SpacePrivacy.fromJson(Map<String, dynamic> json) {
    return SpacePrivacy(
      bangumi: json['bangumi'] as int? ?? 0,
      channel: json['channel'] as int? ?? 0,
      chargeVideo: json['charge_video'] as int? ?? 0,
      coinsVideo: json['coins_video'] as int? ?? 0,
      disableFollowing: json['disable_following'] as int? ?? 0,
      disableShowFans: json['disable_show_fans'] as int? ?? 0,
      favVideo: json['fav_video'] as int? ?? 0,
      likesVideo: json['likes_video'] as int? ?? 0,
      groups: json['groups'] as int? ?? 0,
      tags: json['tags'] as int? ?? 0,
      userInfo: json['user_info'] as int? ?? 0,
    );
  }

  /// 追番可见性 (0=hidden, 1=public)
  final int bangumi;

  /// 频道可见性
  final int channel;

  /// 充电视频可见性
  final int chargeVideo;

  /// 投币视频可见性
  final int coinsVideo;

  /// 禁止查看关注列表
  final int disableFollowing;

  /// 禁止显示粉丝数
  final int disableShowFans;

  /// 收藏夹可见性 (0=hidden, 1=public)
  final int favVideo;

  /// 点赞视频可见性
  final int likesVideo;

  /// 关注分组可见性
  final int groups;

  /// 标签可见性
  final int tags;

  /// 用户信息可见性
  final int userInfo;

  /// Whether favorites are visible
  bool get isFavoritesVisible => favVideo == 1;

  /// Whether following list is visible
  bool get isFollowingVisible => disableFollowing == 0;

  Map<String, dynamic> toJson() {
    return {
      'bangumi': bangumi,
      'channel': channel,
      'charge_video': chargeVideo,
      'coins_video': coinsVideo,
      'disable_following': disableFollowing,
      'disable_show_fans': disableShowFans,
      'fav_video': favVideo,
      'likes_video': likesVideo,
      'groups': groups,
      'tags': tags,
      'user_info': userInfo,
    };
  }
}

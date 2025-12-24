/// Model for a following user from relation API
class FollowingUser {
  const FollowingUser({
    required this.mid,
    required this.uname,
    this.face,
    this.sign,
    this.attribute = 0,
    this.mtime,
    this.tag,
    this.special = 0,
    this.faceNft = 0,
    this.officialVerify,
    this.vip,
  });

  factory FollowingUser.fromJson(Map<String, dynamic> json) {
    return FollowingUser(
      mid: json['mid'] as int,
      uname: json['uname'] as String? ?? '',
      face: json['face'] as String?,
      sign: json['sign'] as String?,
      attribute: json['attribute'] as int? ?? 0,
      mtime: json['mtime'] as int?,
      tag: (json['tag'] as List<dynamic>?)?.cast<int>(),
      special: json['special'] as int? ?? 0,
      faceNft: json['face_nft'] as int? ?? 0,
      officialVerify: json['official_verify'] != null
          ? OfficialVerify.fromJson(json['official_verify'] as Map<String, dynamic>)
          : null,
      vip: json['vip'] != null
          ? UserVip.fromJson(json['vip'] as Map<String, dynamic>)
          : null,
    );
  }

  /// User mid
  final int mid;

  /// User nickname
  final String uname;

  /// User avatar URL
  final String? face;

  /// User signature
  final String? sign;

  /// Relation attribute:
  /// 0 - not following
  /// 1 - quietly following (deprecated)
  /// 2 - following
  /// 6 - mutual following
  /// 128 - blocked
  final int attribute;

  /// Follow time (seconds timestamp)
  final int? mtime;

  /// Group tags
  final List<int>? tag;

  /// Special attention: 0 - no, 1 - yes
  final int special;

  /// Is NFT avatar: 0 - no, 1 - yes
  final int faceNft;

  /// Official verification info
  final OfficialVerify? officialVerify;

  /// VIP info
  final UserVip? vip;

  /// Check if mutual following
  bool get isMutual => attribute == 6;

  /// Check if special attention
  bool get isSpecial => special == 1;

  /// Check if has official verification
  bool get isVerified =>
      officialVerify != null && officialVerify!.type >= 0;
}

/// Official verification information
class OfficialVerify {
  const OfficialVerify({
    required this.type,
    this.desc,
  });

  factory OfficialVerify.fromJson(Map<String, dynamic> json) {
    return OfficialVerify(
      type: json['type'] as int? ?? -1,
      desc: json['desc'] as String?,
    );
  }

  /// Verification type: -1 none, 0 UP verification, 1 organization verification
  final int type;

  /// Verification description
  final String? desc;
}

/// User VIP information
class UserVip {
  const UserVip({
    required this.vipType,
    required this.vipStatus,
    this.vipDueDate,
    this.label,
  });

  factory UserVip.fromJson(Map<String, dynamic> json) {
    return UserVip(
      vipType: json['vipType'] as int? ?? 0,
      vipStatus: json['vipStatus'] as int? ?? 0,
      vipDueDate: json['vipDueDate'] as int?,
      label: json['label'] != null
          ? VipLabel.fromJson(json['label'] as Map<String, dynamic>)
          : null,
    );
  }

  /// VIP type: 0 none, 1 monthly, 2 yearly or above
  final int vipType;

  /// VIP status: 0 none, 1 active
  final int vipStatus;

  /// VIP expiry date (milliseconds timestamp)
  final int? vipDueDate;

  /// VIP label
  final VipLabel? label;

  /// Check if VIP is active
  bool get isVip => vipStatus == 1 && vipType > 0;
}

/// VIP label information
class VipLabel {
  const VipLabel({
    this.path,
    this.text,
    this.labelTheme,
    this.textColor,
    this.bgStyle,
    this.bgColor,
    this.borderColor,
  });

  factory VipLabel.fromJson(Map<String, dynamic> json) {
    return VipLabel(
      path: json['path'] as String?,
      text: json['text'] as String?,
      labelTheme: json['label_theme'] as String?,
      textColor: json['text_color'] as String?,
      bgStyle: json['bg_style'] as int?,
      bgColor: json['bg_color'] as String?,
      borderColor: json['border_color'] as String?,
    );
  }

  final String? path;
  final String? text;
  final String? labelTheme;
  final String? textColor;
  final int? bgStyle;
  final String? bgColor;
  final String? borderColor;
}

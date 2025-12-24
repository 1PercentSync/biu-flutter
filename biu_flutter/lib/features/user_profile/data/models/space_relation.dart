// User relation model
// Reference: biu/src/service/space-wbi-acc-relation.ts

/// User relation attribute values
/// Reference: biu/src/common/constants/relation.ts
enum UserRelation {
  /// Not following
  unfollowed(0),

  /// Quietly following (deprecated)
  quietlyFollowing(1),

  /// Following
  followed(2),

  /// Mutual following
  mutualFollowed(6),

  /// Blocked
  blocked(128);

  const UserRelation(this.value);
  final int value;

  static UserRelation fromValue(int value) {
    return UserRelation.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRelation.unfollowed,
    );
  }
}

/// Relation attribute object
class RelationAttribute {
  const RelationAttribute({
    required this.mid,
    required this.attribute,
    required this.mtime,
    this.tag,
    this.special = 0,
  });

  factory RelationAttribute.fromJson(Map<String, dynamic> json) {
    return RelationAttribute(
      mid: json['mid'] as int? ?? 0,
      attribute: json['attribute'] as int? ?? 0,
      mtime: json['mtime'] as int? ?? 0,
      tag: (json['tag'] as List<dynamic>?)?.cast<int>(),
      special: json['special'] as int? ?? 0,
    );
  }

  /// Target user mid
  final int mid;

  /// Relation attribute: 0 unfollowed, 2 followed, 6 mutual, 128 blocked
  final int attribute;

  /// Follow time (Unix seconds, 0 if not followed)
  final int mtime;

  /// Group id list (null for default group)
  final List<int>? tag;

  /// Special follow flag: 0 no, 1 yes
  final int special;

  /// Get relation enum
  UserRelation get relation => UserRelation.fromValue(attribute);

  /// Is following
  bool get isFollowing =>
      relation == UserRelation.followed ||
      relation == UserRelation.mutualFollowed;

  /// Is mutual following
  bool get isMutual => relation == UserRelation.mutualFollowed;

  /// Is blocked
  bool get isBlocked => relation == UserRelation.blocked;

  /// Is special follow
  bool get isSpecial => special == 1;
}

/// User relation data
class SpaceRelationData {
  const SpaceRelationData({
    required this.relation,
    required this.beRelation,
  });

  factory SpaceRelationData.fromJson(Map<String, dynamic> json) {
    return SpaceRelationData(
      relation: RelationAttribute.fromJson(
          json['relation'] as Map<String, dynamic>? ?? {}),
      beRelation: RelationAttribute.fromJson(
          json['be_relation'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Target user's relation to current user
  final RelationAttribute relation;

  /// Current user's relation to target user
  final RelationAttribute beRelation;
}

/// Relation statistics
class RelationStat {
  const RelationStat({
    required this.mid,
    required this.following,
    required this.follower,
  });

  factory RelationStat.fromJson(Map<String, dynamic> json) {
    return RelationStat(
      mid: json['mid'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      follower: json['follower'] as int? ?? 0,
    );
  }

  /// User mid
  final int mid;

  /// Following count
  final int following;

  /// Follower count
  final int follower;
}

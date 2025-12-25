/// Dynamic feed item model.
/// Source: biu/src/pages/user-profile/dynamic-list/index.tsx
/// Source: biu/src/service/web-dynamic.ts

/// Dynamic type constants
/// Source: biu/src/common/constants/feed.ts
class DynamicType {
  DynamicType._();

  /// Invalid dynamic
  static const String none = 'DYNAMIC_TYPE_NONE';

  /// Repost dynamic
  static const String forward = 'DYNAMIC_TYPE_FORWARD';

  /// Video post
  static const String av = 'DYNAMIC_TYPE_AV';

  /// Bangumi/Movie/Documentary
  static const String pgc = 'DYNAMIC_TYPE_PGC';

  /// Course
  static const String courses = 'DYNAMIC_TYPE_COURSES';

  /// Pure text dynamic
  static const String word = 'DYNAMIC_TYPE_WORD';

  /// Image dynamic
  static const String draw = 'DYNAMIC_TYPE_DRAW';

  /// Article
  static const String article = 'DYNAMIC_TYPE_ARTICLE';

  /// Music
  static const String music = 'DYNAMIC_TYPE_MUSIC';

  /// General sharing
  static const String commonSquare = 'DYNAMIC_TYPE_COMMON_SQUARE';

  /// Vertical video
  static const String commonVertical = 'DYNAMIC_TYPE_COMMON_VERTICAL';

  /// Live stream sharing
  static const String live = 'DYNAMIC_TYPE_LIVE';

  /// Favorites folder
  static const String medialist = 'DYNAMIC_TYPE_MEDIALIST';

  /// UGC season update
  static const String ugcSeason = 'DYNAMIC_TYPE_UGC_SEASON';
}

/// Dynamic item from API response.
class DynamicItem {
  const DynamicItem({
    required this.idStr,
    required this.type,
    required this.modules,
    required this.visible,
    this.orig,
  });

  /// Dynamic item ID string
  final String idStr;

  /// Dynamic type (e.g., DYNAMIC_TYPE_AV, DYNAMIC_TYPE_DRAW)
  final String type;

  /// Dynamic modules containing author, content, and stats
  final DynamicModules modules;

  /// Whether this dynamic is visible
  final bool visible;

  /// Original dynamic for repost
  final DynamicItem? orig;

  factory DynamicItem.fromJson(Map<String, dynamic> json) {
    return DynamicItem(
      idStr: json['id_str'] as String? ?? '',
      type: json['type'] as String? ?? '',
      modules: DynamicModules.fromJson(
          json['modules'] as Map<String, dynamic>? ?? {}),
      visible: json['visible'] as bool? ?? true,
      orig: json['orig'] != null
          ? DynamicItem.fromJson(json['orig'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Check if this is a video dynamic
  bool get isVideo => type == DynamicType.av || type == DynamicType.ugcSeason;

  /// Check if this is an image dynamic
  bool get isDraw => type == DynamicType.draw;

  /// Check if this is a text-only dynamic
  bool get isWord => type == DynamicType.word;

  /// Check if this is a repost
  bool get isForward => type == DynamicType.forward;
}

/// Dynamic modules container.
class DynamicModules {
  const DynamicModules({
    required this.moduleAuthor,
    required this.moduleDynamic,
    this.moduleStat,
    this.moduleMore,
    this.moduleInteraction,
  });

  /// Author information
  final ModuleAuthor moduleAuthor;

  /// Dynamic content (desc, major)
  final ModuleDynamic moduleDynamic;

  /// Statistics (likes, comments, forwards)
  final ModuleStat? moduleStat;

  /// More options
  final ModuleMore? moduleMore;

  /// Interaction info
  final ModuleInteraction? moduleInteraction;

  factory DynamicModules.fromJson(Map<String, dynamic> json) {
    return DynamicModules(
      moduleAuthor: ModuleAuthor.fromJson(
          json['module_author'] as Map<String, dynamic>? ?? {}),
      moduleDynamic: ModuleDynamic.fromJson(
          json['module_dynamic'] as Map<String, dynamic>? ?? {}),
      moduleStat: json['module_stat'] != null
          ? ModuleStat.fromJson(json['module_stat'] as Map<String, dynamic>)
          : null,
      moduleMore: json['module_more'] != null
          ? ModuleMore.fromJson(json['module_more'] as Map<String, dynamic>)
          : null,
      moduleInteraction: json['module_interaction'] != null
          ? ModuleInteraction.fromJson(
              json['module_interaction'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Author information module.
class ModuleAuthor {
  const ModuleAuthor({
    required this.mid,
    required this.name,
    required this.face,
    required this.pubTime,
    required this.pubTs,
    this.following,
    this.label,
    this.pubAction,
  });

  /// User ID
  final int mid;

  /// Username
  final String name;

  /// Avatar URL
  final String face;

  /// Publish time display string
  final String pubTime;

  /// Publish timestamp
  final int pubTs;

  /// Whether current user is following
  final bool? following;

  /// Label text
  final String? label;

  /// Publish action text
  final String? pubAction;

  factory ModuleAuthor.fromJson(Map<String, dynamic> json) {
    return ModuleAuthor(
      mid: json['mid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      face: json['face'] as String? ?? '',
      pubTime: json['pub_time'] as String? ?? '',
      pubTs: json['pub_ts'] as int? ?? 0,
      following: json['following'] as bool?,
      label: json['label'] as String?,
      pubAction: json['pub_action'] as String?,
    );
  }
}

/// Dynamic content module.
class ModuleDynamic {
  const ModuleDynamic({
    this.desc,
    this.major,
    this.additional,
    this.topic,
  });

  /// Text description
  final DynamicDesc? desc;

  /// Major content (video, images, etc.)
  final DynamicMajor? major;

  /// Additional content
  final DynamicAdditional? additional;

  /// Topic info
  final DynamicTopic? topic;

  factory ModuleDynamic.fromJson(Map<String, dynamic> json) {
    return ModuleDynamic(
      desc: json['desc'] != null
          ? DynamicDesc.fromJson(json['desc'] as Map<String, dynamic>)
          : null,
      major: json['major'] != null
          ? DynamicMajor.fromJson(json['major'] as Map<String, dynamic>)
          : null,
      additional: json['additional'] != null
          ? DynamicAdditional.fromJson(
              json['additional'] as Map<String, dynamic>)
          : null,
      topic: json['topic'] != null
          ? DynamicTopic.fromJson(json['topic'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Text description in dynamic.
class DynamicDesc {
  const DynamicDesc({
    required this.text,
    this.richTextNodes,
  });

  /// Plain text content
  final String text;

  /// Rich text nodes for rendering
  final List<RichTextNode>? richTextNodes;

  factory DynamicDesc.fromJson(Map<String, dynamic> json) {
    return DynamicDesc(
      text: json['text'] as String? ?? '',
      richTextNodes: (json['rich_text_nodes'] as List<dynamic>?)
          ?.map((e) => RichTextNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Rich text node for dynamic content.
class RichTextNode {
  const RichTextNode({
    required this.origText,
    required this.text,
    required this.type,
    this.jumpUrl,
    this.emoji,
  });

  final String origText;
  final String text;
  final String type;
  final String? jumpUrl;
  final RichTextEmoji? emoji;

  factory RichTextNode.fromJson(Map<String, dynamic> json) {
    return RichTextNode(
      origText: json['orig_text'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? '',
      jumpUrl: json['jump_url'] as String?,
      emoji: json['emoji'] != null
          ? RichTextEmoji.fromJson(json['emoji'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Emoji in rich text.
class RichTextEmoji {
  const RichTextEmoji({
    required this.iconUrl,
    required this.size,
    required this.text,
  });

  final String iconUrl;
  final int size;
  final String text;

  factory RichTextEmoji.fromJson(Map<String, dynamic> json) {
    return RichTextEmoji(
      iconUrl: json['icon_url'] as String? ?? '',
      size: json['size'] as int? ?? 1,
      text: json['text'] as String? ?? '',
    );
  }
}

/// Major content type constants
class MajorType {
  MajorType._();

  static const String none = 'MAJOR_TYPE_NONE';
  static const String opus = 'MAJOR_TYPE_OPUS';
  static const String archive = 'MAJOR_TYPE_ARCHIVE';
  static const String pgc = 'MAJOR_TYPE_PGC';
  static const String draw = 'MAJOR_TYPE_DRAW';
  static const String article = 'MAJOR_TYPE_ARTICLE';
  static const String music = 'MAJOR_TYPE_MUSIC';
  static const String common = 'MAJOR_TYPE_COMMON';
  static const String live = 'MAJOR_TYPE_LIVE';
  static const String ugcSeason = 'MAJOR_TYPE_UGC_SEASON';
}

/// Major content in dynamic.
class DynamicMajor {
  const DynamicMajor({
    required this.type,
    this.archive,
    this.draw,
    this.opus,
    this.ugcSeason,
    this.article,
    this.music,
    this.common,
    this.live,
  });

  /// Major type
  final String type;

  /// Video archive
  final MajorArchive? archive;

  /// Image draw
  final MajorDraw? draw;

  /// Opus (image post with text)
  final MajorOpus? opus;

  /// UGC season
  final MajorUgcSeason? ugcSeason;

  /// Article
  final MajorArticle? article;

  /// Music
  final MajorMusic? music;

  /// Common type
  final MajorCommon? common;

  /// Live
  final MajorLive? live;

  factory DynamicMajor.fromJson(Map<String, dynamic> json) {
    return DynamicMajor(
      type: json['type'] as String? ?? '',
      archive: json['archive'] != null
          ? MajorArchive.fromJson(json['archive'] as Map<String, dynamic>)
          : null,
      draw: json['draw'] != null
          ? MajorDraw.fromJson(json['draw'] as Map<String, dynamic>)
          : null,
      opus: json['opus'] != null
          ? MajorOpus.fromJson(json['opus'] as Map<String, dynamic>)
          : null,
      ugcSeason: json['ugc_season'] != null
          ? MajorUgcSeason.fromJson(json['ugc_season'] as Map<String, dynamic>)
          : null,
      article: json['article'] != null
          ? MajorArticle.fromJson(json['article'] as Map<String, dynamic>)
          : null,
      music: json['music'] != null
          ? MajorMusic.fromJson(json['music'] as Map<String, dynamic>)
          : null,
      common: json['common'] != null
          ? MajorCommon.fromJson(json['common'] as Map<String, dynamic>)
          : null,
      live: json['live'] != null
          ? MajorLive.fromJson(json['live'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Get video info from archive or ugc_season
  MajorArchive? get videoInfo => archive ?? ugcSeason?.toArchive();
}

/// Video archive in dynamic.
class MajorArchive {
  const MajorArchive({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.cover,
    required this.desc,
    required this.durationText,
    this.jumpUrl,
    this.stat,
    this.badge,
    this.type,
  });

  /// Aid
  final String aid;

  /// Bvid
  final String bvid;

  /// Video title
  final String title;

  /// Cover image URL
  final String cover;

  /// Video description
  final String desc;

  /// Duration display text (e.g., "12:34")
  final String durationText;

  /// Jump URL
  final String? jumpUrl;

  /// Video stats
  final ArchiveStat? stat;

  /// Badge info
  final ArchiveBadge? badge;

  /// Video type
  final int? type;

  factory MajorArchive.fromJson(Map<String, dynamic> json) {
    return MajorArchive(
      aid: json['aid'] as String? ?? '',
      bvid: json['bvid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      durationText: json['duration_text'] as String? ?? '',
      jumpUrl: json['jump_url'] as String?,
      stat: json['stat'] != null
          ? ArchiveStat.fromJson(json['stat'] as Map<String, dynamic>)
          : null,
      badge: json['badge'] != null
          ? ArchiveBadge.fromJson(json['badge'] as Map<String, dynamic>)
          : null,
      type: json['type'] as int?,
    );
  }
}

/// Video stats in archive.
class ArchiveStat {
  const ArchiveStat({
    required this.play,
    required this.danmaku,
  });

  final String play;
  final String danmaku;

  factory ArchiveStat.fromJson(Map<String, dynamic> json) {
    return ArchiveStat(
      play: json['play'] as String? ?? '0',
      danmaku: json['danmaku'] as String? ?? '0',
    );
  }
}

/// Badge info for archive.
class ArchiveBadge {
  const ArchiveBadge({
    required this.text,
    this.bgColor,
    this.color,
  });

  final String text;
  final String? bgColor;
  final String? color;

  factory ArchiveBadge.fromJson(Map<String, dynamic> json) {
    return ArchiveBadge(
      text: json['text'] as String? ?? '',
      bgColor: json['bg_color'] as String?,
      color: json['color'] as String?,
    );
  }
}

/// UGC season in dynamic.
class MajorUgcSeason {
  const MajorUgcSeason({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.cover,
    required this.desc,
    required this.durationText,
    this.jumpUrl,
    this.stat,
  });

  final int aid;
  final String bvid;
  final String title;
  final String cover;
  final String desc;
  final String durationText;
  final String? jumpUrl;
  final ArchiveStat? stat;

  factory MajorUgcSeason.fromJson(Map<String, dynamic> json) {
    return MajorUgcSeason(
      aid: json['aid'] as int? ?? 0,
      bvid: json['bvid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      durationText: json['duration_text'] as String? ?? '',
      jumpUrl: json['jump_url'] as String?,
      stat: json['stat'] != null
          ? ArchiveStat.fromJson(json['stat'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to MajorArchive for unified handling
  MajorArchive toArchive() {
    return MajorArchive(
      aid: aid.toString(),
      bvid: bvid,
      title: title,
      cover: cover,
      desc: desc,
      durationText: durationText,
      jumpUrl: jumpUrl,
      stat: stat,
    );
  }
}

/// Image draw in dynamic.
class MajorDraw {
  const MajorDraw({
    required this.id,
    required this.items,
  });

  final int id;
  final List<DrawItem> items;

  factory MajorDraw.fromJson(Map<String, dynamic> json) {
    return MajorDraw(
      id: json['id'] as int? ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => DrawItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Image item in draw.
class DrawItem {
  const DrawItem({
    required this.src,
    required this.width,
    required this.height,
    this.size,
  });

  final String src;
  final int width;
  final int height;
  final int? size;

  factory DrawItem.fromJson(Map<String, dynamic> json) {
    return DrawItem(
      src: json['src'] as String? ?? '',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      size: json['size'] as int?,
    );
  }
}

/// Opus in dynamic (image post with text).
class MajorOpus {
  const MajorOpus({
    required this.jumpUrl,
    required this.pics,
    this.summary,
    this.title,
  });

  final String jumpUrl;
  final List<OpusPic> pics;
  final OpusSummary? summary;
  final String? title;

  factory MajorOpus.fromJson(Map<String, dynamic> json) {
    return MajorOpus(
      jumpUrl: json['jump_url'] as String? ?? '',
      pics: (json['pics'] as List<dynamic>?)
              ?.map((e) => OpusPic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] != null
          ? OpusSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      title: json['title'] as String?,
    );
  }
}

/// Picture in opus.
class OpusPic {
  const OpusPic({
    required this.src,
    required this.width,
    required this.height,
  });

  final String src;
  final int width;
  final int height;

  factory OpusPic.fromJson(Map<String, dynamic> json) {
    return OpusPic(
      src: json['src'] as String? ?? '',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
    );
  }
}

/// Summary in opus.
class OpusSummary {
  const OpusSummary({
    required this.text,
    this.richTextNodes,
  });

  final String text;
  final List<RichTextNode>? richTextNodes;

  factory OpusSummary.fromJson(Map<String, dynamic> json) {
    return OpusSummary(
      text: json['text'] as String? ?? '',
      richTextNodes: (json['rich_text_nodes'] as List<dynamic>?)
          ?.map((e) => RichTextNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Article in dynamic.
class MajorArticle {
  const MajorArticle({
    required this.id,
    required this.title,
    required this.desc,
    required this.covers,
    this.jumpUrl,
  });

  final int id;
  final String title;
  final String desc;
  final List<String> covers;
  final String? jumpUrl;

  factory MajorArticle.fromJson(Map<String, dynamic> json) {
    return MajorArticle(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      covers: (json['covers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      jumpUrl: json['jump_url'] as String?,
    );
  }
}

/// Music in dynamic.
class MajorMusic {
  const MajorMusic({
    required this.id,
    required this.title,
    required this.cover,
    this.label,
  });

  final int id;
  final String title;
  final String cover;
  final String? label;

  factory MajorMusic.fromJson(Map<String, dynamic> json) {
    return MajorMusic(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      label: json['label'] as String?,
    );
  }
}

/// Common type in dynamic.
class MajorCommon {
  const MajorCommon({
    required this.cover,
    required this.title,
    required this.desc1,
    required this.desc2,
    this.jumpUrl,
  });

  final String cover;
  final String title;
  final String desc1;
  final String desc2;
  final String? jumpUrl;

  factory MajorCommon.fromJson(Map<String, dynamic> json) {
    return MajorCommon(
      cover: json['cover'] as String? ?? '',
      title: json['title'] as String? ?? '',
      desc1: json['desc1'] as String? ?? '',
      desc2: json['desc2'] as String? ?? '',
      jumpUrl: json['jump_url'] as String?,
    );
  }
}

/// Live in dynamic.
class MajorLive {
  const MajorLive({
    required this.id,
    required this.title,
    required this.cover,
    this.roomId,
    this.liveState,
  });

  final int id;
  final String title;
  final String cover;
  final int? roomId;
  final int? liveState;

  factory MajorLive.fromJson(Map<String, dynamic> json) {
    return MajorLive(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      roomId: json['room_id'] as int?,
      liveState: json['live_state'] as int?,
    );
  }
}

/// Additional content in dynamic.
class DynamicAdditional {
  const DynamicAdditional({
    required this.type,
    this.common,
    this.reserve,
    this.vote,
    this.goods,
    this.ugc,
  });

  final String type;
  final AdditionalCommon? common;
  final dynamic reserve;
  final dynamic vote;
  final dynamic goods;
  final dynamic ugc;

  factory DynamicAdditional.fromJson(Map<String, dynamic> json) {
    return DynamicAdditional(
      type: json['type'] as String? ?? '',
      common: json['common'] != null
          ? AdditionalCommon.fromJson(json['common'] as Map<String, dynamic>)
          : null,
      reserve: json['reserve'],
      vote: json['vote'],
      goods: json['goods'],
      ugc: json['ugc'],
    );
  }
}

/// Common additional content.
class AdditionalCommon {
  const AdditionalCommon({
    required this.cover,
    required this.title,
    required this.desc1,
    required this.desc2,
    this.jumpUrl,
  });

  final String cover;
  final String title;
  final String desc1;
  final String desc2;
  final String? jumpUrl;

  factory AdditionalCommon.fromJson(Map<String, dynamic> json) {
    return AdditionalCommon(
      cover: json['cover'] as String? ?? '',
      title: json['title'] as String? ?? '',
      desc1: json['desc1'] as String? ?? '',
      desc2: json['desc2'] as String? ?? '',
      jumpUrl: json['jump_url'] as String?,
    );
  }
}

/// Topic info in dynamic.
class DynamicTopic {
  const DynamicTopic({
    required this.id,
    required this.name,
    this.jumpUrl,
  });

  final int id;
  final String name;
  final String? jumpUrl;

  factory DynamicTopic.fromJson(Map<String, dynamic> json) {
    return DynamicTopic(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      jumpUrl: json['jump_url'] as String?,
    );
  }
}

/// Statistics module.
class ModuleStat {
  const ModuleStat({
    this.like,
    this.comment,
    this.forward,
  });

  final StatItem? like;
  final StatItem? comment;
  final StatItem? forward;

  factory ModuleStat.fromJson(Map<String, dynamic> json) {
    return ModuleStat(
      like: json['like'] != null
          ? StatItem.fromJson(json['like'] as Map<String, dynamic>)
          : null,
      comment: json['comment'] != null
          ? StatItem.fromJson(json['comment'] as Map<String, dynamic>)
          : null,
      forward: json['forward'] != null
          ? StatItem.fromJson(json['forward'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Single stat item.
class StatItem {
  const StatItem({
    required this.count,
    this.forbidden = false,
    this.status,
  });

  final int count;
  final bool forbidden;

  /// For like: whether current user has liked
  final bool? status;

  factory StatItem.fromJson(Map<String, dynamic> json) {
    return StatItem(
      count: json['count'] as int? ?? 0,
      forbidden: json['forbidden'] as bool? ?? false,
      status: json['status'] as bool?,
    );
  }
}

/// More options module.
class ModuleMore {
  const ModuleMore({
    required this.threePointItems,
  });

  final List<ThreePointItem> threePointItems;

  factory ModuleMore.fromJson(Map<String, dynamic> json) {
    return ModuleMore(
      threePointItems: (json['three_point_items'] as List<dynamic>?)
              ?.map((e) => ThreePointItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Three-point menu item.
class ThreePointItem {
  const ThreePointItem({
    required this.label,
    required this.type,
  });

  final String label;
  final String type;

  factory ThreePointItem.fromJson(Map<String, dynamic> json) {
    return ThreePointItem(
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

/// Interaction module.
class ModuleInteraction {
  const ModuleInteraction({
    required this.items,
  });

  final List<InteractionItem> items;

  factory ModuleInteraction.fromJson(Map<String, dynamic> json) {
    return ModuleInteraction(
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => InteractionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Interaction item.
class InteractionItem {
  const InteractionItem({
    required this.desc,
    required this.type,
  });

  final InteractionDesc desc;
  final int type;

  factory InteractionItem.fromJson(Map<String, dynamic> json) {
    return InteractionItem(
      desc: InteractionDesc.fromJson(
          json['desc'] as Map<String, dynamic>? ?? {}),
      type: json['type'] as int? ?? 0,
    );
  }
}

/// Interaction description.
class InteractionDesc {
  const InteractionDesc({
    required this.text,
    this.richTextNodes,
  });

  final String text;
  final List<RichTextNode>? richTextNodes;

  factory InteractionDesc.fromJson(Map<String, dynamic> json) {
    return InteractionDesc(
      text: json['text'] as String? ?? '',
      richTextNodes: (json['rich_text_nodes'] as List<dynamic>?)
          ?.map((e) => RichTextNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Dynamic feed API response.
class DynamicFeedResponse {
  const DynamicFeedResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final DynamicFeedData? data;

  factory DynamicFeedResponse.fromJson(Map<String, dynamic> json) {
    return DynamicFeedResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? DynamicFeedData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => code == 0;
}

/// Dynamic feed data.
class DynamicFeedData {
  const DynamicFeedData({
    required this.items,
    required this.hasMore,
    this.offset,
    this.updateBaseline,
    this.updateNum,
  });

  final List<DynamicItem> items;
  final bool hasMore;

  /// Offset for next page
  final String? offset;

  /// Update baseline for checking new dynamics
  final String? updateBaseline;

  /// Number of new dynamics
  final int? updateNum;

  factory DynamicFeedData.fromJson(Map<String, dynamic> json) {
    return DynamicFeedData(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => DynamicItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
      offset: json['offset'] as String?,
      updateBaseline: json['update_baseline'] as String?,
      updateNum: json['update_num'] as int?,
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../core/utils/number_utils.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/global_snackbar.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../player/player.dart';
import '../../data/datasources/user_profile_remote_datasource.dart';
import '../../data/models/dynamic_item.dart';

const _uuid = Uuid();

/// Card widget for displaying a dynamic item.
///
/// Source: biu/src/pages/user-profile/dynamic-list/item.tsx
/// Like API: biu/src/service/web-dynamic-feed-thumb.ts
class DynamicCard extends ConsumerStatefulWidget {
  const DynamicCard({
    required this.item,
    super.key,
  });

  final DynamicItem item;

  @override
  ConsumerState<DynamicCard> createState() => _DynamicCardState();
}

class _DynamicCardState extends ConsumerState<DynamicCard> {
  late bool _isLiked;
  late int _likeCount;
  bool _isLiking = false;

  DynamicItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    final stat = item.modules.moduleStat;
    _isLiked = stat?.like?.status ?? false;
    _likeCount = stat?.like?.count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final author = item.modules.moduleAuthor;
    final dynamic = item.modules.moduleDynamic;
    final archive = dynamic.major?.videoInfo;
    final opus = dynamic.major?.opus;

    // Get text content
    final textContent =
        dynamic.desc?.text ?? opus?.summary?.text ?? '';

    // Format time - matches source: moment(pub_ts * 1000).fromNow()
    final timeDisplay = author.pubTime.isNotEmpty
        ? author.pubTime
        : date_utils.DateUtils.formatMomentStyleFromTimestamp(author.pubTs);

    return Card(
      color: AppColors.contentBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Time
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Text(
                  timeDisplay,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text content
                if (textContent.isNotEmpty) ...[
                  Text(
                    textContent,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                // Video content
                if (archive != null)
                  _buildVideoContent(context, archive),
                // Image content (from opus or draw)
                if (archive == null && opus != null && opus.pics.isNotEmpty)
                  _buildImageGrid(context, opus.pics),
                if (archive == null &&
                    opus == null &&
                    dynamic.major?.draw != null)
                  _buildDrawImageGrid(context, dynamic.major!.draw!),
              ],
            ),
          ),
          // Footer: Action buttons
          const Divider(height: 1, color: AppColors.divider),
          _buildActionFooter(context, archive),
        ],
      ),
    );
  }

  /// Build video content section.
  Widget _buildVideoContent(BuildContext context, MajorArchive archive) {
    return InkWell(
      onTap: () => _playVideo(archive),
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppTheme.borderRadius),
                  ),
                  child: SizedBox(
                    width: 160,
                    height: 90,
                    child: AppCachedImage(
                      imageUrl: archive.cover,
                      fileType: FileType.video,
                    ),
                  ),
                ),
                // Play icon overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppTheme.borderRadius),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.play_circle_fill,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                // Duration badge
                if (archive.durationText.isNotEmpty)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        archive.durationText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Video info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      archive.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (archive.desc.isNotEmpty)
                      Text(
                        archive.desc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // Stats
                    if (archive.stat != null)
                      Row(
                        children: [
                          Text(
                            archive.stat!.play,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '播放',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build image grid from opus pics.
  Widget _buildImageGrid(BuildContext context, List<OpusPic> pics) {
    if (pics.isEmpty) return const SizedBox.shrink();

    final imageCount = pics.length;

    // Single image
    if (imageCount == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: AppCachedImage(
            imageUrl: pics[0].src,
          ),
        ),
      );
    }

    // Multiple images - grid
    final crossAxisCount = imageCount <= 4 ? 2 : 3;
    final displayCount = imageCount > 9 ? 9 : imageCount;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        final isLast = index == displayCount - 1 && imageCount > 9;
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AppCachedImage(
                imageUrl: pics[index].src,
              ),
            ),
            if (isLast)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '+${imageCount - 9}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build image grid from draw items.
  Widget _buildDrawImageGrid(BuildContext context, MajorDraw draw) {
    if (draw.items.isEmpty) return const SizedBox.shrink();

    final pics = draw.items
        .map((e) => OpusPic(src: e.src, width: e.width, height: e.height))
        .toList();
    return _buildImageGrid(context, pics);
  }

  /// Build footer with action buttons.
  /// Source: biu/src/components/dynamic-feed/item.tsx
  Widget _buildActionFooter(BuildContext context, MajorArchive? archive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Open in browser
          if (archive != null)
            IconButton(
              onPressed: () => _openInBrowser(archive),
              icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 20),
              color: AppColors.textSecondary,
              tooltip: '在B站打开',
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          const Spacer(),
          // Like button with count
          // Source: shows count or "点赞" text when count is 0
          InkWell(
            onTap: _isLiking ? null : _toggleLike,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isLiked ? CupertinoIcons.hand_thumbsup_fill : CupertinoIcons.hand_thumbsup,
                    size: 18,
                    color: _isLiked ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _likeCount > 0 ? NumberUtils.formatCompact(_likeCount) : '点赞',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _isLiked
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle like state for this dynamic.
  ///
  /// Uses optimistic update pattern (matches source project behavior):
  /// 1. Update UI immediately for responsive feel
  /// 2. Call API in background
  /// 3. Revert on error (enhancement over source which ignores errors)
  ///
  /// Source: biu/src/pages/user-profile/dynamic-list/item.tsx#handleThumb
  Future<void> _toggleLike() async {
    if (_isLiking) return;

    final previousLiked = _isLiked;
    final previousCount = _likeCount;
    final newLikeState = !_isLiked;

    // Optimistic update - update UI first
    setState(() {
      _isLiking = true;
      _isLiked = newLikeState;
      _likeCount += newLikeState ? 1 : -1;
      if (_likeCount < 0) _likeCount = 0;
    });

    try {
      final dataSource = UserProfileRemoteDataSource();
      await dataSource.likeDynamic(
        dynIdStr: item.idStr,
        like: newLikeState,
      );
    } catch (e) {
      // Revert on error
      setState(() {
        _isLiked = previousLiked;
        _likeCount = previousCount;
      });
      GlobalSnackbar.showError('点赞失败');
    } finally {
      setState(() => _isLiking = false);
    }
  }

  /// Open video in browser.
  Future<void> _openInBrowser(MajorArchive archive) async {
    final url = 'https://www.bilibili.com/video/${archive.bvid}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      GlobalSnackbar.showError('无法打开浏览器');
    }
  }

  /// Play video from archive.
  void _playVideo(MajorArchive archive) {
    // Don't pass ownerMid to trigger fetching all pages
    // Source: biu/src/store/play-list.ts:527-535
    final playItem = PlayItem(
      id: _uuid.v4(),
      title: archive.title,
      type: PlayDataType.mv,
      bvid: archive.bvid,
      aid: archive.aid,
      cover: archive.cover,
      ownerName: item.modules.moduleAuthor.name,
      // ownerMid intentionally omitted to trigger multi-part fetch
    );

    ref.read(playlistProvider.notifier).play(playItem);
  }
}

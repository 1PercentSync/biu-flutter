import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../data/models/space_arc_search.dart';

/// Card widget for displaying a video post
/// Reference: biu/src/pages/user-profile/video-post.tsx
class VideoPostCard extends StatelessWidget {
  const VideoPostCard({
    required this.video,
    this.onTap,
    super.key,
  });

  final SpaceArcVListItem video;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.contentBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover image with duration badge
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.borderRadius),
                    ),
                    child: AppCachedImage(
                      imageUrl: video.pic,
                    ),
                  ),
                  // Duration badge
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
                        video.length,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Video info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with action menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      MediaActionMenu(
                        title: video.title,
                        bvid: video.bvid,
                        aid: video.aid.toString(),
                        cover: video.pic,
                        ownerName: video.author,
                        ownerMid: video.mid,
                        iconSize: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Stats row - shows date and duration like source
                  // Source: biu/src/pages/user-profile/video-post.tsx:71-76
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      Text(
                        _formatDate(video.createdDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      // Duration
                      Text(
                        video.length,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '今天';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (date.year == now.year) {
      return DateFormat('MM-dd').format(date);
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

/// List tile version of video post card
/// Source: biu/src/components/music-list-item/index.tsx
class VideoPostListTile extends StatelessWidget {
  const VideoPostListTile({
    required this.video,
    this.onTap,
    super.key,
  });

  final SpaceArcVListItem video;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.contentBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Thumbnail
              SizedBox(
                width: 48,
                height: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  child: AppCachedImage(
                    imageUrl: video.pic,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Video info (title + author)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Author
                    Text(
                      video.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Play count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _formatNumber(video.play),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              // Action menu
              MediaActionMenu(
                title: video.title,
                bvid: video.bvid,
                aid: video.aid.toString(),
                cover: video.pic,
                ownerName: video.author,
                ownerMid: video.mid,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 100000000) {
      return '${(num / 100000000).toStringAsFixed(2)}亿';
    } else if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(2)}万';
    }
    return num.toString();
  }
}

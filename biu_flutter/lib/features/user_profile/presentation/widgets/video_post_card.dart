import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
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
                      fit: BoxFit.cover,
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
                children: [
                  // Title
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Stats row
                  Row(
                    children: [
                      // Play count
                      const Icon(
                        Icons.play_arrow,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatNumber(video.play),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(width: 12),
                      // Comment count
                      const Icon(
                        Icons.comment,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatNumber(video.comment),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const Spacer(),
                      // Date
                      Text(
                        _formatDate(video.createdDate),
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

  String _formatNumber(int num) {
    if (num >= 100000000) {
      return '${(num / 100000000).toStringAsFixed(1)}B';
    } else if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(1)}W';
    }
    return num.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else if (date.year == now.year) {
      return DateFormat('MM-dd').format(date);
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

/// List tile version of video post card
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              SizedBox(
                width: 120,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                        child: AppCachedImage(
                          imageUrl: video.pic,
                          fit: BoxFit.cover,
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
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Video info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Stats
                    Row(
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatNumber(video.play),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.comment,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatNumber(video.comment),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Text(
                      _formatDate(video.createdDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 100000000) {
      return '${(num / 100000000).toStringAsFixed(1)}B';
    } else if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(1)}W';
    }
    return num.toString();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

import 'package:flutter/material.dart';

import '../../core/extensions/duration_extensions.dart';
import '../theme/theme.dart';
import 'cached_image.dart';

/// A card widget for displaying video content.
///
/// Shows cover image, title, author, view count, duration, etc.
class VideoCard extends StatelessWidget {
  const VideoCard({
    required this.title,
    super.key,
    this.coverUrl,
    this.ownerName,
    this.ownerAvatar,
    this.duration,
    this.viewCount,
    this.danmakuCount,
    this.pubDate,
    this.isActive = false,
    this.onTap,
    this.onLongPress,
  });

  /// Video title
  final String title;

  /// Cover image URL
  final String? coverUrl;

  /// Owner/author name
  final String? ownerName;

  /// Owner avatar URL
  final String? ownerAvatar;

  /// Video duration in seconds
  final int? duration;

  /// View count
  final int? viewCount;

  /// Danmaku (bullet comments) count
  final int? danmakuCount;

  /// Publish date (timestamp in seconds)
  final int? pubDate;

  /// Whether this video is currently active/selected
  final bool isActive;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Callback when long pressed
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.contentBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: isActive
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image with duration overlay
              _buildCoverSection(),
              // Info section
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildInfoSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          AppCachedImage(
            imageUrl: coverUrl,
            fit: BoxFit.cover,
            fileType: FileType.video,
          ),
          // Duration badge
          if (duration != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  Duration(seconds: duration!).formatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
        ),
        const SizedBox(height: 8),
        // Owner and stats
        Row(
          children: [
            // Owner avatar (optional)
            if (ownerAvatar != null) ...[
              ClipOval(
                child: AppCachedImage(
                  imageUrl: ownerAvatar,
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 6),
            ],
            // Owner name
            if (ownerName != null)
              Expanded(
                child: Text(
                  ownerName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Stats row
        _buildStatsRow(context),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final statStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textTertiary,
        );

    return Row(
      children: [
        // View count
        if (viewCount != null) ...[
          Icon(
            Icons.play_arrow,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 2),
          Text(
            _formatCount(viewCount!),
            style: statStyle,
          ),
          const SizedBox(width: 12),
        ],
        // Danmaku count
        if (danmakuCount != null) ...[
          Icon(
            Icons.comment,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 2),
          Text(
            _formatCount(danmakuCount!),
            style: statStyle,
          ),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }
}

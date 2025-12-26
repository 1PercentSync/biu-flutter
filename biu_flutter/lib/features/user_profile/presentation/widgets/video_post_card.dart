import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../../../shared/widgets/media_item.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../data/models/space_arc_search.dart';

/// Unified widget for displaying a video post.
///
/// Adapts to display mode (card/list) using MediaItem.
/// Source: biu/src/pages/user-profile/video-post.tsx
class VideoPostItem extends StatelessWidget {
  const VideoPostItem({
    required this.video,
    required this.displayMode,
    super.key,
    this.onTap,
    this.isActive = false,
  });

  final SpaceArcVListItem video;
  final DisplayMode displayMode;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return MediaItem(
      displayMode: displayMode,
      title: video.title,
      coverUrl: video.pic,
      ownerName: video.author,
      ownerMid: video.mid,
      duration: video.durationSeconds,
      viewCount: video.play,
      pubDate: video.created,
      isActive: isActive,
      footer: displayMode == DisplayMode.card ? _buildCardFooter(context) : null,
      actionWidget: _buildActionMenu(),
      onTap: onTap,
      onOwnerTap: () => context.push('/user/${video.mid}'),
    );
  }

  /// Card mode footer: date + duration
  /// Source: biu/src/pages/user-profile/video-post.tsx:71-76
  Widget _buildCardFooter(BuildContext context) {
    final statStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date
        Text(
          _formatDate(video.createdDate),
          style: statStyle,
        ),
        // Duration
        Text(
          video.length,
          style: statStyle,
        ),
      ],
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

  Widget _buildActionMenu() {
    return MediaActionMenu(
      title: video.title,
      bvid: video.bvid,
      aid: video.aid.toString(),
      cover: video.pic,
      ownerName: video.author,
      ownerMid: video.mid,
      iconSize: displayMode == DisplayMode.card ? 18 : 20,
    );
  }
}

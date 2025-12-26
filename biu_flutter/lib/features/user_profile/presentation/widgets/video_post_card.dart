import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/media_action_menu.dart';
import '../../../../shared/widgets/media_item.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../data/models/space_arc_search.dart';

/// Unified widget for displaying a video post.
///
/// Adapts to display mode (card/list) using MediaItem.
/// Uses iOS-style minimal design matching prototype.
/// Source: prototype/home_tabs_prototype.html
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
      isActive: isActive,
      aspectRatio: 1.0,
      actionWidget: _buildActionMenu(),
      onTap: onTap,
      onOwnerTap: () => context.push('/user/${video.mid}'),
    );
  }

  Widget _buildActionMenu() {
    return MediaActionMenu(
      title: video.title,
      bvid: video.bvid,
      aid: video.aid.toString(),
      cover: video.pic,
      ownerName: video.author,
      iconSize: displayMode == DisplayMode.card ? 18 : 20,
    );
  }
}

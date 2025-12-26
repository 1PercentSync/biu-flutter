import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/media_action_menu.dart';
import '../../../../shared/widgets/media_item.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../data/models/watch_later_item.dart';

/// Widget for displaying a watch later item.
///
/// Uses iOS-style minimal design matching prototype.
/// Source: biu/src/pages/later/index.tsx
class LaterItem extends StatelessWidget {
  const LaterItem({
    required this.item,
    required this.displayMode,
    super.key,
    this.onTap,
    this.onDelete,
    this.isActive = false,
  });

  final WatchLaterItem item;
  final DisplayMode displayMode;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return MediaItem(
      displayMode: displayMode,
      title: item.title,
      coverUrl: item.pic,
      ownerName: item.owner?.name,
      isActive: isActive,
      actionWidget: _buildActionMenu(context),
      onTap: onTap,
      onOwnerTap: item.owner?.mid != null
          ? () => context.push('/user/${item.owner!.mid}')
          : null,
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return MediaActionMenu(
      title: item.title,
      bvid: item.bvid,
      aid: item.aid.toString(),
      cid: item.cid.toString(),
      cover: item.pic,
      ownerName: item.owner?.name,
      showWatchLater: false,
      additionalActions: [
        if (onDelete != null)
          MediaActionItem(
            key: 'delete',
            icon: Icons.delete_outline,
            label: '删除',
            onTap: () {
              Navigator.pop(context);
              onDelete!();
            },
          ),
      ],
      iconSize: 18,
    );
  }
}

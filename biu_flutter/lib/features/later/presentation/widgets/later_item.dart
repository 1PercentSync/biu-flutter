import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/number_utils.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../../../shared/widgets/media_item.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../data/models/watch_later_item.dart';

/// Unified widget for displaying a watch later item.
///
/// Adapts to display mode (card/list) using MediaItem.
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
      ownerMid: item.owner?.mid,
      duration: item.duration,
      viewCount: item.stat?.view,
      isActive: isActive,
      footer: displayMode == DisplayMode.card ? _buildCardFooter(context) : null,
      actionWidget: _buildActionMenu(context),
      onTap: onTap,
      onOwnerTap: item.owner?.mid != null
          ? () => context.push('/user/${item.owner!.mid}')
          : null,
    );
  }

  /// Card mode footer: owner name + duration
  /// Source: biu/src/pages/later/index.tsx:107-114
  Widget _buildCardFooter(BuildContext context) {
    final statStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // View count with icon
        if ((item.stat?.view ?? 0) > 0)
          Row(
            children: [
              const Icon(
                Icons.play_arrow,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 2),
              Text(
                NumberUtils.formatCompact(item.stat!.view),
                style: statStyle,
              ),
            ],
          ),
        const SizedBox(height: 4),
        // Owner and duration
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: item.owner?.mid != null
                    ? () => GoRouter.of(context).push('/user/${item.owner!.mid}')
                    : null,
                child: Text(
                  item.owner?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: statStyle,
                ),
              ),
            ),
            Text(
              item.durationFormatted,
              style: statStyle?.copyWith(
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
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
      ownerMid: item.owner?.mid,
      showWatchLater: false, // Already in watch later page
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

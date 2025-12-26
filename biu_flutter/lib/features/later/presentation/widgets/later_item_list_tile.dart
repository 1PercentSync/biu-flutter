import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../data/models/watch_later_item.dart';

/// Format number for display (e.g., 10000 -> "1万")
String _formatNumber(int num) {
  if (num >= 100000000) {
    return '${(num / 100000000).toStringAsFixed(1)}亿';
  }
  if (num >= 10000) {
    return '${(num / 10000).toStringAsFixed(1)}万';
  }
  return num.toString();
}

/// List tile widget for displaying a watch later item in list mode.
/// Source: biu/src/components/music-list-item/index.tsx
/// Layout: [48x48 cover] [title + author] [playCount] [duration + action menu]
class LaterItemListTile extends StatelessWidget {
  const LaterItemListTile({
    required this.item,
    super.key,
    this.onTap,
    this.onDelete,
    this.isActive = false,
  });

  final WatchLaterItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      child: InkWell(
        onDoubleTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Cover image (48x48)
              _buildCover(context),
              const SizedBox(width: 8),
              // Title and author
              Expanded(child: _buildInfo(context)),
              const SizedBox(width: 16),
              // Play count
              _buildPlayCount(context),
              const SizedBox(width: 16),
              // Duration and action menu
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppCachedImage(
              imageUrl: item.pic,
              fileType: FileType.video,
            ),
            // Play icon overlay on hover (for desktop) - always visible on mobile
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive ? AppColors.primary : null,
              ),
        ),
        const SizedBox(height: 4),
        // Author (clickable)
        GestureDetector(
          onTap: item.owner?.mid != null
              ? () => context.push('/user/${item.owner!.mid}')
              : null,
          child: Text(
            item.owner?.name ?? '未知',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayCount(BuildContext context) {
    // Source: biu/src/components/music-list-item/index.tsx:90-92
    if ((item.stat?.view ?? 0) <= 0) {
      return const SizedBox(width: 60);
    }
    return SizedBox(
      width: 60,
      child: Text(
        _formatNumber(item.stat!.view),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Duration
        Text(
          item.durationFormatted,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
        ),
        const SizedBox(width: 8),
        // Action menu
        MediaActionMenu(
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
        ),
      ],
    );
  }
}

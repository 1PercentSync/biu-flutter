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

/// Card widget for displaying a watch later item in card/grid mode.
/// Source: biu/src/pages/later/index.tsx - card mode uses MVCard with
/// cover (with playCount overlay), title, footer (owner link + duration)
class LaterItemCard extends StatelessWidget {
  const LaterItemCard({
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.contentBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: isActive
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image with play count
              _buildCover(),
              // Title with action menu
              _buildTitle(context),
              // Footer: owner link + duration
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.borderRadius),
            ),
            child: AppCachedImage(
              imageUrl: item.pic,
              fileType: FileType.video,
            ),
          ),
          // Play count overlay at bottom left
          // Source: biu/src/components/mv-card/index.tsx - playCount shown at bottom
          if ((item.stat?.view ?? 0) > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          if ((item.stat?.view ?? 0) > 0)
            Positioned(
              left: 8,
              bottom: 6,
              child: Row(
                children: [
                  const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatNumber(item.stat!.view),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
            ),
          ),
          // Action menu with delete option
          // Source: biu/src/pages/later/index.tsx - menus=[{key:"delete"}]
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
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    // Source: biu/src/pages/later/index.tsx:107-114 - footer shows owner link + duration
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Owner name (clickable)
          Expanded(
            child: GestureDetector(
              onTap: item.owner?.mid != null
                  ? () => context.push('/user/${item.owner!.mid}')
                  : null,
              child: Text(
                item.owner?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ),
          // Duration
          Text(
            item.durationFormatted,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}

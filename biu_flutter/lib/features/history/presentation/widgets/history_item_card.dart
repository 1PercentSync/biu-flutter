import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../data/models/history_item.dart';

/// Card widget for displaying a history item in list mode.
/// Source: biu/src/pages/history/index.tsx - list mode only shows cover, title, author
class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    required this.item,
    super.key,
    this.onTap,
    this.isActive = false,
  });

  final HistoryItem item;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.contentBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: isActive
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Cover image with duration (no progress bar in list mode)
              _buildCover(),
              const SizedBox(width: 12),
              // Info section (only title and author in list mode)
              Expanded(child: _buildInfo(context)),
              // Action menu (includes watch later option)
              // Source: biu/src/components/mv-action/index.tsx - history page shows watch later
              if (item.isPlayable)
                MediaActionMenu(
                  title: item.title,
                  bvid: item.history.bvid ?? '',
                  aid: item.history.oid.toString(),
                  cover: item.cover,
                  ownerName: item.authorName,
                  ownerMid: item.authorMid,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return SizedBox(
      width: 48,
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: AppCachedImage(
          imageUrl: item.cover,
          fileType: FileType.video,
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    // List mode only shows title and author
    // Source: biu/src/pages/history/index.tsx:165-166
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
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        // Author - clickable when authorMid exists
        // Source: biu/src/pages/history/index.tsx:142-145
        if (item.authorName != null)
          item.authorMid != null
              ? GestureDetector(
                  onTap: () => context.push('/user/${item.authorMid}'),
                  child: Text(
                    item.authorName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                )
              : Text(
                  item.authorName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
      ],
    );
  }
}

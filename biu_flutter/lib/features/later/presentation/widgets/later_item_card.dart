import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/watch_later_item.dart';

/// Card widget for displaying a watch later item
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image with duration
              _buildCover(),
              const SizedBox(width: 12),
              // Info section
              Expanded(child: _buildInfo(context)),
              // Delete button
              if (onDelete != null) _buildDeleteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return SizedBox(
      width: 120,
      height: 68,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            child: AppCachedImage(
              imageUrl: item.pic,
              fit: BoxFit.cover,
              fileType: FileType.video,
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
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                item.durationFormatted,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          // Progress bar
          if (item.progress > 0 && item.duration > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.borderRadiusSmall),
                  bottomRight: Radius.circular(AppTheme.borderRadiusSmall),
                ),
                child: LinearProgressIndicator(
                  value: item.progressRatio,
                  minHeight: 3,
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
        ),
        const SizedBox(height: 6),
        // Author
        if (item.owner != null)
          Text(
            item.owner!.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        const SizedBox(height: 4),
        // Add time and view count
        Row(
          children: [
            Text(
              item.addAtFormatted,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
            if (item.stat != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.play_circle_outline,
                size: 12,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 2),
              Text(
                item.stat!.viewFormatted,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.delete_outline,
        color: AppColors.textTertiary,
        size: 20,
      ),
      onPressed: onDelete,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/search_result.dart';

/// Card widget for displaying user search results
class UserSearchCard extends StatelessWidget {
  const UserSearchCard({
    required this.user, super.key,
    this.onTap,
  });

  final SearchUserItem user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo(context)),
              _buildFansCount(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        ClipOval(
          child: AppCachedImage(
            imageUrl: user.upic,
            width: 48,
            height: 48,
            placeholder: Container(
              width: 48,
              height: 48,
              color: AppColors.surfaceElevated,
              child: const Icon(
                Icons.person,
                color: AppColors.textTertiary,
              ),
            ),
            errorWidget: Container(
              width: 48,
              height: 48,
              color: AppColors.surfaceElevated,
              child: const Icon(
                Icons.person,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
        if (user.isOfficial)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.uname,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.level != null) ...[
              const SizedBox(width: 4),
              _buildLevelBadge(user.level!),
            ],
          ],
        ),
        if (user.usign.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            user.usign,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (user.officialDesc != null && user.officialDesc!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            user.officialDesc!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildLevelBadge(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: _getLevelColor(level).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'LV$level',
        style: TextStyle(
          color: _getLevelColor(level),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 6) return Colors.orange;
    if (level >= 5) return Colors.deepOrange;
    if (level >= 4) return Colors.blue;
    if (level >= 3) return Colors.green;
    return Colors.grey;
  }

  Widget _buildFansCount(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user.fansFormatted,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        Text(
          'followers',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

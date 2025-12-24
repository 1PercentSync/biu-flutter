import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/following_user.dart';

/// Card displaying a following user's info
class FollowingCard extends StatelessWidget {
  const FollowingCard({
    required this.user,
    this.onTap,
    this.onUnfollow,
    super.key,
  });

  final FollowingUser user;
  final VoidCallback? onTap;
  final VoidCallback? onUnfollow;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.contentBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Stack(
                children: [
                  ClipOval(
                    child: user.face != null
                        ? AppCachedImage(
                            imageUrl: user.face!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 72,
                            height: 72,
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.person,
                              size: 36,
                              color: AppColors.textTertiary,
                            ),
                          ),
                  ),
                  // VIP badge
                  if (user.vip?.isVip == true)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Name with verification icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      user.uname,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (user.isVerified)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.verified,
                        size: 14,
                        color: user.officialVerify?.type == 0
                            ? Colors.amber
                            : Colors.blue,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Signature
              Text(
                user.sign?.isNotEmpty == true ? user.sign! : 'No signature',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.isMutual)
                    _buildBadge(
                      context,
                      'Mutual',
                      Colors.green.withOpacity(0.2),
                      Colors.green,
                    ),
                  if (user.isSpecial)
                    _buildBadge(
                      context,
                      'Special',
                      Colors.orange.withOpacity(0.2),
                      Colors.orange,
                    ),
                ],
              ),
              const Spacer(),
              // Unfollow button
              if (onUnfollow != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onUnfollow,
                    icon: const Icon(Icons.person_remove, size: 16),
                    label: const Text('Unfollow'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String text,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontSize: 10,
            ),
      ),
    );
  }
}

/// List tile version of following user card
class FollowingListTile extends StatelessWidget {
  const FollowingListTile({
    required this.user,
    this.onTap,
    this.onUnfollow,
    super.key,
  });

  final FollowingUser user;
  final VoidCallback? onTap;
  final VoidCallback? onUnfollow;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.contentBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipOval(
          child: user.face != null
              ? AppCachedImage(
                  imageUrl: user.face!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.person,
                    size: 24,
                    color: AppColors.textTertiary,
                  ),
                ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                user.uname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isVerified)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.verified,
                  size: 14,
                  color: user.officialVerify?.type == 0
                      ? Colors.amber
                      : Colors.blue,
                ),
              ),
            if (user.vip?.isVip == true)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'VIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (user.isMutual)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Mutual',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          user.sign?.isNotEmpty == true ? user.sign! : 'No signature',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: onUnfollow != null
            ? IconButton(
                icon: const Icon(Icons.person_remove),
                onPressed: onUnfollow,
                tooltip: 'Unfollow',
              )
            : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/user_badges.dart';
import '../../data/models/following_user.dart';

// ══════════════════════════════════════════════════════════════════════════
// Helper Functions
// ══════════════════════════════════════════════════════════════════════════

/// Get signature text with fallback.
String _getSignatureText(FollowingUser user) {
  return user.sign?.isNotEmpty ?? false ? user.sign! : '暂无签名';
}

// ══════════════════════════════════════════════════════════════════════════
// Public Widgets
// ══════════════════════════════════════════════════════════════════════════

/// Card displaying a following user's info
///
/// Uses shared UserAvatar and badge widgets for consistent UI.
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
              // Avatar with VIP badge
              UserAvatar(
                avatarUrl: user.face,
                size: 72,
                showVipBadge: user.vip?.isVip ?? false,
              ),
              const SizedBox(height: 8),
              // Name with verification icon
              _buildNameRow(context),
              const SizedBox(height: 4),
              // Signature
              Text(
                _getSignatureText(user),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Badges row
              _buildBadgesRow(),
              const Spacer(),
              // Unfollow button
              if (onUnfollow != null) _buildUnfollowButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameRow(BuildContext context) {
    return Row(
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
            child: VerificationIcon(type: user.officialVerify?.type ?? 1),
          ),
      ],
    );
  }

  Widget _buildBadgesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (user.isMutual)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: MutualFollowBadge(),
          ),
        if (user.isSpecial)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: SpecialAttentionBadge(),
          ),
      ],
    );
  }

  Widget _buildUnfollowButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onUnfollow,
        icon: const Icon(Icons.person_remove, size: 16),
        label: const Text('取消关注'),
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
    );
  }
}

/// List tile version of following user card
///
/// Uses shared UserAvatar and badge widgets for consistent UI.
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
        leading: UserAvatar(
          avatarUrl: user.face,
          showVipBadge: user.vip?.isVip ?? false,
        ),
        title: _buildTitleRow(),
        subtitle: Text(
          _getSignatureText(user),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: onUnfollow != null
            ? IconButton(
                icon: const Icon(Icons.person_remove),
                onPressed: onUnfollow,
                tooltip: '取消关注',
              )
            : null,
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
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
            child: VerificationIcon(type: user.officialVerify?.type ?? 1),
          ),
        if (user.vip?.isVip ?? false)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: VipBadge(),
          ),
        if (user.isMutual)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: MutualFollowBadge(),
          ),
      ],
    );
  }
}

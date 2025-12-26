import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/following_user.dart';

// ══════════════════════════════════════════════════════════════════════════
// Shared Helper Widgets
// ══════════════════════════════════════════════════════════════════════════

/// Build user avatar with optional VIP badge overlay.
Widget _buildUserAvatar(FollowingUser user, {required double size}) {
  return Stack(
    children: [
      ClipOval(
        child: user.face != null
            ? AppCachedImage(
                imageUrl: user.face,
                width: size,
                height: size,
              )
            : Container(
                width: size,
                height: size,
                color: AppColors.surface,
                child: Icon(
                  Icons.person,
                  size: size / 2,
                  color: AppColors.textTertiary,
                ),
              ),
      ),
      // VIP badge on avatar
      if (user.vip?.isVip ?? false)
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
  );
}

/// Build verification icon based on official verify type.
Widget? _buildVerificationIcon(FollowingUser user) {
  if (!user.isVerified) return null;
  return Icon(
    Icons.verified,
    size: 14,
    color: user.officialVerify?.type == 0 ? Colors.amber : Colors.blue,
  );
}

/// Build inline VIP badge.
Widget _buildVipBadge() {
  return Container(
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
  );
}

/// Build mutual follow badge.
Widget _buildMutualBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(
      color: Colors.green.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      'Mutual',
      style: TextStyle(
        color: Colors.green,
        fontSize: 10,
      ),
    ),
  );
}

/// Build special badge.
Widget _buildSpecialBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(
      color: Colors.orange.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      'Special',
      style: TextStyle(
        color: Colors.orange,
        fontSize: 10,
      ),
    ),
  );
}

/// Get signature text with fallback.
String _getSignatureText(FollowingUser user) {
  return user.sign?.isNotEmpty ?? false ? user.sign! : 'No signature';
}

// ══════════════════════════════════════════════════════════════════════════
// Public Widgets
// ══════════════════════════════════════════════════════════════════════════

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
              // Avatar with VIP badge
              _buildUserAvatar(user, size: 72),
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
    final verificationIcon = _buildVerificationIcon(user);

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
        if (verificationIcon != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: verificationIcon,
          ),
      ],
    );
  }

  Widget _buildBadgesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (user.isMutual)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildMutualBadge(),
          ),
        if (user.isSpecial)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildSpecialBadge(),
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
        leading: _buildUserAvatar(user, size: 48),
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
    final verificationIcon = _buildVerificationIcon(user);

    return Row(
      children: [
        Flexible(
          child: Text(
            user.uname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (verificationIcon != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: verificationIcon,
          ),
        if (user.vip?.isVip ?? false)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _buildVipBadge(),
          ),
        if (user.isMutual)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _buildMutualBadge(),
          ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/number_utils.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/space_acc_info.dart';
import '../../data/models/space_relation.dart';

/// Header widget displaying user space info
/// Reference: biu/src/pages/user-profile/space-info.tsx
class SpaceInfoHeader extends StatelessWidget {
  const SpaceInfoHeader({
    required this.spaceInfo,
    this.relationStat,
    this.relationData,
    this.isSelf = false,
    this.isLoggedIn = false,
    this.onFollowTap,
    super.key,
  });

  final SpaceAccInfo spaceInfo;
  final RelationStat? relationStat;
  final SpaceRelationData? relationData;
  final bool isSelf;
  final bool isLoggedIn;
  final VoidCallback? onFollowTap;

  bool get _isFollowing => relationData?.relation.isFollowing ?? false;
  bool get _isBlocked =>
      relationData?.relation.relation == UserRelation.blocked;

  @override
  Widget build(BuildContext context) {
    // Show blocked state
    if (_isBlocked) {
      return _buildBlockedView(context);
    }

    return _buildNormalView(context);
  }

  Widget _buildBlockedView(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      color: AppColors.contentBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatar(size: 100),
          const SizedBox(height: 16),
          Text(
            'Blocked',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalView(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: _getBackgroundImage(),
        color: AppColors.contentBackground,
      ),
      child: Container(
        // Dark overlay
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildUserInfo(context),
              const SizedBox(height: 16),
              _buildStats(context),
            ],
          ),
        ),
      ),
    );
  }

  DecorationImage? _getBackgroundImage() {
    final topPhoto =
        spaceInfo.topPhotoV2?.l200hImg ?? spaceInfo.topPhoto;
    if (topPhoto != null && topPhoto.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(topPhoto),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildUserInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar
        _buildAvatar(size: 80),
        const SizedBox(width: 16),
        // Name and info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Name row
              Row(
                children: [
                  // Verification icon
                  if (spaceInfo.isVerified)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 18,
                        color: spaceInfo.official?.isPersonalVerified ?? false
                            ? Colors.amber
                            : Colors.blue,
                      ),
                    ),
                  // Name
                  Flexible(
                    child: Text(
                      spaceInfo.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // VIP badge
                  if (spaceInfo.vip?.label?.imgLabelUriHansStatic case final vipLabel?)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: AppCachedImage(
                        imageUrl: vipLabel,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Signature
              if (spaceInfo.sign.isNotEmpty)
                Text(
                  spaceInfo.sign,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar({required double size}) {
    // Source: biu/src/pages/user-profile/space-info.tsx:82
    // Avatar without VIP badge overlay (VIP shown as label next to name)
    return ClipOval(
      child: AppCachedImage(
        imageUrl: spaceInfo.face,
        width: size,
        height: size,
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        // Follow button
        if (isLoggedIn && !isSelf)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildFollowButton(context),
          ),
        // Stats
        if (isLoggedIn) ...[
          // Following count (only for self)
          if (isSelf) ...[
            _buildStatItem(
              context,
              '关注',
              relationStat?.following ?? 0,
            ),
            const SizedBox(width: 16),
          ],
          // Follower count
          _buildStatItem(
            context,
            '粉丝',
            relationStat?.follower ?? 0,
          ),
          const SizedBox(width: 16),
          // Level
          _buildLevelBadge(context),
        ],
      ],
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onFollowTap,
      icon: Icon(
        _isFollowing ? CupertinoIcons.checkmark : CupertinoIcons.add,
        size: 16,
      ),
      label: Text(_isFollowing ? '已关注' : '关注'),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isFollowing ? Theme.of(context).primaryColor : Colors.white24,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(80, 36),
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int value) {
    return Column(
      children: [
        Text(
          NumberUtils.formatCompact(value),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget _buildLevelBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getLevelColor(spaceInfo.level),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Lv${spaceInfo.level}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.grey.shade600;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      case 6:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

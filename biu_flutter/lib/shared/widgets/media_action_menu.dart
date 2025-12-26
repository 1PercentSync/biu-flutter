import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/audio.dart';
import '../../features/auth/auth.dart';
import '../../features/later/data/datasources/later_remote_datasource.dart';
import '../../features/player/player.dart';
import '../theme/theme.dart';
import '../utils/global_snackbar.dart';

/// Action menu item definition
class MediaActionItem {
  const MediaActionItem({
    required this.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.hidden = false,
  });

  final String key;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool hidden;
}

/// Reusable action menu for media items (songs, videos).
///
/// Source: biu/src/components/mv-action/index.tsx
/// Provides options like:
/// - Play next (下一首播放)
/// - Add to favorites (收藏)
/// - Add to watch later (添加到稍后再看)
class MediaActionMenu extends ConsumerWidget {
  const MediaActionMenu({
    required this.title,
    required this.bvid,
    super.key,
    this.aid,
    this.cid,
    this.cover,
    this.ownerName,
    this.ownerMid,
    this.type = PlayDataType.mv,
    this.showWatchLater = true,
    this.additionalActions,
    this.iconSize = 20,
    this.iconColor,
  });

  /// Media title
  final String title;

  /// Video bvid
  final String bvid;

  /// Video aid (optional)
  final String? aid;

  /// Video cid (optional)
  final String? cid;

  /// Cover image URL
  final String? cover;

  /// Owner/Author name
  final String? ownerName;

  /// Owner mid
  final int? ownerMid;

  /// Media type
  final PlayDataType type;

  /// Whether to show "Add to watch later" option
  final bool showWatchLater;

  /// Additional custom actions
  final List<MediaActionItem>? additionalActions;

  /// Icon size
  final double iconSize;

  /// Icon color (defaults to theme)
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authNotifierProvider).isAuthenticated;

    return IconButton(
      icon: Icon(
        CupertinoIcons.ellipsis,
        size: iconSize,
        color: iconColor ?? AppColors.textSecondary,
      ),
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(
        minWidth: 28,
        minHeight: 28,
      ),
      onPressed: () => _showActionSheet(context, ref, isLoggedIn),
    );
  }

  void _showActionSheet(BuildContext context, WidgetRef ref, bool isLoggedIn) {
    final actions = _buildActions(context, ref, isLoggedIn);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.contentBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 1),
            // Action items
            ...actions
                .where((a) => !a.hidden)
                .map((action) => _buildActionTile(context, action)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<MediaActionItem> _buildActions(
      BuildContext context, WidgetRef ref, bool isLoggedIn) {
    return [
      // Play next
      MediaActionItem(
        key: 'playNext',
        icon: CupertinoIcons.text_badge_plus,
        label: '下一首播放',
        onTap: () {
          Navigator.pop(context);
          _addToNext(ref);
        },
      ),
      // Add to favorites
      MediaActionItem(
        key: 'collect',
        icon: CupertinoIcons.star,
        label: '收藏',
        hidden: !isLoggedIn,
        onTap: () {
          Navigator.pop(context);
          _showFavoritesDialog(context);
        },
      ),
      // Add to watch later
      MediaActionItem(
        key: 'watchLater',
        icon: CupertinoIcons.clock,
        label: '添加到稍后再看',
        hidden: !isLoggedIn || !showWatchLater,
        onTap: () {
          Navigator.pop(context);
          _addToWatchLater(context);
        },
      ),
      // Additional custom actions
      ...?additionalActions,
    ];
  }

  Widget _buildActionTile(BuildContext context, MediaActionItem action) {
    return ListTile(
      leading: Icon(action.icon, color: AppColors.textPrimary),
      title: Text(action.label),
      onTap: action.onTap,
    );
  }

  void _addToNext(WidgetRef ref) {
    final playItem = PlayItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type,
      bvid: bvid,
      aid: aid,
      cid: cid,
      cover: cover,
      ownerName: ownerName,
      ownerMid: ownerMid,
    );

    ref.read(playlistProvider.notifier).addToNext(playItem);
    GlobalSnackbar.showSuccess('已添加到下一首播放');
  }

  void _showFavoritesDialog(BuildContext context) {
    // TODO: Implement favorites selection dialog
    GlobalSnackbar.showInfo('收藏功能开发中');
  }

  Future<void> _addToWatchLater(BuildContext context) async {
    try {
      final datasource = LaterRemoteDataSource();
      await datasource.addToWatchLater(bvid: bvid);
      GlobalSnackbar.showSuccess('已添加到稍后再看');
    } on LaterNotLoggedInException {
      GlobalSnackbar.showError('请先登录');
    } on LaterListFullException {
      GlobalSnackbar.showError('稍后再看列表已满');
    } catch (e) {
      GlobalSnackbar.showError('添加失败');
    }
  }
}

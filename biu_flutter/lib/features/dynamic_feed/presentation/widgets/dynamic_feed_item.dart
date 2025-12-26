import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/global_snackbar.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../player/player.dart';
import '../../../user_profile/data/models/dynamic_item.dart';

const _uuid = Uuid();

/// Item widget for displaying a dynamic in the feed drawer.
///
/// Shows author info, content, and video card with action menu.
/// Source: biu/src/components/dynamic-feed/item.tsx
class DynamicFeedItem extends ConsumerWidget {
  const DynamicFeedItem({
    required this.item,
    this.onClose,
    super.key,
  });

  final DynamicItem item;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final author = item.modules.moduleAuthor;
    final dynamic = item.modules.moduleDynamic;
    final archive = dynamic.major?.videoInfo;

    // Get text content
    final textContent =
        dynamic.desc?.text ?? dynamic.major?.opus?.summary?.text ?? '';

    // Format time - use API provided time or format from timestamp
    final timeDisplay = author.pubTime.isNotEmpty
        ? author.pubTime
        : date_utils.DateUtils.formatMomentStyleFromTimestamp(author.pubTs);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.contentBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header
            _buildAuthorHeader(context, ref, author, timeDisplay, archive),
            const SizedBox(height: 8),

            // Text content
            if (textContent.isNotEmpty) ...[
              Text(
                textContent,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],

            // Video content
            if (archive != null) _buildVideoCard(context, ref, archive, author),
          ],
        ),
      ),
    );
  }

  /// Build author header with avatar, name, time, and action menu.
  Widget _buildAuthorHeader(
    BuildContext context,
    WidgetRef ref,
    ModuleAuthor author,
    String timeDisplay,
    MajorArchive? archive,
  ) {
    return Row(
      children: [
        // Avatar (clickable to user profile)
        GestureDetector(
          onTap: () {
            onClose?.call();
            context.push(AppRoutes.userSpacePath(author.mid));
          },
          child: UserAvatar(
            avatarUrl: author.face,
            size: 40,
          ),
        ),
        const SizedBox(width: 10),

        // Name and time
        Expanded(
          child: GestureDetector(
            onTap: () {
              onClose?.call();
              context.push(AppRoutes.userSpacePath(author.mid));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      timeDisplay,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (author.pubAction != null &&
                        author.pubAction!.isNotEmpty) ...[
                      Text(
                        ' · ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        author.pubAction!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        // More menu button (if has video)
        // Source: biu/src/components/dynamic-feed/more-menu.tsx
        if (archive != null)
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 20),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => _showMoreMenu(context, ref, archive, author),
          ),
      ],
    );
  }

  /// Show more menu with action options.
  /// Source: biu/src/components/dynamic-feed/more-menu.tsx
  void _showMoreMenu(
    BuildContext context,
    WidgetRef ref,
    MajorArchive archive,
    ModuleAuthor author,
  ) {
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
            // Add to next play
            ListTile(
              leading:
                  const Icon(Icons.playlist_add, color: AppColors.textPrimary),
              title: const Text('添加到下一首播放'),
              onTap: () {
                Navigator.pop(context);
                _addToNext(ref, archive, author);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Add video to next in playlist.
  /// Source: biu/src/components/dynamic-feed/item.tsx - onAddToNext
  void _addToNext(WidgetRef ref, MajorArchive archive, ModuleAuthor author) {
    final playItem = PlayItem(
      id: _uuid.v4(),
      title: archive.title,
      type: PlayDataType.mv,
      bvid: archive.bvid,
      aid: archive.aid,
      cover: archive.cover,
      ownerName: author.name,
      ownerMid: author.mid,
    );

    ref.read(playlistProvider.notifier).addToNext(playItem);
    GlobalSnackbar.showSuccess('已添加到下一首播放');
  }

  /// Build video card content.
  Widget _buildVideoCard(
    BuildContext context,
    WidgetRef ref,
    MajorArchive archive,
    ModuleAuthor author,
  ) {
    return InkWell(
      onTap: () => _playVideo(ref, archive, author),
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail (no duration badge - matching source)
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppTheme.borderRadius),
              ),
              child: SizedBox(
                width: 160,
                height: 90,
                child: AppCachedImage(
                  imageUrl: archive.cover,
                  fileType: FileType.video,
                ),
              ),
            ),
            // Video info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      archive.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (archive.desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        archive.desc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Stats - matching source: "{play}观看"
                    if (archive.stat != null)
                      Text(
                        '${archive.stat!.play}观看',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Play video and close drawer.
  void _playVideo(WidgetRef ref, MajorArchive archive, ModuleAuthor author) {
    final playItem = PlayItem(
      id: _uuid.v4(),
      title: archive.title,
      type: PlayDataType.mv,
      bvid: archive.bvid,
      aid: archive.aid,
      cover: archive.cover,
      ownerName: author.name,
      ownerMid: author.mid,
    );

    ref.read(playlistProvider.notifier).play(playItem);
    onClose?.call();
  }

}

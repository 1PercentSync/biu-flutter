import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/global_snackbar.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../player/player.dart';
import '../../data/models/dynamic_item.dart';

const _uuid = Uuid();

/// Card widget for displaying a dynamic item.
/// Source: biu/src/pages/user-profile/dynamic-list/item.tsx
class DynamicCard extends ConsumerWidget {
  const DynamicCard({
    required this.item,
    super.key,
  });

  final DynamicItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final author = item.modules.moduleAuthor;
    final dynamic = item.modules.moduleDynamic;
    final archive = dynamic.major?.videoInfo;
    final opus = dynamic.major?.opus;

    // Get text content
    final textContent =
        dynamic.desc?.text ?? opus?.summary?.text ?? '';

    // Format time
    final timeDisplay = author.pubTime.isNotEmpty
        ? author.pubTime
        : _formatTime(author.pubTs);

    return Card(
      color: AppColors.contentBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Time
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Text(
                  timeDisplay,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text content
                if (textContent.isNotEmpty) ...[
                  Text(
                    textContent,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                // Video content
                if (archive != null)
                  _buildVideoContent(context, ref, archive),
                // Image content (from opus or draw)
                if (archive == null && opus != null && opus.pics.isNotEmpty)
                  _buildImageGrid(context, opus.pics),
                if (archive == null &&
                    opus == null &&
                    dynamic.major?.draw != null)
                  _buildDrawImageGrid(context, dynamic.major!.draw!),
              ],
            ),
          ),
          // Footer: Action buttons
          if (archive != null) ...[
            const Divider(height: 1, color: AppColors.divider),
            _buildActionFooter(context, ref, archive),
          ],
        ],
      ),
    );
  }

  /// Build video content section.
  Widget _buildVideoContent(
      BuildContext context, WidgetRef ref, MajorArchive archive) {
    return InkWell(
      onTap: () => _playVideo(ref, archive),
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
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
                // Play icon overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppTheme.borderRadius),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                // Duration badge
                if (archive.durationText.isNotEmpty)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        archive.durationText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Video info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      archive.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (archive.desc.isNotEmpty)
                      Text(
                        archive.desc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // Stats
                    if (archive.stat != null)
                      Row(
                        children: [
                          Text(
                            archive.stat!.play,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '播放',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                          ),
                        ],
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

  /// Build image grid from opus pics.
  Widget _buildImageGrid(BuildContext context, List<OpusPic> pics) {
    if (pics.isEmpty) return const SizedBox.shrink();

    final imageCount = pics.length;

    // Single image
    if (imageCount == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: AppCachedImage(
            imageUrl: pics[0].src,
          ),
        ),
      );
    }

    // Multiple images - grid
    final crossAxisCount = imageCount <= 4 ? 2 : 3;
    final displayCount = imageCount > 9 ? 9 : imageCount;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        final isLast = index == displayCount - 1 && imageCount > 9;
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AppCachedImage(
                imageUrl: pics[index].src,
              ),
            ),
            if (isLast)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '+${imageCount - 9}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build image grid from draw items.
  Widget _buildDrawImageGrid(BuildContext context, MajorDraw draw) {
    if (draw.items.isEmpty) return const SizedBox.shrink();

    final pics = draw.items
        .map((e) => OpusPic(src: e.src, width: e.width, height: e.height))
        .toList();
    return _buildImageGrid(context, pics);
  }

  /// Build footer with action buttons.
  /// Source: biu/src/components/dynamic-feed/more-menu.tsx
  Widget _buildActionFooter(
      BuildContext context, WidgetRef ref, MajorArchive archive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Open in B站
          TextButton.icon(
            onPressed: () => _openInBrowser(archive),
            icon: const Icon(Icons.open_in_browser, size: 16),
            label: const Text('在B站打开'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          const SizedBox(width: 8),
          // Add to play next
          TextButton.icon(
            onPressed: () => _addToPlayNext(ref, archive),
            icon: const Icon(Icons.playlist_add, size: 16),
            label: const Text('下一首播放'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// Open video in browser.
  Future<void> _openInBrowser(MajorArchive archive) async {
    final url = 'https://www.bilibili.com/video/${archive.bvid}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      GlobalSnackbar.showError('无法打开浏览器');
    }
  }

  /// Add video to play next.
  void _addToPlayNext(WidgetRef ref, MajorArchive archive) {
    final playItem = PlayItem(
      id: _uuid.v4(),
      title: archive.title,
      type: PlayDataType.mv,
      bvid: archive.bvid,
      aid: archive.aid,
      cover: archive.cover,
      ownerName: item.modules.moduleAuthor.name,
      ownerMid: item.modules.moduleAuthor.mid,
      duration: _parseDuration(archive.durationText),
    );

    ref.read(playlistProvider.notifier).addToNext(playItem);
    GlobalSnackbar.showSuccess('已添加到下一首播放');
  }

  /// Format timestamp to relative time.
  String _formatTime(int timestamp) {
    if (timestamp == 0) return '';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}-${date.day}';
    }
  }

  /// Play video from archive.
  void _playVideo(WidgetRef ref, MajorArchive archive) {
    final playItem = PlayItem(
      id: _uuid.v4(),
      title: archive.title,
      type: PlayDataType.mv,
      bvid: archive.bvid,
      aid: archive.aid,
      cover: archive.cover,
      ownerName: item.modules.moduleAuthor.name,
      ownerMid: item.modules.moduleAuthor.mid,
      duration: _parseDuration(archive.durationText),
    );

    ref.read(playlistProvider.notifier).play(playItem);
  }

  /// Parse duration text to seconds.
  int _parseDuration(String durationText) {
    if (durationText.isEmpty) return 0;

    final parts = durationText.split(':').reversed.toList();
    var seconds = 0;
    for (var i = 0; i < parts.length; i++) {
      final value = int.tryParse(parts[i]) ?? 0;
      seconds += value * _pow(60, i);
    }
    return seconds;
  }

  /// Simple power function.
  int _pow(int base, int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}

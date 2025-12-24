import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/extensions/duration_extensions.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../player/domain/entities/play_item.dart';
import '../../../player/presentation/providers/playlist_notifier.dart';
import '../../domain/entities/fav_media.dart';
import '../providers/favorites_notifier.dart';
import '../providers/favorites_state.dart';

/// Folder detail screen showing folder resources.
class FolderDetailScreen extends ConsumerWidget {
  const FolderDetailScreen({
    required this.folderId,
    super.key,
  });

  final int folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(folderDetailProvider(folderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.isLoading && state.folder == null
          ? const Center(child: CircularProgressIndicator())
          : state.hasError && state.folder == null
              ? _buildError(context, ref, state.errorMessage!)
              : _buildContent(context, ref, state),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load folder',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () =>
                ref.read(folderDetailProvider(folderId).notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, FolderDetailState state) {
    final folder = state.folder!;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(folderDetailProvider(folderId).notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // App bar with folder cover
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (folder.cover.isNotEmpty)
                    AppCachedImage(
                      imageUrl: folder.cover,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: AppColors.contentBackground),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.8),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Folder info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          folder.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (folder.isPrivate)
                        Chip(
                          label: const Text('Private'),
                          avatar: const Icon(Icons.lock, size: 14),
                          labelStyle: const TextStyle(fontSize: 12),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (folder.upper.face.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(folder.upper.face),
                          ),
                        ),
                      Text(
                        folder.upper.name,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.video_library_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${folder.mediaCount} items',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (folder.intro.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      folder.intro,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Divider
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          // Media list
          if (state.medias.isEmpty && !state.isLoading)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icon(
                  Icons.video_library_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                title: 'No Items',
                message: 'This folder is empty',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= state.medias.length) {
                    // Load more
                    if (state.hasMore && !state.isLoadingMore) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(folderDetailProvider(folderId).notifier)
                            .loadMore();
                      });
                    }
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final media = state.medias[index];
                  return _MediaListItem(
                    media: media,
                    onTap: () => _playMedia(context, ref, media),
                  );
                },
                childCount:
                    state.medias.length + (state.hasMore || state.isLoadingMore ? 1 : 0),
              ),
            ),
        ],
      ),
    );
  }

  void _playMedia(BuildContext context, WidgetRef ref, FavMedia media) {
    if (media.isInvalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This content is no longer available')),
      );
      return;
    }

    // Play the media using playlist notifier
    ref.read(playlistProvider.notifier).play(
          PlayItem(
            id: '${media.bvid}_1',
            type: PlayDataType.mv,
            bvid: media.bvid,
            title: media.title,
            ownerName: media.upper.name,
            cover: media.cover,
            duration: media.duration,
          ),
        );
  }
}

class _MediaListItem extends StatelessWidget {
  const _MediaListItem({
    required this.media,
    required this.onTap,
  });

  final FavMedia media;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 120,
              height: 68,
              child: media.cover.isNotEmpty
                  ? AppCachedImage(
                      imageUrl: media.cover,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.contentBackground,
                      child: const Icon(
                        Icons.video_library,
                        color: AppColors.textTertiary,
                      ),
                    ),
            ),
          ),
          // Duration badge
          if (media.duration > 0)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  Duration(seconds: media.duration).formatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          // Invalid overlay
          if (media.isInvalid)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.block,
                    color: Colors.white54,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        media.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: media.isInvalid ? AppColors.textTertiary : null,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            media.upper.name,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          if (media.playCount > 0)
            Text(
              '${_formatCount(media.playCount)} plays',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
        ],
      ),
      onTap: media.isInvalid ? null : onTap,
    );
  }

  String _formatCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }
}

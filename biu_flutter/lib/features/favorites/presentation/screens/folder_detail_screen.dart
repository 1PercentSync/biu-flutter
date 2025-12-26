import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/extensions/duration_extensions.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/global_snackbar.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../../auth/auth.dart';
import '../../../player/domain/entities/play_item.dart';
import '../../../player/presentation/providers/playlist_notifier.dart';
import '../../domain/entities/fav_media.dart';
import '../../domain/entities/favorites_folder.dart';
import '../providers/favorites_notifier.dart';
import '../providers/favorites_state.dart';
import '../widgets/folder_edit_dialog.dart';

/// Folder detail screen showing folder resources.
///
/// Source: biu/src/pages/video-collection/favorites.tsx#Favorites
class FolderDetailScreen extends ConsumerStatefulWidget {
  const FolderDetailScreen({
    required this.folderId,
    super.key,
  });

  final int folderId;

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  /// Debounce timer for keyword search
  /// Source: biu/src/pages/video-collection/favorites.tsx
  /// Source project uses refreshDeps to auto-refresh on keyword change
  Timer? _keywordDebounceTimer;
  static const _keywordDebounceDuration = Duration(milliseconds: 300);

  @override
  void dispose() {
    _keywordDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(folderDetailProvider(widget.folderId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.isLoading && state.folder == null
          ? const Center(child: CircularProgressIndicator())
          : state.hasError && state.folder == null
              ? _buildError(context, ref, state.errorMessage!)
              : _buildContent(context, ref, state, user),
      bottomNavigationBar:
          state.isSelectionMode ? _buildSelectionBar(context, ref, state) : null,
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load folder',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () =>
                ref.read(folderDetailProvider(widget.folderId).notifier).refresh(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FolderDetailState state,
    User? user,
  ) {
    final folder = state.folder!;
    final isOwner = user?.mid == folder.upper.mid;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(folderDetailProvider(widget.folderId).notifier).refresh(),
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
            child: _buildFolderInfo(context, ref, folder, state, isOwner),
          ),
          // Search and filter bar
          SliverToBoxAdapter(
            child: _buildSearchFilterBar(context, ref, state),
          ),
          // Divider
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          // Media list
          if (state.medias.isEmpty && !state.isLoading)
            SliverFillRemaining(
              child: EmptyState(
                icon: const Icon(
                  Icons.video_library_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                title: state.keyword.isNotEmpty ? '无结果' : '暂无内容',
                message: state.keyword.isNotEmpty
                    ? '没有找到匹配的内容'
                    : '这个收藏夹是空的',
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
                            .read(folderDetailProvider(widget.folderId).notifier)
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
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderInfo(
    BuildContext context,
    WidgetRef ref,
    FavoritesFolder folder,
    FolderDetailState state,
    bool isOwner,
  ) {
    return Padding(
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
                const Chip(
                  label: Text('私密'),
                  avatar: Icon(Icons.lock, size: 14),
                  labelStyle: TextStyle(fontSize: 12),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Show type and count info
          // Source: biu/src/pages/video-collection/info/index.tsx:109-117
          Text(
            '${isOwner && folder.isPrivate ? "私密" : ""}收藏夹 · ${folder.mediaCount}个视频',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          if (folder.intro.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              folder.intro,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // Play button and action menu
          // Source: biu/src/pages/video-collection/info/index.tsx:119-131
          // Always show action buttons if folder has content (use folder.mediaCount, not filtered medias)
          if (folder.mediaCount > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _playAll(context, ref, state),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('播放全部'),
                ),
                const SizedBox(width: 12),
                // Action menu button
                IconButton(
                  onPressed: () => _showFolderActionMenu(context, ref, folder, state, isOwner),
                  icon: const Icon(Icons.more_horiz),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchFilterBar(
    BuildContext context,
    WidgetRef ref,
    FolderDetailState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search input
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: '搜索...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: state.keyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(folderDetailProvider(widget.folderId).notifier)
                              .setKeyword('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: AppColors.contentBackground,
                isDense: true,
              ),
              // Source: biu/src/pages/video-collection/favorites.tsx
              // Source project updates results on every keystroke (via refreshDeps)
              onChanged: (value) {
                _keywordDebounceTimer?.cancel();
                _keywordDebounceTimer = Timer(_keywordDebounceDuration, () {
                  ref
                      .read(folderDetailProvider(widget.folderId).notifier)
                      .setKeyword(value.trim());
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // Sort dropdown
          PopupMenuButton<FolderSortOrder>(
            initialValue: state.order,
            onSelected: (order) {
              ref
                  .read(folderDetailProvider(widget.folderId).notifier)
                  .setOrder(order);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.contentBackground,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.order.label,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
            itemBuilder: (context) => FolderSortOrder.values
                .map(
                  (order) => PopupMenuItem(
                    value: order,
                    child: Row(
                      children: [
                        if (order == state.order)
                          const Icon(Icons.check, size: 18)
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(order.label),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Show action menu for the folder.
  /// Source: biu/src/pages/video-collection/info/menu.tsx
  void _showFolderActionMenu(
    BuildContext context,
    WidgetRef ref,
    FavoritesFolder folder,
    FolderDetailState state,
    bool isOwner,
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
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                folder.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 1),
            // Add to playlist
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('添加到播放列表'),
              onTap: () {
                Navigator.pop(context);
                _addAllToQueue(context, ref, state);
              },
            ),
            // Edit (only for owner, attr != 0 means not default folder)
            // Source: biu/src/pages/video-collection/info/menu.tsx:148-153
            if (isOwner && folder.attr != 0)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('修改信息'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditFolderDialog(context, ref, folder);
                },
              ),
            // Delete (only for owner, attr != 0 means not default folder)
            // Source: biu/src/pages/video-collection/info/menu.tsx:154-179
            if (isOwner && folder.attr != 0)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteFolderDialog(context, ref, folder);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Show edit folder dialog.
  void _showEditFolderDialog(
    BuildContext context,
    WidgetRef ref,
    FavoritesFolder folder,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => FolderEditDialog(
        folderId: folder.id,
        initialTitle: folder.title,
        initialIntro: folder.intro,
        initialIsPublic: !folder.isPrivate,
        onSubmit: ({
          required String title,
          required String intro,
          required bool isPublic,
        }) async {
          final repository = ref.read(favoritesRepositoryProvider);
          try {
            await repository.editFolder(
              mediaId: folder.id,
              title: title,
              intro: intro,
              isPublic: isPublic,
            );
            // Refresh folder detail
            await ref.read(folderDetailProvider(widget.folderId).notifier).refresh();
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
              GlobalSnackbar.showSuccess('收藏夹更新成功');
            }
            return true;
          } catch (e) {
            GlobalSnackbar.showError('更新收藏夹失败: $e');
            return false;
          }
        },
      ),
    );
  }

  /// Show delete folder confirmation dialog.
  void _showDeleteFolderDialog(
    BuildContext context,
    WidgetRef ref,
    FavoritesFolder folder,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除收藏夹'),
        content: Text('确定要删除"${folder.title}"吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success = await ref
                  .read(favoritesListProvider.notifier)
                  .deleteFolders([folder.id]);
              if (success && context.mounted) {
                GlobalSnackbar.showSuccess('收藏夹已删除');
                // Go back to favorites list
                context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(
    BuildContext context,
    WidgetRef ref,
    FolderDetailState state,
  ) {
    final user = ref.watch(currentUserProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.contentBackground,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Delete
            _SelectionActionButton(
              icon: Icons.delete_outline,
              label: '删除',
              enabled: state.hasSelection,
              onPressed: () => _confirmBatchDelete(context, ref, state),
            ),
            // Move
            _SelectionActionButton(
              icon: Icons.drive_file_move_outline,
              label: '移动',
              enabled: state.hasSelection,
              onPressed: () => _showFolderPicker(
                context,
                ref,
                '移动到',
                (folderId) async {
                  if (user == null) return;
                  final success = await ref
                      .read(folderDetailProvider(widget.folderId).notifier)
                      .batchMoveSelected(
                        targetFolderId: folderId,
                        userMid: user.mid,
                      );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('移动成功')),
                    );
                  }
                },
              ),
            ),
            // Copy
            _SelectionActionButton(
              icon: Icons.copy_outlined,
              label: '复制',
              enabled: state.hasSelection,
              onPressed: () => _showFolderPicker(
                context,
                ref,
                '复制到',
                (folderId) async {
                  if (user == null) return;
                  final success = await ref
                      .read(folderDetailProvider(widget.folderId).notifier)
                      .batchCopySelected(
                        targetFolderId: folderId,
                        userMid: user.mid,
                      );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('复制成功')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playAll(BuildContext context, WidgetRef ref, FolderDetailState state) {
    final validMedias = state.medias.where((m) => !m.isInvalid).toList();
    if (validMedias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有可播放的内容')),
      );
      return;
    }

    // Convert to PlayItems and play
    final playItems = validMedias.map(_mediaToPlayItem).toList();
    ref.read(playlistProvider.notifier).playList(playItems);
  }

  void _addAllToQueue(BuildContext context, WidgetRef ref, FolderDetailState state) {
    final validMedias = state.medias.where((m) => !m.isInvalid).toList();
    if (validMedias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有可添加的内容')),
      );
      return;
    }

    // Convert to PlayItems and add to queue
    final playItems = validMedias.map(_mediaToPlayItem).toList();
    ref.read(playlistProvider.notifier).addList(playItems);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已添加 ${playItems.length} 首到播放列表')),
    );
  }

  PlayItem _mediaToPlayItem(FavMedia media) {
    if (media.isAudio) {
      return PlayItem(
        id: 'audio_${media.id}',
        type: PlayDataType.audio,
        sid: media.id,
        title: media.title,
        ownerName: media.upper.name,
        ownerMid: media.upper.mid,
        cover: media.cover,
        duration: media.duration,
      );
    } else {
      return PlayItem(
        id: '${media.bvid}_1',
        type: PlayDataType.mv,
        bvid: media.bvid,
        aid: media.id.toString(),
        title: media.title,
        ownerName: media.upper.name,
        ownerMid: media.upper.mid,
        cover: media.cover,
        duration: media.duration,
      );
    }
  }

  void _playMedia(BuildContext context, WidgetRef ref, FavMedia media) {
    if (media.isInvalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该内容已失效')),
      );
      return;
    }

    ref.read(playlistProvider.notifier).play(_mediaToPlayItem(media));
  }

  void _confirmBatchDelete(
    BuildContext context,
    WidgetRef ref,
    FolderDetailState state,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除内容'),
        content: Text(
          'Are you sure you want to delete ${state.selectedCount} items from this folder?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(folderDetailProvider(widget.folderId).notifier)
                  .batchDeleteSelected();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showFolderPicker(
    BuildContext context,
    WidgetRef ref,
    String title,
    Future<void> Function(int folderId) onSelect,
  ) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final foldersState = ref.read(favoritesListProvider);
    final folders = foldersState.createdFolders
        .where((f) => f.id != widget.folderId)
        .toList();

    if (folders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有其他收藏夹')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return ListTile(
                    leading: folder.cover.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AppCachedImage(
                              imageUrl: folder.cover,
                              width: 48,
                              height: 48,
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.contentBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.folder),
                          ),
                    title: Text(folder.title),
                    subtitle: Text('${folder.mediaCount} items'),
                    onTap: () {
                      Navigator.pop(context);
                      onSelect(folder.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
                    )
                  : const ColoredBox(
                      color: AppColors.contentBackground,
                      child: Icon(
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
              child: DecoratedBox(
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          if (media.playCount > 0)
            Text(
              NumberUtils.formatCompact(media.playCount),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
        ],
      ),
      // Action menu (replaces watch later button)
      // Source: biu/src/components/music-list-item/index.tsx:96-108
      trailing: !media.isInvalid
          ? MediaActionMenu(
              title: media.title,
              bvid: media.bvid,
              aid: media.id.toString(),
              cover: media.cover,
              ownerName: media.upper.name,
              ownerMid: media.upper.mid,
            )
          : null,
      onTap: media.isInvalid ? null : onTap,
    );
  }
}

class _SelectionActionButton extends StatelessWidget {
  const _SelectionActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: enabled ? null : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: enabled ? null : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

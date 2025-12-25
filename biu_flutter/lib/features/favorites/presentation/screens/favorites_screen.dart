import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../domain/entities/favorites_folder.dart';
import '../providers/favorites_notifier.dart';
import '../widgets/folder_edit_dialog.dart';

/// Show dialog to create a new folder.
///
/// Extracted to top-level to avoid duplication in FavoritesScreen and _CreatedFoldersTab.
void _showCreateFolderDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    builder: (context) => FolderEditDialog(
      onSubmit: ({
        required String title,
        required String intro,
        required bool isPublic,
      }) async {
        final notifier = ref.read(favoritesListProvider.notifier);
        final success = await notifier.createFolder(
          title: title,
          intro: intro,
          isPublic: isPublic,
        );
        if (success && context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('收藏夹创建成功')),
          );
        }
        return success;
      },
    ),
  );
}

/// Favorites screen showing user's favorite collections.
///
/// Source: biu/src/pages/video-collection/index.tsx#VideoCollection
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppColors.background,
                title: const Text('收藏夹'),
                actions: [
                  IconButton(
                    onPressed: () => _showCreateFolderDialog(context, ref),
                    icon: const Icon(Icons.create_new_folder_outlined),
                    tooltip: '新建收藏夹',
                  ),
                ],
                bottom: const TabBar(
                  tabs: [
                    Tab(text: '创建的'),
                    Tab(text: '收藏的'),
                  ],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  dividerColor: Colors.transparent,
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _CreatedFoldersTab(),
              _CollectedFoldersTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatedFoldersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesListProvider);
    final hiddenIds = ref.watch(hiddenFolderIdsProvider);

    // Filter out hidden folders
    final visibleFolders = state.createdFolders
        .where((folder) => !hiddenIds.contains(folder.id))
        .toList();

    if (state.isLoadingCreated && visibleFolders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (visibleFolders.isEmpty) {
      return EmptyState(
        icon: const Icon(
          Icons.folder_special,
          size: 48,
          color: AppColors.textTertiary,
        ),
        title: '暂无创建的收藏夹',
        message: '创建收藏夹来整理你的收藏',
        action: ElevatedButton.icon(
          onPressed: () => _showCreateFolderDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('新建收藏夹'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(favoritesListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: visibleFolders.length + (state.createdHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= visibleFolders.length) {
            // Load more
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(favoritesListProvider.notifier).loadMoreCreatedFolders();
            });
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _FolderListItem(
            folder: visibleFolders[index],
            showMenu: true,
            onTap: () => context.push(
              AppRoutes.favoritesFolderPath(visibleFolders[index].id),
            ),
          );
        },
      ),
    );
  }
}

class _CollectedFoldersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesListProvider);
    final hiddenIds = ref.watch(hiddenFolderIdsProvider);

    // Filter out hidden folders
    final visibleFolders = state.collectedFolders
        .where((folder) => !hiddenIds.contains(folder.id))
        .toList();

    if (state.isLoadingCollected && visibleFolders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (visibleFolders.isEmpty) {
      return const EmptyState(
        icon: Icon(
          Icons.bookmark,
          size: 48,
          color: AppColors.textTertiary,
        ),
        title: '暂无收藏的收藏夹',
        message: '收藏其他用户的收藏夹',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(favoritesListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: visibleFolders.length + (state.collectedHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= visibleFolders.length) {
            // Load more
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(favoritesListProvider.notifier)
                  .loadMoreCollectedFolders();
            });
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _FolderListItem(
            folder: visibleFolders[index],
            showMenu: false,
            onTap: () => context.push(
              AppRoutes.favoritesFolderPath(visibleFolders[index].id),
            ),
          );
        },
      ),
    );
  }
}

class _FolderListItem extends StatelessWidget {
  const _FolderListItem({
    required this.folder,
    required this.showMenu,
    required this.onTap,
  });

  final FavoritesFolder folder;
  final bool showMenu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 64,
          height: 64,
          child: folder.cover.isNotEmpty
              ? AppCachedImage(
                  imageUrl: folder.cover,
                )
              : const ColoredBox(
                  color: AppColors.contentBackground,
                  child: Icon(
                    Icons.folder,
                    color: AppColors.textTertiary,
                  ),
                ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              folder.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (folder.isPrivate)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.lock,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${folder.mediaCount} items',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: showMenu
          ? IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showFolderMenu(context),
            )
          : null,
      onTap: onTap,
    );
  }

  void _showFolderMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.contentBackground,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.of(context).pop();
                _showEditDialog(context);
              },
            ),
            if (!folder.isDefault)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmation(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, child) => FolderEditDialog(
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
              ref.read(favoritesListProvider.notifier).updateFolder(
                    folderId: folder.id,
                    title: title,
                    intro: intro,
                    isPublic: isPublic,
                  );
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('收藏夹更新成功')),
                );
              }
              return true;
            } catch (e) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('更新收藏夹失败: $e')),
                );
              }
              return false;
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, child) => AlertDialog(
          title: const Text('删除收藏夹'),
          content: Text('确定要删除"${folder.title}"吗？'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('收藏夹已删除')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        ),
      ),
    );
  }
}

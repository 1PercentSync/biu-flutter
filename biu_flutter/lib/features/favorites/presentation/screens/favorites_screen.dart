import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/favorites_folder.dart';
import '../providers/favorites_notifier.dart';
import '../widgets/folder_edit_dialog.dart';

/// Favorites screen showing user's favorite collections.
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
                title: const Text('Favorites'),
                actions: [
                  IconButton(
                    onPressed: () => _showCreateFolderDialog(context, ref),
                    icon: const Icon(Icons.create_new_folder_outlined),
                    tooltip: 'Create Folder',
                  ),
                ],
                bottom: TabBar(
                  tabs: const [
                    Tab(text: 'Created'),
                    Tab(text: 'Collected'),
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

  void _showCreateFolderDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => FolderEditDialog(
        onSubmit: (title, intro, isPublic) async {
          final notifier = ref.read(favoritesListProvider.notifier);
          final success = await notifier.createFolder(
            title: title,
            intro: intro,
            isPublic: isPublic,
          );
          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Folder created successfully')),
            );
          }
          return success;
        },
      ),
    );
  }
}

class _CreatedFoldersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesListProvider);

    if (state.isLoadingCreated && state.createdFolders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.createdFolders.isEmpty) {
      return EmptyState(
        icon: Icon(
          Icons.folder_special,
          size: 48,
          color: AppColors.textTertiary,
        ),
        title: 'No Created Folders',
        message: 'Create a folder to organize your favorites',
        action: ElevatedButton.icon(
          onPressed: () => _showCreateFolderDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Create Folder'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(favoritesListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.createdFolders.length + (state.createdHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.createdFolders.length) {
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
            folder: state.createdFolders[index],
            showMenu: true,
            onTap: () => context.push(
              AppRoutes.favoritesFolderPath(state.createdFolders[index].id),
            ),
          );
        },
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => FolderEditDialog(
        onSubmit: (title, intro, isPublic) async {
          final notifier = ref.read(favoritesListProvider.notifier);
          final success = await notifier.createFolder(
            title: title,
            intro: intro,
            isPublic: isPublic,
          );
          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Folder created successfully')),
            );
          }
          return success;
        },
      ),
    );
  }
}

class _CollectedFoldersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesListProvider);

    if (state.isLoadingCollected && state.collectedFolders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.collectedFolders.isEmpty) {
      return EmptyState(
        icon: Icon(
          Icons.bookmark,
          size: 48,
          color: AppColors.textTertiary,
        ),
        title: 'No Collected Folders',
        message: 'Collect folders from other users',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(favoritesListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount:
            state.collectedFolders.length + (state.collectedHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.collectedFolders.length) {
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
            folder: state.collectedFolders[index],
            showMenu: false,
            onTap: () => context.push(
              AppRoutes.favoritesFolderPath(state.collectedFolders[index].id),
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
                  fit: BoxFit.cover,
                )
              : Container(
                  color: AppColors.contentBackground,
                  child: const Icon(
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
            Padding(
              padding: const EdgeInsets.only(left: 4),
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
        style: TextStyle(
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.contentBackground,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                _showEditDialog(context);
              },
            ),
            if (!folder.isDefault)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
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
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, child) => FolderEditDialog(
          folderId: folder.id,
          initialTitle: folder.title,
          initialIntro: folder.intro,
          initialIsPublic: !folder.isPrivate,
          onSubmit: (title, intro, isPublic) async {
            final repository = ref.read(favoritesRepositoryProvider);
            try {
              await repository.editFolder(
                mediaId: folder.id,
                title: title,
                intro: intro,
                isPublic: isPublic,
              );
              ref.read(favoritesListProvider.notifier).updateFolder(
                    folder.id,
                    title,
                    intro,
                    isPublic,
                  );
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Folder updated successfully')),
                );
              }
              return true;
            } catch (e) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Failed to update folder: $e')),
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
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, child) => AlertDialog(
          title: const Text('Delete Folder'),
          content: Text('Are you sure you want to delete "${folder.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await ref
                    .read(favoritesListProvider.notifier)
                    .deleteFolders([folder.id]);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Folder deleted')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

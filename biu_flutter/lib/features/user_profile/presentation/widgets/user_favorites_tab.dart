import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../favorites/data/models/folder_response.dart';
import '../providers/user_profile_notifier.dart';

/// User favorites tab widget
///
/// Displays user's public folders in a grid layout
/// Source: biu/src/pages/user-profile/favorites.tsx
class UserFavoritesTab extends ConsumerStatefulWidget {
  const UserFavoritesTab({
    required this.mid,
    super.key,
  });

  final int mid;

  @override
  ConsumerState<UserFavoritesTab> createState() => _UserFavoritesTabState();
}

class _UserFavoritesTabState extends ConsumerState<UserFavoritesTab> {
  @override
  void initState() {
    super.initState();
    // Load folders when tab is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider(widget.mid).notifier).loadUserFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileProvider(widget.mid));
    final folders = state.userFolders ?? [];
    final isLoading = state.isLoadingFolders;

    if (isLoading && folders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (folders.isEmpty) {
      return const EmptyState(
        icon: Icon(
          Icons.folder_outlined,
          size: 48,
          color: Color(0xFF9CA3AF),
        ),
        title: 'No folders',
        message: 'No public folders available',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) => _FolderCard(
        folder: folders[index],
        onTap: () => _navigateToFolder(folders[index]),
      ),
    );
  }

  void _navigateToFolder(FolderModel folder) {
    context.push('/collection/${folder.id}?type=favorite');
  }
}

/// Folder card widget
class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.folder,
    this.onTap,
  });

  final FolderModel folder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AppCachedImage(
                imageUrl: folder.cover,
              ),
            ),
            // Folder info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      folder.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    // Footer: date and count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateTime.fromMillisecondsSinceEpoch(
                            folder.ctime * 1000,
                          ).toDateString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        Text(
                          '${folder.mediaCount} items',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/empty_state.dart';

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
              // Created favorites
              _buildFolderList(context, isCreated: true),
              // Collected favorites
              _buildFolderList(context, isCreated: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderList(BuildContext context, {required bool isCreated}) {
    // TODO: Implement actual favorites list
    return EmptyState(
      icon: Icon(
        isCreated ? Icons.folder_special : Icons.bookmark,
        size: 48,
        color: AppColors.textTertiary,
      ),
      title: isCreated ? 'No Created Folders' : 'No Collected Folders',
      message: isCreated
          ? 'Create a folder to organize your favorites'
          : 'Collect folders from other users',
      action: isCreated
          ? ElevatedButton.icon(
              onPressed: () {
                // TODO: Create folder
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Folder'),
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../providers/favorites_notifier.dart';

/// Bottom sheet for selecting folders to add a resource to.
class FolderSelectSheet extends ConsumerWidget {
  const FolderSelectSheet({
    required this.resourceId,
    required this.title,
    this.onComplete,
    super.key,
  });

  /// Resource id (avid or bvid)
  final String resourceId;

  /// Title shown in the header
  final String title;

  /// Callback when selection is completed
  final VoidCallback? onComplete;

  /// Show the folder select sheet.
  static Future<void> show({
    required BuildContext context,
    required String resourceId,
    required String title,
    VoidCallback? onComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.contentBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FolderSelectSheet(
        resourceId: resourceId,
        title: title,
        onComplete: onComplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(folderSelectProvider(resourceId));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        state.isSubmitting || !state.hasChanges ? null : () => _submit(context, ref),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm'),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.folders.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: state.folders.length,
                          itemBuilder: (context, index) {
                            final folder = state.folders[index];
                            final isSelected =
                                state.selectedIds.contains(folder.id);

                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: state.isSubmitting
                                  ? null
                                  : (_) => ref
                                      .read(folderSelectProvider(resourceId)
                                          .notifier)
                                      .toggleSelection(folder.id),
                              title: Text(
                                folder.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${folder.mediaCount} items',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              secondary: folder.isPrivate
                                  ? const Icon(
                                      Icons.lock,
                                      size: 18,
                                      color: AppColors.textTertiary,
                                    )
                                  : null,
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            'No folders',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(folderSelectProvider(resourceId).notifier)
        .submit();

    if (success && context.mounted) {
      Navigator.of(context).pop();
      onComplete?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/folder_select_sheet.dart' as shared;
import '../providers/favorites_notifier.dart';

/// Bottom sheet for selecting folders to add a resource to.
///
/// This is a connector widget that bridges the shared FolderSelectSheet with
/// the favorites provider, maintaining proper layer separation.
///
/// Source: biu/src/components/favorites-select-modal/index.tsx#FavoritesSelectModal
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

    // Convert FolderSelectState to shared.FolderSelectSheetState
    final sheetState = shared.FolderSelectSheetState(
      folders: state.folders
          .map((folder) => shared.FolderSelectItem(
                id: folder.id,
                title: folder.title,
                mediaCount: folder.mediaCount,
                isPrivate: folder.isPrivate,
              ))
          .toList(),
      selectedIds: state.selectedIds,
      isLoading: state.isLoading,
      isSubmitting: state.isSubmitting,
      hasChanges: state.hasChanges,
    );

    return shared.FolderSelectSheet(
      title: title,
      state: sheetState,
      onToggleSelection: (folderId) {
        ref.read(folderSelectProvider(resourceId).notifier).toggleSelection(folderId);
      },
      onSubmit: () async {
        final success = await ref.read(folderSelectProvider(resourceId).notifier).submit();
        if (success) {
          onComplete?.call();
        }
        return success;
      },
    );
  }
}

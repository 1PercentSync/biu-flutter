import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Data model for a folder item in the selection sheet.
///
/// This is a simplified model that only contains the fields needed for display,
/// decoupling the widget from the features layer.
class FolderSelectItem {
  const FolderSelectItem({
    required this.id,
    required this.title,
    required this.mediaCount,
    required this.isPrivate,
  });

  final int id;
  final String title;
  final int mediaCount;
  final bool isPrivate;
}

/// State for the folder selection sheet.
///
/// This is a presentation-only state that does not depend on any features layer.
class FolderSelectSheetState {
  const FolderSelectSheetState({
    this.folders = const [],
    this.selectedIds = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasChanges = false,
  });

  final List<FolderSelectItem> folders;
  final List<int> selectedIds;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasChanges;
}

/// Bottom sheet for selecting a favorites folder.
///
/// This widget is decoupled from the features layer and receives state and
/// callbacks as parameters, making it reusable across different contexts.
///
/// Source: biu/src/layout/playbar/right/mv-fav-folder-select.tsx
class FolderSelectSheet extends StatelessWidget {
  const FolderSelectSheet({
    required this.title,
    required this.state,
    required this.onToggleSelection,
    required this.onSubmit,
    super.key,
  });

  /// Title shown in the header
  final String title;

  /// Current state of the folder selection
  final FolderSelectSheetState state;

  /// Callback when a folder selection is toggled
  final void Function(int folderId) onToggleSelection;

  /// Callback when the submit button is pressed
  /// Should return true on success, false on failure
  final Future<bool> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
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
                    onPressed: state.isSubmitting || !state.hasChanges
                        ? null
                        : () => _submit(context),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('确定'),
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
                                  : (_) => onToggleSelection(folder.id),
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

  Future<void> _submit(BuildContext context) async {
    final success = await onSubmit();

    if (success && context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新成功')),
      );
    }
  }
}

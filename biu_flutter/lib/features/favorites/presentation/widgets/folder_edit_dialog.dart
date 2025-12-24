import 'package:flutter/material.dart';

/// Callback signature for folder submission.
typedef FolderSubmitCallback = Future<bool> Function({
  required String title,
  required String intro,
  required bool isPublic,
});

/// Dialog for creating or editing a favorites folder.
///
/// Source: biu/src/components/favorites-edit-modal/index.tsx#FavoritesEditModal
class FolderEditDialog extends StatefulWidget {
  const FolderEditDialog({
    required this.onSubmit,
    this.folderId,
    this.initialTitle = '',
    this.initialIntro = '',
    this.initialIsPublic = true,
    super.key,
  });

  /// Folder id for editing, null for creating
  final int? folderId;

  /// Initial title
  final String initialTitle;

  /// Initial description
  final String initialIntro;

  /// Initial public state
  final bool initialIsPublic;

  /// Callback when submitting the form
  final FolderSubmitCallback onSubmit;

  @override
  State<FolderEditDialog> createState() => _FolderEditDialogState();
}

class _FolderEditDialogState extends State<FolderEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _introController;
  late bool _isPublic;
  bool _isSubmitting = false;
  String? _titleError;

  bool get _isEditing => widget.folderId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _introController = TextEditingController(text: widget.initialIntro);
    _isPublic = widget.initialIsPublic;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _validateTitle() {
    final title = _titleController.text.trim();
    setState(() {
      if (title.isEmpty) {
        _titleError = 'Title is required';
      } else if (title.length > 20) {
        _titleError = 'Title must be 20 characters or less';
      } else {
        _titleError = null;
      }
    });
  }

  Future<void> _submit() async {
    _validateTitle();
    if (_titleError != null) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await widget.onSubmit(
      title: _titleController.text.trim(),
      intro: _introController.text.trim(),
      isPublic: _isPublic,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (!success) {
        // Show error if not handled by parent
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Folder' : 'Create Folder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter folder name',
                errorText: _titleError,
                border: const OutlineInputBorder(),
              ),
              maxLength: 20,
              enabled: !_isSubmitting,
              onChanged: (_) => _validateTitle(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _introController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Brief description of this folder',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Public'),
              subtitle: Text(
                _isPublic
                    ? 'Anyone can view this folder'
                    : 'Only you can view this folder',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _isPublic,
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _isPublic = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ||
                  _titleController.text.trim().isEmpty ||
                  _titleError != null
              ? null
              : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}

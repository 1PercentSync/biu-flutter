import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Type of confirm dialog affecting button color.
///
/// Source: biu/src/components/confirm-modal/index.tsx#ConfirmModalType
enum ConfirmDialogType {
  warning,
  danger,
}

/// A confirmation dialog with async support and loading state.
///
/// Features:
/// - Async onConfirm callback with loading indicator
/// - Type-based button coloring (warning/danger)
/// - Prevents dismissal during loading
/// - Auto-closes on successful confirmation
///
/// Source: biu/src/components/confirm-modal/index.tsx#ConfirmModal
class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    required this.title,
    super.key,
    this.description,
    this.type = ConfirmDialogType.danger,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
  });

  /// Dialog title
  final String title;

  /// Optional description text
  final String? description;

  /// Dialog type (affects confirm button color)
  final ConfirmDialogType type;

  /// Confirm button text
  final String confirmText;

  /// Cancel button text
  final String cancelText;

  /// Async confirm callback.
  /// Returns true to close dialog, false to keep open.
  /// Dialog shows loading state while callback is executing.
  final Future<bool> Function()? onConfirm;

  /// Shows a confirmation dialog.
  ///
  /// Returns true if user confirmed and action succeeded, false otherwise.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? description,
    ConfirmDialogType type = ConfirmDialogType.danger,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Future<bool> Function()? onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(
        title: title,
        description: description,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
    return result ?? false;
  }

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _isLoading = false;

  Color get _confirmButtonColor {
    switch (widget.type) {
      case ConfirmDialogType.warning:
        return const Color(0xFFF5A524);
      case ConfirmDialogType.danger:
        return AppColors.error;
    }
  }

  IconData get _typeIcon {
    switch (widget.type) {
      case ConfirmDialogType.warning:
        return CupertinoIcons.exclamationmark_triangle;
      case ConfirmDialogType.danger:
        return CupertinoIcons.exclamationmark_circle;
    }
  }

  Future<void> _handleConfirm() async {
    if (_isLoading) return;

    if (widget.onConfirm == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await widget.onConfirm!();
      if (result && mounted) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleCancel() {
    if (!_isLoading) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              _typeIcon,
              color: _confirmButtonColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.title)),
          ],
        ),
        content: widget.description != null
            ? Text(
                widget.description!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleCancel,
            child: Text(widget.cancelText),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _handleConfirm,
            style: FilledButton.styleFrom(
              backgroundColor: _confirmButtonColor,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(widget.confirmText),
          ),
        ],
      ),
    );
  }
}

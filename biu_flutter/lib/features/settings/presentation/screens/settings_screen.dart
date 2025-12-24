import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../favorites/presentation/providers/favorites_notifier.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_notifier.dart';
import '../widgets/audio_quality_picker.dart';
import '../widgets/color_picker.dart';

/// Settings screen for app preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isLoggedIn = authState.isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account section (only show when logged in)
          if (isLoggedIn) ...[
            _buildSectionHeader(context, 'Account'),
            _buildUserTile(context, ref, user),
            const SizedBox(height: 24),
          ],

          // Audio settings
          _buildSectionHeader(context, 'Audio'),
          _buildSettingTile(
            context,
            title: 'Audio Quality',
            subtitle: settings.audioQuality.label,
            onTap: () => _showAudioQualityPicker(context, ref, settings),
          ),
          const SizedBox(height: 24),

          // Appearance settings
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingTile(
            context,
            title: 'Display Mode',
            subtitle: settings.displayMode.label,
            onTap: () => _showDisplayModePicker(context, ref, settings),
          ),
          _buildSettingTile(
            context,
            title: 'Primary Color',
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: settings.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
            ),
            onTap: () => _showColorPicker(context, ref, settings),
          ),
          _buildSettingTile(
            context,
            title: 'Reset Theme',
            subtitle: 'Restore default colors',
            onTap: () => _showResetThemeDialog(context, ref),
          ),
          const SizedBox(height: 24),

          // Menu customization (only show when logged in)
          if (isLoggedIn) ...[
            _buildSectionHeader(context, 'Menu Customization'),
            _buildSettingTile(
              context,
              title: 'Hidden Folders',
              subtitle: settings.hiddenFolderIds.isEmpty
                  ? 'No folders hidden'
                  : '${settings.hiddenFolderIds.length} folder(s) hidden',
              onTap: () => _showHiddenFoldersDialog(context, ref),
            ),
            const SizedBox(height: 24),
          ],

          // Storage settings
          _buildSectionHeader(context, 'Storage'),
          _buildSettingTile(
            context,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () => _showClearCacheDialog(context, ref),
          ),
          const SizedBox(height: 24),

          // Account actions (only show when logged in)
          if (isLoggedIn) ...[
            _buildSectionHeader(context, 'Session'),
            _buildSettingTile(
              context,
              title: 'Logout',
              titleColor: AppColors.error,
              onTap: () => _showLogoutDialog(context, ref),
            ),
            const SizedBox(height: 24),
          ],

          // About settings
          _buildSectionHeader(context, 'About'),
          _buildSettingTile(
            context,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _buildSettingTile(
            context,
            title: 'About',
            onTap: () => context.push(AppRoutes.about),
          ),
          _buildSettingTile(
            context,
            title: 'Open Source Licenses',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Biu',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, WidgetRef ref, User? user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.contentBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: ListTile(
        leading: ClipOval(
          child: user?.face != null
              ? AppCachedImage(
                  imageUrl: user!.face,
                  width: 48,
                  height: 48,
                )
              : Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.person,
                    size: 24,
                    color: AppColors.textTertiary,
                  ),
                ),
        ),
        title: Text(user?.uname ?? 'User'),
        subtitle: Text(
          'UID: ${user?.mid ?? ''}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.contentBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: titleColor),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: AppColors.textTertiary)
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  Future<void> _showAudioQualityPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final selected = await AudioQualityPicker.show(
      context,
      currentQuality: settings.audioQuality,
    );

    if (selected != null) {
      ref.read(settingsNotifierProvider.notifier).setAudioQuality(selected);
    }
  }

  Future<void> _showColorPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final selected = await ColorPicker.show(
      context,
      currentColor: settings.primaryColor,
    );

    if (selected != null) {
      ref.read(settingsNotifierProvider.notifier).setPrimaryColor(selected);
    }
  }

  Future<void> _showResetThemeDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Theme'),
        content: const Text(
          'This will restore all appearance settings to their default values. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(settingsNotifierProvider.notifier).resetToDefaults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theme reset to defaults')),
        );
      }
    }
  }

  Future<void> _showClearCacheDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear cached images and temporary data. Your login and settings will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Clear image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared')),
      );
    }
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        // Navigate back to main screen
        context.go(AppRoutes.home);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      }
    }
  }

  Future<void> _showDisplayModePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final selected = await showDialog<DisplayMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Display Mode'),
        children: DisplayMode.values.map((mode) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, mode),
            child: Row(
              children: [
                Icon(
                  mode == DisplayMode.card ? Icons.grid_view : Icons.list,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(mode.label)),
                if (mode == settings.displayMode)
                  const Icon(Icons.check, size: 20),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      ref.read(settingsNotifierProvider.notifier).setDisplayMode(selected);
    }
  }

  Future<void> _showHiddenFoldersDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => _HiddenFoldersDialog(),
    );
  }
}

/// Dialog for managing hidden folders
class _HiddenFoldersDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesListProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final folders = favoritesState.createdFolders;

    return AlertDialog(
      title: const Text('Hidden Folders'),
      content: SizedBox(
        width: double.maxFinite,
        child: folders.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No folders available'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  final isHidden = settings.isFolderHidden(folder.id);

                  return CheckboxListTile(
                    value: !isHidden,
                    onChanged: (visible) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setFolderHidden(folder.id, !visible!);
                    },
                    title: Text(folder.title),
                    subtitle: Text('${folder.mediaCount} items'),
                    secondary: folder.cover.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AppCachedImage(
                              imageUrl: folder.cover,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.contentBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.folder, size: 20),
                          ),
                  );
                },
              ),
      ),
      actions: [
        if (settings.hiddenFolderIds.isNotEmpty)
          TextButton(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).clearHiddenFolders();
            },
            child: const Text('Show All'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

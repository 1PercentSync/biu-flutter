import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../favorites/presentation/providers/favorites_notifier.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_notifier.dart';
import '../widgets/audio_quality_picker.dart';
import '../widgets/color_picker.dart';

/// Settings screen for app preferences.
/// Source: biu/src/pages/settings/index.tsx#SettingsPage
/// Source: biu/src/pages/settings/system-settings.tsx#SystemSettingsTab
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final isLoggedIn = authState.isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Audio settings
          _buildSectionHeader(context, '音频'),
          _buildSettingTile(
            context,
            title: '音频质量',
            subtitle: settings.audioQuality.label,
            onTap: () => _showAudioQualityPicker(context, ref, settings),
          ),
          const SizedBox(height: 24),

          // Appearance settings
          _buildSectionHeader(context, '外观'),
          _buildSettingTile(
            context,
            title: '显示模式',
            subtitle: settings.displayMode.label,
            onTap: () => _showDisplayModePicker(context, ref, settings),
          ),
          _buildSettingTile(
            context,
            title: '主题色',
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
            title: '内容背景',
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: settings.contentBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
            ),
            onTap: () => _showContentBackgroundColorPicker(context, ref, settings),
          ),
          _buildSettingTile(
            context,
            title: '背景色',
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: settings.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
            ),
            onTap: () => _showBackgroundColorPicker(context, ref, settings),
          ),
          _buildSettingTile(
            context,
            title: '圆角',
            subtitle: '${settings.borderRadius.toInt()}px',
            onTap: () => _showBorderRadiusPicker(context, ref, settings),
          ),
          _buildSettingTile(
            context,
            title: '重置主题',
            subtitle: '恢复默认颜色',
            onTap: () => _showResetThemeDialog(context, ref),
          ),
          const SizedBox(height: 24),

          // Menu customization (only show when logged in)
          if (isLoggedIn) ...[
            _buildSectionHeader(context, '菜单定制'),
            _buildSettingTile(
              context,
              title: '隐藏的收藏夹',
              subtitle: settings.hiddenFolderIds.isEmpty
                  ? '无隐藏的收藏夹'
                  : '已隐藏 ${settings.hiddenFolderIds.length} 个收藏夹',
              onTap: () => _showHiddenFoldersDialog(context, ref),
            ),
            const SizedBox(height: 24),
          ],

          // Storage settings
          _buildSectionHeader(context, '存储'),
          _buildSettingTile(
            context,
            title: '清除缓存',
            subtitle: '释放存储空间',
            onTap: () => _showClearCacheDialog(context, ref),
          ),
          const SizedBox(height: 24),

          // Data settings (import/export)
          _buildSectionHeader(context, '数据'),
          _buildSettingTile(
            context,
            title: '导出设置',
            subtitle: '将设置保存到文件',
            onTap: () => _exportSettings(context, ref),
          ),
          _buildSettingTile(
            context,
            title: '导入设置',
            subtitle: '从文件加载设置',
            onTap: () => _importSettings(context, ref),
          ),
          const SizedBox(height: 24),

          // About settings
          _buildSectionHeader(context, '关于'),
          _buildVersionTile(context, ref),
          _buildSettingTile(
            context,
            title: '关于',
            onTap: () => context.push(AppRoutes.about),
          ),
          _buildSettingTile(
            context,
            title: '开源许可证',
            onTap: () {
              final packageInfo = ref.read(packageInfoProvider).valueOrNull;
              showLicensePage(
                context: context,
                applicationName: 'Biu',
                applicationVersion: packageInfo?.version ?? '...',
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

  /// Build version tile that reads from package_info_plus.
  Widget _buildVersionTile(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return packageInfoAsync.when(
      data: (packageInfo) => _buildSettingTile(
        context,
        title: '版本',
        subtitle: packageInfo.version,
      ),
      loading: () => _buildSettingTile(
        context,
        title: '版本',
        subtitle: '...',
      ),
      error: (error, stack) => _buildSettingTile(
        context,
        title: '版本',
        subtitle: '未知',
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
      unawaited(ref.read(settingsNotifierProvider.notifier).setAudioQuality(selected));
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
      unawaited(ref.read(settingsNotifierProvider.notifier).setPrimaryColor(selected));
    }
  }

  /// Show content background color picker.
  /// Source: biu/src/pages/settings/system-settings.tsx#contentBackgroundColor
  Future<void> _showContentBackgroundColorPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final selected = await ColorPicker.show(
      context,
      currentColor: settings.contentBackgroundColor,
    );

    if (selected != null) {
      unawaited(ref.read(settingsNotifierProvider.notifier).setContentBackgroundColor(selected));
    }
  }

  /// Show background color picker.
  /// Source: biu/src/pages/settings/system-settings.tsx#backgroundColor
  Future<void> _showBackgroundColorPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final selected = await ColorPicker.show(
      context,
      currentColor: settings.backgroundColor,
    );

    if (selected != null) {
      unawaited(ref.read(settingsNotifierProvider.notifier).setBackgroundColor(selected));
    }
  }

  /// Show border radius picker.
  /// Source: biu/src/pages/settings/system-settings.tsx#borderRadius
  Future<void> _showBorderRadiusPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final result = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: AppColors.contentBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (context) => _BorderRadiusPicker(
        currentRadius: settings.borderRadius,
      ),
    );

    if (result != null) {
      unawaited(ref.read(settingsNotifierProvider.notifier).setBorderRadius(result));
    }
  }

  Future<void> _showResetThemeDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置主题'),
        content: const Text(
          'This will restore all appearance settings to their default values. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('重置'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(settingsNotifierProvider.notifier).resetToDefaults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('主题已重置')),
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
        title: const Text('清除缓存'),
        content: const Text(
          'This will clear cached images and temporary data. Your login and settings will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      // Clear image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缓存已清除')),
      );
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
        title: const Text('显示模式'),
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
      unawaited(ref.read(settingsNotifierProvider.notifier).setDisplayMode(selected));
    }
  }

  Future<void> _showHiddenFoldersDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _HiddenFoldersDialog(),
    );
  }

  /// Export settings to file.
  /// Source: biu/src/pages/settings/export-import.tsx#handleExport
  Future<void> _exportSettings(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(settingsNotifierProvider.notifier).exportSettings();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? null : AppColors.error,
        ),
      );
    }
  }

  /// Import settings from file.
  /// Source: biu/src/pages/settings/export-import.tsx#handleImportClick
  Future<void> _importSettings(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(settingsNotifierProvider.notifier).importSettings();

    if (context.mounted && !result.cancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? null : AppColors.error,
        ),
      );
    }
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
      title: const Text('隐藏的收藏夹'),
      content: SizedBox(
        width: double.maxFinite,
        child: folders.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无收藏夹'),
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
                          .setFolderHidden(folder.id, hidden: !visible!);
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
            child: const Text('显示全部'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('完成'),
        ),
      ],
    );
  }
}

/// Border radius picker widget.
/// Source: biu/src/pages/settings/system-settings.tsx#borderRadius
class _BorderRadiusPicker extends StatefulWidget {
  const _BorderRadiusPicker({required this.currentRadius});

  final double currentRadius;

  @override
  State<_BorderRadiusPicker> createState() => _BorderRadiusPickerState();
}

class _BorderRadiusPickerState extends State<_BorderRadiusPicker> {
  late double _radius;

  @override
  void initState() {
    super.initState();
    _radius = widget.currentRadius;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '圆角',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(_radius),
              ),
              child: Center(
                child: Text(
                  '${_radius.toInt()}px',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('0'),
                Expanded(
                  child: Slider(
                    value: _radius,
                    max: 24,
                    divisions: 24,
                    onChanged: (value) {
                      setState(() {
                        _radius = value;
                      });
                    },
                  ),
                ),
                const Text('24'),
              ],
            ),
          ),
          // Confirm button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _radius),
                child: const Text('应用'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

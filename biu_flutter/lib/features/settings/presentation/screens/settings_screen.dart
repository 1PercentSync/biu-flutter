import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';

/// Settings screen for app preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Audio settings
          _buildSectionHeader(context, 'Audio'),
          _buildSettingTile(
            context,
            title: 'Audio Quality',
            subtitle: 'Auto',
            onTap: () {
              // TODO: Show audio quality selector
            },
          ),
          _buildSettingTile(
            context,
            title: 'Play Mode',
            subtitle: 'Sequential',
            onTap: () {
              // TODO: Show play mode selector
            },
          ),
          const SizedBox(height: 24),

          // Appearance settings
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingTile(
            context,
            title: 'Theme',
            subtitle: 'Dark',
            onTap: () {
              // TODO: Show theme selector
            },
          ),
          _buildSettingTile(
            context,
            title: 'Primary Color',
            trailing: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              // TODO: Show color picker
            },
          ),
          const SizedBox(height: 24),

          // Account settings
          _buildSectionHeader(context, 'Account'),
          _buildSettingTile(
            context,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () {
              // TODO: Clear cache
            },
          ),
          _buildSettingTile(
            context,
            title: 'Logout',
            titleColor: AppColors.error,
            onTap: () {
              // TODO: Show logout confirmation
            },
          ),
          const SizedBox(height: 24),

          // About settings
          _buildSectionHeader(context, 'About'),
          _buildSettingTile(
            context,
            title: 'Version',
            subtitle: '1.0.0',
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
      padding: const EdgeInsets.only(bottom: 8),
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
}

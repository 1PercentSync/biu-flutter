import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../providers/settings_notifier.dart';

/// About screen showing app version and licenses.
/// Flutter-only: Source shows version info inline in system-settings.tsx.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const String appName = 'Biu';
  static const String appDescription =
      'A music player for Bilibili audio content.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);
    final version = packageInfoAsync.valueOrNull?.version ?? '...';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('关于'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App info section
          _buildAppInfoSection(context, version),
          const SizedBox(height: 32),
          // Links section
          _buildLinksSection(context, version),
          const SizedBox(height: 32),
          // Version info
          _buildVersionSection(context, version),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context, String version) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.contentBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Column(
        children: [
          // App icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.music_note,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // App name
          Text(
            appName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          // Version
          Text(
            'Version $version',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            appDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context, String version) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            '信息',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        _buildLinkTile(
          context,
          icon: Icons.description_outlined,
          title: '开源许可证',
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: appName,
              applicationVersion: version,
              applicationIcon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVersionSection(BuildContext context, String version) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            '技术',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.contentBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Column(
            children: [
              _buildInfoRow(context, '应用版本', version),
              const Divider(height: 16),
              _buildInfoRow(context, '构建', 'Flutter'),
              const Divider(height: 16),
              _buildInfoRow(context, '框架', 'Material 3'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.contentBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

}

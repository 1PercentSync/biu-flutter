import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../domain/entities/app_settings.dart';

/// Audio quality picker dialog widget
class AudioQualityPicker extends StatelessWidget {
  const AudioQualityPicker({
    required this.currentQuality, required this.onSelected, super.key,
  });

  final AudioQualitySetting currentQuality;
  final void Function(AudioQualitySetting) onSelected;

  static Future<AudioQualitySetting?> show(
    BuildContext context, {
    required AudioQualitySetting currentQuality,
  }) {
    return showModalBottomSheet<AudioQualitySetting>(
      context: context,
      backgroundColor: AppColors.contentBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (context) => AudioQualityPicker(
        currentQuality: currentQuality,
        onSelected: (quality) => Navigator.pop(context, quality),
      ),
    );
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
              'Audio Quality',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Options
          ...AudioQualitySetting.values.map(
            (quality) => _buildOption(context, quality),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, AudioQualitySetting quality) {
    final isSelected = quality == currentQuality;

    return ListTile(
      title: Text(quality.label),
      subtitle: Text(
        quality.description,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () => onSelected(quality),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

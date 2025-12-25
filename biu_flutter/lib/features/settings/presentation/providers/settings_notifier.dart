import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/storage/storage_service.dart';
import '../../domain/entities/app_settings.dart';

/// Storage key for settings
const _settingsStorageKey = 'app_settings';

/// Provider for package info (app version, build number, etc.)
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

/// Provider for settings.
/// Source: biu/src/store/settings.ts#useSettings
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});

/// Convenience providers for individual settings
final audioQualityProvider = Provider<AudioQualitySetting>((ref) {
  return ref.watch(settingsNotifierProvider).audioQuality;
});

final primaryColorProvider = Provider<Color>((ref) {
  return ref.watch(settingsNotifierProvider).primaryColor;
});

final displayModeProvider = Provider<DisplayMode>((ref) {
  return ref.watch(settingsNotifierProvider).displayMode;
});

final hiddenFolderIdsProvider = Provider<List<int>>((ref) {
  return ref.watch(settingsNotifierProvider).hiddenFolderIds;
});

/// Settings state notifier.
/// Source: biu/src/store/settings.ts#SettingsActions
class SettingsNotifier extends StateNotifier<AppSettings> {

  SettingsNotifier(this._storage) : super(AppSettings.defaults) {
    _loadSettings();
  }
  final StorageService _storage;

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final json = await _storage.getJson(_settingsStorageKey);
      if (json != null) {
        state = AppSettings.fromJson(json);
      }
    } catch (e) {
      // Use defaults on error
      debugPrint('Failed to load settings: $e');
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      await _storage.setJson(_settingsStorageKey, state.toJson());
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  /// Update audio quality
  Future<void> setAudioQuality(AudioQualitySetting quality) async {
    state = state.copyWith(audioQuality: quality);
    await _saveSettings();
  }

  /// Update primary color
  Future<void> setPrimaryColor(Color color) async {
    state = state.copyWith(primaryColor: color);
    await _saveSettings();
  }

  /// Update background color
  Future<void> setBackgroundColor(Color color) async {
    state = state.copyWith(backgroundColor: color);
    await _saveSettings();
  }

  /// Update content background color
  Future<void> setContentBackgroundColor(Color color) async {
    state = state.copyWith(contentBackgroundColor: color);
    await _saveSettings();
  }

  /// Update border radius
  Future<void> setBorderRadius(double radius) async {
    state = state.copyWith(borderRadius: radius);
    await _saveSettings();
  }

  /// Update display mode
  Future<void> setDisplayMode(DisplayMode mode) async {
    state = state.copyWith(displayMode: mode);
    await _saveSettings();
  }

  /// Toggle folder visibility
  Future<void> toggleFolderVisibility(int folderId) async {
    final currentHidden = List<int>.from(state.hiddenFolderIds);
    if (currentHidden.contains(folderId)) {
      currentHidden.remove(folderId);
    } else {
      currentHidden.add(folderId);
    }
    state = state.copyWith(hiddenFolderIds: currentHidden);
    await _saveSettings();
  }

  /// Set folder hidden
  Future<void> setFolderHidden(int folderId, {required bool hidden}) async {
    final currentHidden = List<int>.from(state.hiddenFolderIds);
    if (hidden && !currentHidden.contains(folderId)) {
      currentHidden.add(folderId);
    } else if (!hidden && currentHidden.contains(folderId)) {
      currentHidden.remove(folderId);
    }
    state = state.copyWith(hiddenFolderIds: currentHidden);
    await _saveSettings();
  }

  /// Clear all hidden folders
  Future<void> clearHiddenFolders() async {
    state = state.copyWith(hiddenFolderIds: []);
    await _saveSettings();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    state = AppSettings.defaults;
    await _saveSettings();
  }

  /// Export settings to JSON and share.
  /// Source: biu/src/pages/settings/export-import.tsx#handleExport
  Future<ExportResult> exportSettings() async {
    try {
      final json = state.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(json);

      // Create temp file with timestamp
      final timestamp = DateTime.now()
          .toIso8601String()
          .substring(0, 19)
          .replaceAll(':', '-')
          .replaceAll('T', '-');
      final fileName = 'biu-settings-$timestamp.json';

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // Share the file
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Biu Settings Export',
      );

      return ExportResult(
        success: result.status == ShareResultStatus.success ||
            result.status == ShareResultStatus.dismissed,
        message: 'Settings exported successfully',
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Export failed: $e',
      );
    }
  }

  /// Import settings from JSON file.
  /// Source: biu/src/pages/settings/export-import.tsx#handleImportFileChange
  Future<ImportResult> importSettings() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return const ImportResult(
          success: false,
          message: 'No file selected',
          cancelled: true,
        );
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return const ImportResult(
          success: false,
          message: 'Cannot access file',
        );
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Merge with current settings (like source does)
      final imported = AppSettings.fromJson(json);
      state = imported;
      await _saveSettings();

      return const ImportResult(
        success: true,
        message: 'Settings imported successfully',
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Import failed: $e',
      );
    }
  }
}

/// Result of export operation
class ExportResult {
  const ExportResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

/// Result of import operation
class ImportResult {
  const ImportResult({
    required this.success,
    required this.message,
    this.cancelled = false,
  });

  final bool success;
  final String message;
  final bool cancelled;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_service.dart';
import '../../domain/entities/app_settings.dart';

/// Storage key for settings
const _settingsStorageKey = 'app_settings';

/// Provider for settings
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

/// Settings state notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(AppSettings.defaults) {
    _loadSettings();
  }

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

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    state = AppSettings.defaults;
    await _saveSettings();
  }
}

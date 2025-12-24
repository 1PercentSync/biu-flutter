import 'package:flutter/material.dart';

/// Display mode for list screens
enum DisplayMode {
  /// Card/grid display mode
  card('card', 'Card'),

  /// List display mode
  list('list', 'List');

  const DisplayMode(this.value, this.label);
  final String value;
  final String label;

  static DisplayMode fromValue(String value) {
    return DisplayMode.values.firstWhere(
      (m) => m.value == value,
      orElse: () => DisplayMode.card,
    );
  }
}

/// Audio quality settings for playback
enum AudioQualitySetting {
  /// Automatically select best available quality
  auto('auto', 'Auto', 'Select best quality automatically'),

  /// Low quality (64K)
  low('low', '64K', 'Low quality, saves data'),

  /// Standard quality (128K)
  standard('standard', '128K', 'Standard quality'),

  /// High quality (192K)
  high('high', '192K', 'High quality'),

  /// Hi-Res quality (lossless)
  hires('hires', 'Hi-Res', 'Lossless audio (requires VIP)');

  const AudioQualitySetting(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  static AudioQualitySetting fromValue(String value) {
    return AudioQualitySetting.values.firstWhere(
      (q) => q.value == value,
      orElse: () => AudioQualitySetting.auto,
    );
  }
}

/// App settings entity matching source app configuration
class AppSettings {

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      audioQuality: AudioQualitySetting.fromValue(
        json['audioQuality'] as String? ?? 'auto',
      ),
      primaryColor: Color(json['primaryColor'] as int? ?? 0xFF17C964),
      backgroundColor: Color(json['backgroundColor'] as int? ?? 0xFF18181B),
      contentBackgroundColor:
          Color(json['contentBackgroundColor'] as int? ?? 0xFF1F1F1F),
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 8.0,
      displayMode: DisplayMode.fromValue(
        json['displayMode'] as String? ?? 'card',
      ),
      hiddenFolderIds: (json['hiddenFolderIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
  const AppSettings({
    this.audioQuality = AudioQualitySetting.auto,
    this.primaryColor = const Color(0xFF17C964),
    this.backgroundColor = const Color(0xFF18181B),
    this.contentBackgroundColor = const Color(0xFF1F1F1F),
    this.borderRadius = 8.0,
    this.displayMode = DisplayMode.card,
    this.hiddenFolderIds = const [],
  });

  /// Audio quality preference
  final AudioQualitySetting audioQuality;

  /// Primary/accent color
  final Color primaryColor;

  /// Main background color
  final Color backgroundColor;

  /// Content area background color
  final Color contentBackgroundColor;

  /// Border radius for UI elements
  final double borderRadius;

  /// Display mode for list screens (card or list)
  final DisplayMode displayMode;

  /// List of hidden folder IDs
  final List<int> hiddenFolderIds;

  /// Default settings
  static const AppSettings defaults = AppSettings();

  /// Preset primary colors
  static const List<Color> presetColors = [
    Color(0xFF17C964), // Green (default)
    Color(0xFFFB7299), // Bilibili pink
    Color(0xFF00A1D6), // Bilibili blue
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF59E0B), // Orange
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
  ];

  AppSettings copyWith({
    AudioQualitySetting? audioQuality,
    Color? primaryColor,
    Color? backgroundColor,
    Color? contentBackgroundColor,
    double? borderRadius,
    DisplayMode? displayMode,
    List<int>? hiddenFolderIds,
  }) {
    return AppSettings(
      audioQuality: audioQuality ?? this.audioQuality,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      contentBackgroundColor:
          contentBackgroundColor ?? this.contentBackgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      displayMode: displayMode ?? this.displayMode,
      hiddenFolderIds: hiddenFolderIds ?? this.hiddenFolderIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioQuality': audioQuality.value,
      'primaryColor': primaryColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
      'contentBackgroundColor': contentBackgroundColor.toARGB32(),
      'borderRadius': borderRadius,
      'displayMode': displayMode.value,
      'hiddenFolderIds': hiddenFolderIds,
    };
  }

  /// Check if a folder is hidden
  bool isFolderHidden(int folderId) => hiddenFolderIds.contains(folderId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppSettings) return false;
    if (hiddenFolderIds.length != other.hiddenFolderIds.length) return false;
    for (var i = 0; i < hiddenFolderIds.length; i++) {
      if (hiddenFolderIds[i] != other.hiddenFolderIds[i]) return false;
    }
    return other.audioQuality == audioQuality &&
        other.primaryColor == primaryColor &&
        other.backgroundColor == backgroundColor &&
        other.contentBackgroundColor == contentBackgroundColor &&
        other.borderRadius == borderRadius &&
        other.displayMode == displayMode;
  }

  @override
  int get hashCode {
    return Object.hash(
      audioQuality,
      primaryColor,
      backgroundColor,
      contentBackgroundColor,
      borderRadius,
      displayMode,
      Object.hashAll(hiddenFolderIds),
    );
  }
}

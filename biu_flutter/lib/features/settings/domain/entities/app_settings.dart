import 'package:flutter/material.dart';

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
  const AppSettings({
    this.audioQuality = AudioQualitySetting.auto,
    this.primaryColor = const Color(0xFF17C964),
    this.backgroundColor = const Color(0xFF18181B),
    this.contentBackgroundColor = const Color(0xFF1F1F1F),
    this.borderRadius = 8.0,
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
  }) {
    return AppSettings(
      audioQuality: audioQuality ?? this.audioQuality,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      contentBackgroundColor:
          contentBackgroundColor ?? this.contentBackgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioQuality': audioQuality.value,
      'primaryColor': primaryColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
      'contentBackgroundColor': contentBackgroundColor.toARGB32(),
      'borderRadius': borderRadius,
    };
  }

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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.audioQuality == audioQuality &&
        other.primaryColor == primaryColor &&
        other.backgroundColor == backgroundColor &&
        other.contentBackgroundColor == contentBackgroundColor &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode {
    return Object.hash(
      audioQuality,
      primaryColor,
      backgroundColor,
      contentBackgroundColor,
      borderRadius,
    );
  }
}

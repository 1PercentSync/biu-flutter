/// Play mode for the audio player.
///
/// Defines how the playlist behaves when a track finishes playing.
///
/// Source: biu/src/common/constants/audio.tsx#PlayMode
enum PlayMode {
  /// Sequential play - play in order, stop at the end
  sequence(1, 'Sequential', 'order_play'),

  /// Loop play - repeat the entire playlist
  loop(2, 'Loop', 'repeat'),

  /// Random play - shuffle the playlist
  random(3, 'Random', 'shuffle'),

  /// Single play - repeat the current track
  single(4, 'Single', 'repeat_one');

  const PlayMode(this.value, this.label, this.iconName);

  /// Numeric value for persistence
  final int value;

  /// Display label
  final String label;

  /// Icon name for UI
  final String iconName;

  /// Get PlayMode from numeric value
  static PlayMode fromValue(int value) {
    return PlayMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => PlayMode.loop,
    );
  }

  /// Get the next play mode in cycle
  PlayMode get next {
    final currentIndex = PlayMode.values.indexOf(this);
    final nextIndex = (currentIndex + 1) % PlayMode.values.length;
    return PlayMode.values[nextIndex];
  }
}

/// Audio quality levels for Bilibili.
///
/// Contains quality IDs and their mappings for audio stream selection.
/// IDs are sorted from lowest to highest quality (last is lossless).
///
/// Source: biu/src/common/constants/audio.tsx#audioQualitySort
class AudioQuality {
  AudioQuality._();

  /// Quality IDs from low to high (last is lossless)
  static const List<int> sortedQualityIds = [
    30257, // 64K
    30216, // 64K (legacy)
    30259, // 128K
    30260, // 128K (legacy)
    30232, // 132K
    30280, // 192K
    30250, // Dolby Atmos
    30251, // Hi-Res
  ];

  /// Quality labels
  static const Map<int, String> qualityLabels = {
    30257: '64K',
    30216: '64K',
    30259: '128K',
    30260: '128K',
    30232: '132K',
    30280: '192K',
    30250: 'Dolby',
    30251: 'Hi-Res',
  };

  /// Check if quality is lossless
  static bool isLossless(int qualityId) => qualityId == 30251;

  /// Check if quality is Dolby
  static bool isDolby(int qualityId) => qualityId == 30250;
}

/// Type of playable content
enum PlayDataType {
  /// Music video
  mv,

  /// Audio-only content
  audio,
}

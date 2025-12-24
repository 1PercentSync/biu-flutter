import 'package:biu_flutter/core/constants/audio.dart';
import 'package:biu_flutter/features/player/domain/entities/play_item.dart';

/// Represents the state of the playlist and playback.
class PlaylistState {

  const PlaylistState({
    this.isPlaying = false,
    this.isMuted = false,
    this.volume = 0.5,
    this.playMode = PlayMode.loop,
    this.rate = 1.0,
    this.duration,
    this.currentTime = 0.0,
    this.list = const [],
    this.playId,
    this.nextId,
    this.shouldKeepPagesOrderInRandomPlayMode = true,
    this.isLoading = false,
    this.error,
  });

  /// Create from JSON
  factory PlaylistState.fromJson(Map<String, dynamic> json) {
    return PlaylistState(
      isMuted: json['isMuted'] as bool? ?? false,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.5,
      playMode: PlayMode.fromValue(json['playMode'] as int? ?? 2),
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
      duration: (json['duration'] as num?)?.toDouble(),
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => PlayItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      playId: json['playId'] as String?,
      nextId: json['nextId'] as String?,
      shouldKeepPagesOrderInRandomPlayMode:
          json['shouldKeepPagesOrderInRandomPlayMode'] as bool? ?? true,
    );
  }
  /// Whether audio is currently playing
  final bool isPlaying;

  /// Whether audio is muted
  final bool isMuted;

  /// Volume level (0.0 to 1.0)
  final double volume;

  /// Current play mode
  final PlayMode playMode;

  /// Playback speed (0.5 to 2.0)
  final double rate;

  /// Total duration of current track in seconds
  final double? duration;

  /// Current playback position in seconds
  final double currentTime;

  /// The playlist
  final List<PlayItem> list;

  /// ID of the currently playing item
  final String? playId;

  /// ID of the next item to play (for "play next" feature)
  final String? nextId;

  /// Whether to keep page order in random play mode for multi-part videos
  final bool shouldKeepPagesOrderInRandomPlayMode;

  /// Whether the player is loading/buffering
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Get the currently playing item
  PlayItem? get currentItem {
    if (playId == null) return null;
    return list.cast<PlayItem?>().firstWhere(
          (item) => item?.id == playId,
          orElse: () => null,
        );
  }

  /// Get the index of the currently playing item
  int get currentIndex {
    if (playId == null) return -1;
    return list.indexWhere((item) => item.id == playId);
  }

  /// Whether the playlist is empty
  bool get isEmpty => list.isEmpty;

  /// Whether the playlist has items
  bool get hasItems => list.isNotEmpty;

  /// Number of items in the playlist
  int get length => list.length;

  /// Create a copy with updated fields
  PlaylistState copyWith({
    bool? isPlaying,
    bool? isMuted,
    double? volume,
    PlayMode? playMode,
    double? rate,
    double? duration,
    double? currentTime,
    List<PlayItem>? list,
    String? playId,
    String? nextId,
    bool? shouldKeepPagesOrderInRandomPlayMode,
    bool? isLoading,
    String? error,
    bool clearPlayId = false,
    bool clearNextId = false,
    bool clearDuration = false,
    bool clearError = false,
  }) {
    return PlaylistState(
      isPlaying: isPlaying ?? this.isPlaying,
      isMuted: isMuted ?? this.isMuted,
      volume: volume ?? this.volume,
      playMode: playMode ?? this.playMode,
      rate: rate ?? this.rate,
      duration: clearDuration ? null : (duration ?? this.duration),
      currentTime: currentTime ?? this.currentTime,
      list: list ?? this.list,
      playId: clearPlayId ? null : (playId ?? this.playId),
      nextId: clearNextId ? null : (nextId ?? this.nextId),
      shouldKeepPagesOrderInRandomPlayMode:
          shouldKeepPagesOrderInRandomPlayMode ??
              this.shouldKeepPagesOrderInRandomPlayMode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'isMuted': isMuted,
      'volume': volume,
      'playMode': playMode.value,
      'rate': rate,
      'duration': duration,
      'list': list.map((item) => item.toJson()).toList(),
      'playId': playId,
      'nextId': nextId,
      'shouldKeepPagesOrderInRandomPlayMode':
          shouldKeepPagesOrderInRandomPlayMode,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistState &&
          runtimeType == other.runtimeType &&
          isPlaying == other.isPlaying &&
          isMuted == other.isMuted &&
          volume == other.volume &&
          playMode == other.playMode &&
          rate == other.rate &&
          duration == other.duration &&
          currentTime == other.currentTime &&
          playId == other.playId &&
          nextId == other.nextId &&
          shouldKeepPagesOrderInRandomPlayMode ==
              other.shouldKeepPagesOrderInRandomPlayMode &&
          isLoading == other.isLoading &&
          error == other.error &&
          _listEquals(list, other.list);

  bool _listEquals(List<PlayItem> a, List<PlayItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        isPlaying,
        isMuted,
        volume,
        playMode,
        rate,
        duration,
        currentTime,
        playId,
        nextId,
        shouldKeepPagesOrderInRandomPlayMode,
        isLoading,
        error,
        Object.hashAll(list),
      );
}

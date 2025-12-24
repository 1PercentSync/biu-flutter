import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:biu_flutter/core/constants/api.dart';
import 'package:biu_flutter/features/player/domain/entities/play_item.dart';
import 'package:just_audio/just_audio.dart';

/// Service that wraps just_audio AudioPlayer for audio playback.
/// Provides a simplified interface for the playlist manager.
class AudioPlayerService {

  AudioPlayerService() : _player = AudioPlayer();
  final AudioPlayer _player;

  /// The underlying AudioPlayer instance
  AudioPlayer get player => _player;

  /// Current playback position
  Duration get position => _player.position;

  /// Current duration of the playing track
  Duration? get duration => _player.duration;

  /// Whether audio is currently playing
  bool get isPlaying => _player.playing;

  /// Current volume (0.0 to 1.0)
  double get volume => _player.volume;

  /// Current playback speed
  double get speed => _player.speed;

  /// Stream of player state changes
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Stream of position changes
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of duration changes
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Stream of buffered position changes
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  /// Stream of current index changes (for playlist)
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  /// Stream of processing state changes
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  /// Set the audio source URL with Bilibili-specific headers
  Future<Duration?> setUrl(String url, {Map<String, String>? headers}) async {
    final effectiveHeaders = {
      'Referer': ApiConstants.bilibiliReferer,
      'User-Agent': ApiConstants.userAgent,
      ...?headers,
    };

    return _player.setUrl(
      url,
      headers: effectiveHeaders,
    );
  }

  /// Set audio source from a PlayItem
  Future<Duration?> setPlayItem(PlayItem item) async {
    if (item.audioUrl == null || item.audioUrl!.isEmpty) {
      return null;
    }
    return setUrl(item.audioUrl!);
  }

  /// Start or resume playback
  Future<void> play() async {
    await _player.play();
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stop playback and release resources
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Set the playback volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Set the playback speed (0.5 to 2.0)
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed.clamp(0.5, 2.0));
  }

  /// Set loop mode
  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Audio handler for background playback using audio_service.
/// Integrates with system media controls.
class BiuAudioHandler extends BaseAudioHandler with SeekHandler {

  BiuAudioHandler({
    required AudioPlayerService playerService,
    this.onPlayNext,
    this.onPlayPrevious,
  }) : _playerService = playerService {
    _init();
  }
  final AudioPlayerService _playerService;
  final void Function()? onPlayNext;
  final void Function()? onPlayPrevious;

  void _init() {
    // Forward player state to playback state
    _playerService.playerStateStream.listen((playerState) {
      final processingState = _mapProcessingState(playerState.processingState);
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playerState.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: playerState.playing,
        updatePosition: _playerService.position,
        bufferedPosition:
            Duration.zero, // Will be updated by buffered position stream
        speed: _playerService.speed,
      ));
    });

    // Forward position updates
    _playerService.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });

    // Forward buffered position updates
    _playerService.bufferedPositionStream.listen((bufferedPosition) {
      playbackState.add(playbackState.value.copyWith(
        bufferedPosition: bufferedPosition,
      ));
    });

    // Forward duration updates
    _playerService.durationStream.listen((duration) {
      final currentItem = mediaItem.value;
      if (currentItem != null && duration != null) {
        mediaItem.add(currentItem.copyWith(duration: duration));
      }
    });
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  /// Update the currently playing media item for system UI.
  /// Uses a custom method name to avoid conflicting with BaseAudioHandler.
  void updateCurrentMediaItem(PlayItem item) {
    mediaItem.add(MediaItem(
      id: item.id,
      title: item.displayTitle,
      artist: item.ownerName,
      duration: item.duration != null
          ? Duration(seconds: item.duration!)
          : Duration.zero,
      artUri: item.displayCover != null ? Uri.parse(item.displayCover!) : null,
    ));
  }

  @override
  Future<void> play() async {
    await _playerService.play();
  }

  @override
  Future<void> pause() async {
    await _playerService.pause();
  }

  @override
  Future<void> stop() async {
    await _playerService.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _playerService.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    onPlayNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    onPlayPrevious?.call();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _playerService.setSpeed(speed);
    playbackState.add(playbackState.value.copyWith(speed: speed));
  }
}

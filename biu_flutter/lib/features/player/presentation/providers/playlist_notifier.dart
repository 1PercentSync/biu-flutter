import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:biu_flutter/core/constants/audio.dart';
import 'package:biu_flutter/core/storage/storage_service.dart';
import 'package:biu_flutter/core/utils/url_utils.dart';
import 'package:biu_flutter/features/player/domain/entities/play_item.dart';
import 'package:biu_flutter/features/player/presentation/providers/playlist_state.dart';
import 'package:biu_flutter/features/player/services/audio_player_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Result of fetching video info for getting cid
class VideoInfoResult {
  const VideoInfoResult({
    required this.cid,
    required this.aid,
    this.title,
    this.cover,
    this.ownerName,
    this.ownerMid,
    this.duration,
    this.hasMultiPart = false,
    this.pageIndex,
    this.pageTitle,
    this.pageCover,
    this.totalPage,
  });

  final String cid;
  final String aid;
  final String? title;
  final String? cover;
  final String? ownerName;
  final int? ownerMid;
  final int? duration;
  final bool hasMultiPart;
  final int? pageIndex;
  final String? pageTitle;
  final String? pageCover;
  final int? totalPage;
}

/// Keys for persistent storage
class _StorageKeys {
  static const String playlistState = 'playlist_state';
  static const String currentTime = 'play_current_time';
}

/// Notifier for managing playlist state and audio playback.
class PlaylistNotifier extends Notifier<PlaylistState> {
  late AudioPlayerService _playerService;
  late BiuAudioHandler _audioHandler;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;

  // Callbacks for fetching audio URLs (injected from features)
  Future<String?> Function(String bvid, String cid)? onFetchMvAudioUrl;
  Future<String?> Function(int sid)? onFetchAudioUrl;
  // Callback for fetching video info (to get cid when missing)
  Future<VideoInfoResult?> Function(String bvid)? onFetchVideoInfo;

  @override
  PlaylistState build() {
    // Initialize player service
    _playerService = AudioPlayerService();

    // Clean up on disposal
    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _processingStateSubscription?.cancel();
      _playerService.dispose();
    });

    // Load persisted state
    _loadPersistedState();

    return const PlaylistState();
  }

  /// Initialize the audio handler for background playback.
  /// Must be called after AudioService.init()
  BiuAudioHandler get audioHandler => _audioHandler;
  set audioHandler(BiuAudioHandler handler) => _audioHandler = handler;

  /// Initialize player and restore state
  Future<void> initialize() async {
    // Set up player state listener
    _playerStateSubscription =
        _playerService.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
      );

      // Handle track completion
      if (playerState.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });

    // Set up position listener
    _positionSubscription = _playerService.positionStream.listen((position) {
      state = state.copyWith(
        currentTime: position.inMilliseconds / 1000.0,
      );
    });

    // Set up duration listener
    _durationSubscription = _playerService.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(
          duration: duration.inMilliseconds / 1000.0,
        );
      }
    });

    // Set up processing state listener
    _processingStateSubscription =
        _playerService.processingStateStream.listen((processingState) {
      state = state.copyWith(
        isLoading: processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering,
      );
    });

    // Apply persisted settings
    await _playerService.setVolume(state.volume);
    await _playerService.setSpeed(state.rate);
    await _playerService.setLoopMode(
      state.playMode == PlayMode.single ? LoopMode.one : LoopMode.off,
    );

    // Restore playback position if there's a current item
    if (state.playId != null && state.currentItem != null) {
      await _ensureAudioUrlValid();

      final savedTime = await _loadCurrentTime();
      if (savedTime > 0) {
        await _playerService.seek(Duration(milliseconds: (savedTime * 1000).round()));
        state = state.copyWith(currentTime: savedTime);
      }
    }
  }

  // ============ Playback Controls ============

  /// Toggle play/pause
  Future<void> togglePlay() async {
    if (state.isEmpty || state.playId == null) return;

    if (_playerService.isPlaying) {
      await _playerService.pause();
    } else {
      final success = await _ensureAudioUrlValid();
      if (success) {
        await _playerService.play();
      }
    }
  }

  /// Toggle mute
  void toggleMute() {
    final newMuted = !state.isMuted;
    unawaited(_playerService.setVolume(newMuted ? 0.0 : state.volume));
    state = state.copyWith(isMuted: newMuted);
    unawaited(_saveState());
  }

  /// Set volume (0.0 to 1.0)
  void setVolume(double volume) {
    final clampedVolume = volume.clamp(0.0, 1.0);
    unawaited(_playerService.setVolume(state.isMuted ? 0.0 : clampedVolume));
    state = state.copyWith(volume: clampedVolume);
    unawaited(_saveState());
  }

  /// Toggle play mode (cycle through modes)
  void togglePlayMode() {
    final newMode = state.playMode.next;
    unawaited(_playerService.setLoopMode(
      newMode == PlayMode.single ? LoopMode.one : LoopMode.off,
    ));
    state = state.copyWith(playMode: newMode);
    unawaited(_saveState());
  }

  /// Set playback rate (0.5 to 2.0)
  void setRate(double rate) {
    final clampedRate = rate.clamp(0.5, 2.0);
    unawaited(_playerService.setSpeed(clampedRate));
    state = state.copyWith(rate: clampedRate);
    unawaited(_saveState());
  }

  /// Seek to position (in seconds)
  Future<void> seek(double seconds) async {
    await _playerService.seek(Duration(milliseconds: (seconds * 1000).round()));
    state = state.copyWith(currentTime: seconds);
    unawaited(_saveCurrentTime());
  }

  /// Set whether to keep page order in random play mode
  void setShouldKeepPagesOrderInRandomPlayMode({required bool shouldKeep}) {
    state = state.copyWith(shouldKeepPagesOrderInRandomPlayMode: shouldKeep);
    unawaited(_saveState());
  }

  // ============ Playlist Operations ============

  /// Play a single item (adds to playlist if not present)
  Future<void> play(PlayItem item) async {
    debugPrint('[Playlist] Play requested: ${item.title} (type: ${item.type})');

    // Check if already playing
    final currentItem = state.currentItem;
    if (currentItem != null && currentItem.isSameContent(item)) {
      debugPrint('[Playlist] Already current item, checking playback state');
      if (!_playerService.isPlaying) {
        final success = await _ensureAudioUrlValid();
        if (success) {
          debugPrint('[Playlist] Starting player (existing item)');
          await _playerService.play();
          debugPrint('[Playlist] Player started');
        }
      } else {
        debugPrint('[Playlist] Already playing');
      }
      return;
    }

    // Check if item already exists in playlist
    final existingIndex =
        state.list.indexWhere((i) => i.isSameContent(item));
    if (existingIndex != -1) {
      debugPrint('[Playlist] Item exists in playlist, switching to it');
      await playListItem(state.list[existingIndex].id);
      return;
    }

    // Add new item and play
    debugPrint('[Playlist] Adding new item to playlist');
    final newList = [...state.list, item];
    state = state.copyWith(
      list: newList,
      playId: item.id,
      currentTime: 0,
      clearDuration: true,
    );

    await _playCurrentItem();
  }

  /// Play a specific item from the playlist by ID
  Future<void> playListItem(String id) async {
    if (state.playId == id) return;

    final itemIndex = state.list.indexWhere((item) => item.id == id);
    if (itemIndex == -1) return;

    state = state.copyWith(
      playId: id,
      nextId: state.nextId == id ? null : state.nextId,
      clearNextId: state.nextId == id,
      currentTime: 0,
      clearDuration: true,
    );

    await _playCurrentItem();
  }

  /// Replace the entire playlist and play the first item
  Future<void> playList(List<PlayItem> items) async {
    if (items.isEmpty) return;

    state = state.copyWith(
      list: items,
      playId: items.first.id,
      clearNextId: true,
      currentTime: 0,
      clearDuration: true,
    );

    await _playCurrentItem();
  }

  /// Add item to play next.
  ///
  /// For audio type: Insert directly after current item.
  /// For MV type: Insert after the LAST page of the current video.
  ///
  /// Reference: `biu/src/store/play-list.ts:729-745`
  Future<void> addToNext(PlayItem item) async {
    // Don't add if currently playing
    final currentItem = state.currentItem;
    if (currentItem != null && currentItem.isSameContent(item)) return;

    // Don't add if already set as next
    if (state.nextId != null) {
      final nextItem = state.list.cast<PlayItem?>().firstWhere(
            (i) => i?.id == state.nextId,
            orElse: () => null,
          );
      if (nextItem != null && nextItem.isSameContent(item)) return;
    }

    // Check if item already exists
    final existingIndex =
        state.list.indexWhere((i) => i.isSameContent(item));
    if (existingIndex != -1) {
      state = state.copyWith(nextId: state.list[existingIndex].id);
      unawaited(_saveState());
      return;
    }

    // Add new item and set as next
    if (state.isEmpty) {
      // Empty list - just play it
      await play(item);
      return;
    }

    // Determine insert position based on current item type
    int insertIndex;
    if (currentItem?.type == PlayDataType.audio) {
      // For audio: Insert directly after current item
      final currentIndex = state.currentIndex;
      insertIndex = currentIndex == -1 ? 0 : currentIndex + 1;
    } else if (currentItem?.type == PlayDataType.mv && currentItem?.bvid != null) {
      // For MV: Find the last page of the current video and insert after it
      final lastPageIndex = state.list.lastIndexWhere(
        (i) => i.bvid == currentItem!.bvid,
      );
      insertIndex = lastPageIndex == -1 ? state.length : lastPageIndex + 1;
    } else {
      // Fallback: Insert after current item
      final currentIndex = state.currentIndex;
      insertIndex = currentIndex == -1 ? 0 : currentIndex + 1;
    }

    final newList = [...state.list]..insert(insertIndex, item);

    state = state.copyWith(
      list: newList,
      nextId: item.id,
    );
    unawaited(_saveState());
  }

  /// Add multiple items to the end of playlist
  void addList(List<PlayItem> items) {
    if (items.isEmpty) return;

    if (state.isEmpty) {
      playList(items);
      return;
    }

    // Filter out duplicates
    final currentItem = state.currentItem;
    final newItems = items
        .where((item) =>
            !state.list.any((i) => i.isSameContent(item)) &&
            (currentItem == null || !currentItem.isSameContent(item)))
        .toList();

    if (newItems.isEmpty) return;

    state = state.copyWith(
      list: [...state.list, ...newItems],
    );
    unawaited(_saveState());
  }

  /// Remove a single page/part from playlist
  Future<void> delPage(String id) async {
    if (state.list.length == 1) {
      await clear();
      return;
    }

    // If deleting current item, play next first
    if (id == state.playId) {
      await next();
    }

    final newList = state.list.where((item) => item.id != id).toList();
    state = state.copyWith(list: newList);
    unawaited(_saveState());
  }

  /// Remove all items with same content (all parts of a video)
  Future<void> del(String id) async {
    if (state.list.length == 1) {
      await clear();
      return;
    }

    final removedItem = state.list.cast<PlayItem?>().firstWhere(
          (item) => item?.id == id,
          orElse: () => null,
        );
    if (removedItem == null) return;

    // If deleting current content, play next first
    final currentItem = state.currentItem;
    if (currentItem != null && currentItem.isSameContent(removedItem)) {
      // Find next item that's different
      final nextDifferent = state.list.cast<PlayItem?>().firstWhere(
            (item) => item != null && !item.isSameContent(removedItem),
            orElse: () => null,
          );

      if (nextDifferent == null) {
        await clear();
        return;
      }

      await playListItem(nextDifferent.id);
    }

    final newList =
        state.list.where((item) => !item.isSameContent(removedItem)).toList();
    state = state.copyWith(list: newList);
    unawaited(_saveState());
  }

  /// Clear the entire playlist
  Future<void> clear() async {
    await _playerService.stop();

    state = state.copyWith(
      isPlaying: false,
      list: [],
      clearPlayId: true,
      clearNextId: true,
      clearDuration: true,
      currentTime: 0,
    );

    unawaited(_saveState());
    unawaited(_saveCurrentTime());
  }

  // ============ Navigation ============

  /// Play next track
  Future<void> next() async {
    if (state.isEmpty || state.playId == null) return;

    // Play designated "next" item if set
    if (state.nextId != null) {
      await playListItem(state.nextId!);
      return;
    }

    final currentIndex = state.currentIndex;
    if (currentIndex == -1) return;

    String nextPlayId;

    switch (state.playMode) {
      case PlayMode.sequence:
      case PlayMode.single:
      case PlayMode.loop:
        if (state.length == 1) {
          // Single item - restart
          await seek(0);
          await _playerService.play();
          return;
        }
        final nextIndex = (currentIndex + 1) % state.length;
        nextPlayId = state.list[nextIndex].id;
        break;

      case PlayMode.random:
        if (state.length == 1) {
          // Single item - restart
          await seek(0);
          await _playerService.play();
          return;
        }

        // Keep page order for multi-part videos if enabled
        final currentItem = state.currentItem;
        if (state.shouldKeepPagesOrderInRandomPlayMode &&
            currentItem != null &&
            currentItem.pageIndex != null &&
            currentItem.totalPage != null &&
            currentItem.pageIndex! < currentItem.totalPage!) {
          // Find next page
          final nextPage = state.list.cast<PlayItem?>().firstWhere(
                (item) =>
                    item?.bvid == currentItem.bvid &&
                    item?.pageIndex == currentItem.pageIndex! + 1,
                orElse: () => null,
              );
          if (nextPage != null) {
            nextPlayId = nextPage.id;
            break;
          }
        }

        // Random selection (excluding current)
        final random = Random();
        int nextIndex;
        do {
          nextIndex = random.nextInt(state.length);
        } while (nextIndex == currentIndex && state.length > 1);
        nextPlayId = state.list[nextIndex].id;
        break;
    }

    await playListItem(nextPlayId);
  }

  /// Play previous track
  Future<void> prev() async {
    if (state.isEmpty || state.playId == null) return;

    final currentIndex = state.currentIndex;
    if (currentIndex == -1) return;

    final prevIndex = (currentIndex - 1 + state.length) % state.length;
    await playListItem(state.list[prevIndex].id);
  }

  /// Update audio URL for the current item
  void updateCurrentItemAudioUrl({
    required String audioUrl,
    String? videoUrl,
    bool? isLossless,
    bool? isDolby,
  }) {
    final currentItem = state.currentItem;
    if (currentItem == null) return;

    final updatedItem = currentItem.copyWith(
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      isLossless: isLossless,
      isDolby: isDolby,
    );

    final newList = state.list.map((item) {
      if (item.id == currentItem.id) return updatedItem;
      return item;
    }).toList();

    state = state.copyWith(list: newList);
    _saveState();
  }

  // ============ Private Methods ============

  Future<void> _playCurrentItem() async {
    final currentItem = state.currentItem;
    if (currentItem == null) {
      debugPrint('[Playlist] _playCurrentItem: No current item');
      return;
    }

    debugPrint('[Playlist] _playCurrentItem: Starting playback for ${currentItem.title}');

    // Clear any previous error
    state = state.copyWith(clearError: true);

    final success = await _ensureAudioUrlValid();
    if (!success) {
      debugPrint('[Playlist] Cannot play: audio URL not available');
      return;
    }

    // Update media session
    debugPrint('[Playlist] Updating media session');
    _audioHandler.updateCurrentMediaItem(currentItem);

    debugPrint('[Playlist] Starting player');
    try {
      await _playerService.play();
      debugPrint('[Playlist] Player started successfully');
    } catch (e) {
      debugPrint('[Playlist] Failed to start player: $e');
      state = state.copyWith(error: 'Failed to start playback: $e');
    }
    unawaited(_saveState());
    unawaited(_saveCurrentTime());
  }

  /// Ensures audio URL is valid and loaded. Returns true if successful.
  ///
  /// This method proactively checks URL validity using the deadline parameter
  /// before attempting playback, which provides a better user experience
  /// compared to waiting for playback to fail.
  ///
  /// Reference: `biu/src/store/play-list.ts:247-260`
  Future<bool> _ensureAudioUrlValid() async {
    final currentItem = state.currentItem;
    if (currentItem == null) {
      debugPrint('[Playlist] No current item to play');
      return false;
    }

    debugPrint('[Playlist] Ensuring audio URL valid for: ${currentItem.title}');
    debugPrint('[Playlist] Item type: ${currentItem.type}, bvid: ${currentItem.bvid}, sid: ${currentItem.sid}');

    // First, try to get a fresh URL if we don't have one or need to refresh
    var audioUrl = currentItem.audioUrl;

    // Check URL validity using deadline parameter
    // Bilibili URLs have a deadline query param that indicates expiry time
    final isValid = UrlUtils.isUrlValid(audioUrl);
    debugPrint('[Playlist] Current URL valid: $isValid');

    // Fetch fresh URL if:
    // 1. No URL available
    // 2. URL has expired (deadline passed)
    if (audioUrl == null || audioUrl.isEmpty || !isValid) {
      debugPrint('[Playlist] Fetching fresh audio URL (expired or missing)');
      audioUrl = await _fetchAudioUrl(currentItem);
      if (audioUrl != null) {
        updateCurrentItemAudioUrl(audioUrl: audioUrl);
      }
    }

    if (audioUrl == null || audioUrl.isEmpty) {
      debugPrint('[Playlist] Failed to get audio URL');
      state = state.copyWith(error: 'Failed to get audio URL');
      return false;
    }

    // Try to set the URL
    try {
      debugPrint('[Playlist] Setting audio URL...');
      await _playerService.setUrl(audioUrl);
      // On Windows, setUrl may return null duration but still work
      // We consider it successful if no exception was thrown
      debugPrint('[Playlist] Audio URL set successfully');
      return true;
    } catch (e) {
      debugPrint('[Playlist] Failed to set audio URL: $e, trying to refresh...');

      // Try to get a fresh URL
      final freshUrl = await _fetchAudioUrl(currentItem);
      if (freshUrl != null && freshUrl.isNotEmpty) {
        updateCurrentItemAudioUrl(audioUrl: freshUrl);
        try {
          await _playerService.setUrl(freshUrl);
          debugPrint('[Playlist] Fresh audio URL set successfully');
          return true;
        } catch (e2) {
          debugPrint('[Playlist] Failed to set fresh audio URL: $e2');
          state = state.copyWith(error: 'Failed to load audio');
          return false;
        }
      }

      state = state.copyWith(error: 'Failed to load audio');
      return false;
    }
  }

  /// Fetch audio URL for the given item
  Future<String?> _fetchAudioUrl(PlayItem item) async {
    if (item.type == PlayDataType.mv && item.bvid != null) {
      // Check if we have cid, if not fetch video info first
      var cid = item.cid;
      if (cid == null || cid.isEmpty) {
        debugPrint('[Playlist] No cid, fetching video info...');
        final videoInfo = await onFetchVideoInfo?.call(item.bvid!);
        if (videoInfo != null) {
          cid = videoInfo.cid;
          debugPrint('[Playlist] Got cid: $cid');
          _updateCurrentItemWithVideoInfo(item, videoInfo);
        } else {
          debugPrint('[Playlist] Failed to fetch video info');
          return null;
        }
      }

      if (cid.isNotEmpty) {
        debugPrint('[Playlist] Fetching MV audio URL with cid: $cid');
        return await onFetchMvAudioUrl?.call(item.bvid!, cid);
      }
    } else if (item.type == PlayDataType.audio && item.sid != null) {
      debugPrint('[Playlist] Fetching audio stream URL for sid: ${item.sid}');
      return await onFetchAudioUrl?.call(item.sid!);
    }

    debugPrint('[Playlist] Unknown item type or missing identifiers');
    return null;
  }

  /// Update current item with video info from API
  void _updateCurrentItemWithVideoInfo(PlayItem currentItem, VideoInfoResult info) {
    final updatedItem = currentItem.copyWith(
      cid: info.cid,
      aid: info.aid,
      title: info.title ?? currentItem.title,
      cover: info.cover ?? currentItem.cover,
      ownerName: info.ownerName ?? currentItem.ownerName,
      ownerMid: info.ownerMid ?? currentItem.ownerMid,
      duration: info.duration ?? currentItem.duration,
      hasMultiPart: info.hasMultiPart,
      pageIndex: info.pageIndex,
      pageTitle: info.pageTitle,
      pageCover: info.pageCover,
      totalPage: info.totalPage,
    );

    final newList = state.list.map((item) {
      if (item.id == currentItem.id) return updatedItem;
      return item;
    }).toList();

    state = state.copyWith(list: newList);
    unawaited(_saveState());
  }

  void _onTrackCompleted() {
    if (state.playMode == PlayMode.single) {
      // Loop mode is handled by just_audio
      return;
    }

    // Check if at end of sequence mode
    if (state.playMode == PlayMode.sequence) {
      final currentIndex = state.currentIndex;
      if (currentIndex == state.length - 1) {
        // End of playlist - stop
        unawaited(seek(0));
        unawaited(_playerService.pause());
        return;
      }
    }

    // Play next
    unawaited(next());
  }

  // ============ Persistence ============

  Future<void> _loadPersistedState() async {
    try {
      final storage = ref.read(storageServiceProvider);
      final jsonString = await storage.getString(_StorageKeys.playlistState);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = PlaylistState.fromJson(json);
      }
    } catch (e) {
      // Ignore persistence errors
    }
  }

  Future<void> _saveState() async {
    try {
      final storage = ref.read(storageServiceProvider);
      final jsonString = jsonEncode(state.toJson());
      await storage.setString(_StorageKeys.playlistState, jsonString);
    } catch (e) {
      // Ignore persistence errors
    }
  }

  Future<double> _loadCurrentTime() async {
    try {
      final storage = ref.read(storageServiceProvider);
      return await storage.getDouble(_StorageKeys.currentTime) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> _saveCurrentTime() async {
    try {
      final storage = ref.read(storageServiceProvider);
      await storage.setDouble(_StorageKeys.currentTime, state.currentTime);
    } catch (e) {
      // Ignore persistence errors
    }
  }

  /// Get the current item (for external access)
  PlayItem? getPlayItem() => state.currentItem;

  /// Get the audio player service (for external access)
  AudioPlayerService getPlayerService() => _playerService;
}

/// Provider for the playlist notifier
final playlistProvider =
    NotifierProvider<PlaylistNotifier, PlaylistState>(PlaylistNotifier.new);

/// Provider for the current play item
final currentPlayItemProvider = Provider<PlayItem?>((ref) {
  return ref.watch(playlistProvider).currentItem;
});

/// Provider for the playing state
final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(playlistProvider).isPlaying;
});

/// Provider for the current position
final currentPositionProvider = Provider<double>((ref) {
  return ref.watch(playlistProvider).currentTime;
});

/// Provider for the duration
final durationProvider = Provider<double?>((ref) {
  return ref.watch(playlistProvider).duration;
});

/// Provider for the play mode
final playModeProvider = Provider<PlayMode>((ref) {
  return ref.watch(playlistProvider).playMode;
});

/// Provider for the loading state
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(playlistProvider).isLoading;
});

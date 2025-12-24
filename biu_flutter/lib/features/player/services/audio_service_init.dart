import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:biu_flutter/features/audio/data/datasources/audio_remote_datasource.dart';
import 'package:biu_flutter/features/player/presentation/providers/playlist_notifier.dart';
import 'package:biu_flutter/features/player/services/audio_player_service.dart';
import 'package:biu_flutter/features/video/data/datasources/video_remote_datasource.dart';

/// Initializes the audio service and player for background playback.
/// Must be called early in app startup, before runApp().
Future<BiuAudioHandler> initializeAudioService(ProviderContainer container) async {
  final playlistNotifier = container.read(playlistProvider.notifier);
  final playerService = playlistNotifier.getPlayerService();

  final audioHandler = await AudioService.init(
    builder: () => BiuAudioHandler(
      playerService: playerService,
      onPlayNext: () => playlistNotifier.next(),
      onPlayPrevious: () => playlistNotifier.prev(),
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.biu_flutter.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  playlistNotifier.setAudioHandler(audioHandler);

  // Set up audio URL fetch callbacks
  _setupAudioFetchCallbacks(playlistNotifier);

  await playlistNotifier.initialize();

  return audioHandler;
}

/// Set up callbacks for fetching audio URLs and video info
void _setupAudioFetchCallbacks(PlaylistNotifier notifier) {
  final videoDataSource = VideoRemoteDataSource();
  final audioDataSource = AudioRemoteDataSource();

  // Callback for fetching video play URL (audio stream from video)
  notifier.onFetchMvAudioUrl = (String bvid, String cid) async {
    try {
      final playUrl = await videoDataSource.getPlayUrl(
        bvid: bvid,
        cid: int.parse(cid),
        fnval: 16, // DASH format
      );

      // Get best audio stream
      final bestAudio = playUrl.dash?.getBestAudio();
      if (bestAudio != null) {
        return bestAudio.baseUrl.isNotEmpty
            ? bestAudio.baseUrl
            : bestAudio.backupUrl.isNotEmpty
                ? bestAudio.backupUrl.first
                : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  };

  // Callback for fetching audio stream URL (Bilibili music)
  notifier.onFetchAudioUrl = (int sid) async {
    try {
      final audioStream = await audioDataSource.getAudioStreamUrl(
        songId: sid,
        quality: 2, // 192kbps by default, can be upgraded for VIP
      );
      return audioStream.primaryUrl;
    } catch (e) {
      return null;
    }
  };

  // Callback for fetching video info (to get cid)
  notifier.onFetchVideoInfo = (String bvid) async {
    try {
      final videoInfo = await videoDataSource.getVideoInfo(bvid: bvid);
      if (videoInfo.pages.isEmpty) return null;

      final firstPage = videoInfo.pages.first;
      final hasMultiPart = videoInfo.pages.length > 1;

      return VideoInfoResult(
        cid: firstPage.cid.toString(),
        aid: videoInfo.aid.toString(),
        title: videoInfo.title,
        cover: videoInfo.pic,
        ownerName: videoInfo.owner.name,
        ownerMid: videoInfo.owner.mid,
        duration: firstPage.duration,
        hasMultiPart: hasMultiPart,
        pageIndex: firstPage.page,
        pageTitle: hasMultiPart ? firstPage.part : videoInfo.title,
        pageCover: firstPage.firstFrame ?? videoInfo.pic,
        totalPage: videoInfo.pages.length,
      );
    } catch (e) {
      return null;
    }
  };
}

/// Provider for the audio handler (available after initialization)
final audioHandlerProvider = Provider<BiuAudioHandler?>((ref) {
  // This will be set during app initialization
  return null;
});

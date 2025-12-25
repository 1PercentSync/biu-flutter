import 'package:audio_service/audio_service.dart';
import 'package:biu_flutter/features/audio/data/datasources/audio_remote_datasource.dart';
import 'package:biu_flutter/features/auth/presentation/providers/auth_notifier.dart';
import 'package:biu_flutter/features/player/presentation/providers/playlist_notifier.dart';
import 'package:biu_flutter/features/player/services/audio_player_service.dart';
import 'package:biu_flutter/features/settings/presentation/providers/settings_notifier.dart';
import 'package:biu_flutter/features/video/data/datasources/video_remote_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Video fnval constants for requesting video streams
///
/// These are bitwise flags used to request specific video formats/qualities.
/// Multiple flags can be combined using OR (|) operator.
///
/// Source: biu/src/common/constants/video.ts
class VideoFnval {
  VideoFnval._();

  /// MP4 format, H.264 encoding only
  static const int mp4 = 1;

  /// DASH format
  static const int dash = 16;

  /// HDR video, H.265 encoding, requires qn=125, VIP membership
  static const int hdr = 64;

  /// 4K resolution, requires qn=120 and fourk=1, VIP membership
  static const int fourK = 128;

  /// Dolby Audio, VIP membership
  static const int dolbyAudio = 256;

  /// Dolby Vision, VIP membership
  static const int dolbyVideo = 512;

  /// 8K resolution, requires qn=127, VIP membership
  static const int eightK = 1024;

  /// AV1 encoding
  static const int av1 = 2048;

  /// All available DASH streams (including FLAC and Dolby)
  /// = dash | hdr | fourK | dolbyAudio | dolbyVideo | eightK | av1
  static const int allDash = 4048;
}

/// Initializes the audio service and player for background playback.
/// Must be called early in app startup, before runApp().
Future<BiuAudioHandler> initializeAudioService(ProviderContainer container) async {
  final playlistNotifier = container.read(playlistProvider.notifier);
  final playerService = playlistNotifier.getPlayerService();

  final audioHandler = await AudioService.init(
    builder: () => BiuAudioHandler(
      playerService: playerService,
      onPlayNext: playlistNotifier.next,
      onPlayPrevious: playlistNotifier.prev,
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.biu_flutter.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationOngoing: true,
    ),
  );

  playlistNotifier.audioHandler = audioHandler;

  // Set up audio URL fetch callbacks with access to container for user state
  _setupAudioFetchCallbacks(playlistNotifier, container);

  await playlistNotifier.initialize();

  return audioHandler;
}

/// Set up callbacks for fetching audio URLs and video info
void _setupAudioFetchCallbacks(PlaylistNotifier notifier, ProviderContainer container) {
  final videoDataSource = VideoRemoteDataSource();
  final audioDataSource = AudioRemoteDataSource();

  notifier
    // Callback for fetching video play URL (audio stream from video)
    ..onFetchMvAudioUrl = (String bvid, String cid) async {
      try {
        debugPrint('[Audio] Fetching MV audio URL: bvid=$bvid, cid=$cid');

        // Get user audio quality preference from settings
        final audioQuality = container.read(settingsNotifierProvider).audioQuality;
        debugPrint('[Audio] User audio quality preference: ${audioQuality.value}');

        final playUrl = await videoDataSource.getPlayUrl(
          bvid: bvid,
          cid: int.parse(cid),
          fnval: VideoFnval.allDash, // Use AllDash to get FLAC and Dolby
        );

        final dash = playUrl.dash;
        if (dash == null) {
          debugPrint('[Audio] No DASH data available');
          return null;
        }

        // Select audio stream based on user quality preference
        // Reference: `biu/src/common/utils/audio.ts:selectAudioByQuality`
        final selectedAudio = dash.selectAudioByQuality(audioQuality.value);
        if (selectedAudio != null) {
          final url = selectedAudio.baseUrl.isNotEmpty
              ? selectedAudio.baseUrl
              : selectedAudio.backupUrl.isNotEmpty
                  ? selectedAudio.backupUrl.first
                  : null;

          debugPrint('[Audio] Got audio URL: ${url?.substring(0, 50)}..., '
              'quality=${audioQuality.value}, flac=${dash.hasFlac}, dolby=${dash.hasDolby}');
          return url;
        }

        debugPrint('[Audio] No audio stream found');
        return null;
      } catch (e, stackTrace) {
        debugPrint('[Audio] Error fetching MV audio URL: $e');
        debugPrint('[Audio] Stack trace: $stackTrace');
        return null;
      }
    }
    // Callback for fetching audio stream URL (Bilibili music)
    ..onFetchAudioUrl = (int sid) async {
      try {
        debugPrint('[Audio] Fetching audio stream URL: sid=$sid');

        // Get user VIP status for quality selection
        final user = container.read(currentUserProvider);
        final isVip = user?.isVip ?? false;
        final quality = isVip ? 3 : 2; // 3 for FLAC (VIP), 2 for 192kbps
        final mid = user?.mid;

        debugPrint('[Audio] User VIP: $isVip, quality: $quality, mid: $mid');

        final audioStream = await audioDataSource.getAudioStreamUrl(
          songId: sid,
          quality: quality,
          mid: mid,
        );

        final url = audioStream.primaryUrl;
        debugPrint('[Audio] Got audio stream URL: ${url?.substring(0, 50) ?? 'null'}...');
        return url;
      } catch (e, stackTrace) {
        debugPrint('[Audio] Error fetching audio stream URL: $e');
        debugPrint('[Audio] Stack trace: $stackTrace');
        return null;
      }
    }
    // Callback for fetching video info (to get cid)
    ..onFetchVideoInfo = (String bvid) async {
      try {
        debugPrint('[Audio] Fetching video info: bvid=$bvid');

        final videoInfo = await videoDataSource.getVideoInfo(bvid: bvid);
        if (videoInfo.pages.isEmpty) {
          debugPrint('[Audio] Video has no pages');
          return null;
        }

        final firstPage = videoInfo.pages.first;
        final hasMultiPart = videoInfo.pages.length > 1;

        debugPrint('[Audio] Got video info: title=${videoInfo.title}, '
            'cid=${firstPage.cid}, pages=${videoInfo.pages.length}');

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
      } catch (e, stackTrace) {
        debugPrint('[Audio] Error fetching video info: $e');
        debugPrint('[Audio] Stack trace: $stackTrace');
        return null;
      }
    };
}

/// Provider for the audio handler (available after initialization)
final audioHandlerProvider = Provider<BiuAudioHandler?>((ref) {
  // This will be set during app initialization
  return null;
});

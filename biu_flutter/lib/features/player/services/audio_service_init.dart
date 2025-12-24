import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:biu_flutter/features/player/presentation/providers/playlist_notifier.dart';
import 'package:biu_flutter/features/player/services/audio_player_service.dart';

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
  await playlistNotifier.initialize();

  return audioHandler;
}

/// Provider for the audio handler (available after initialization)
final audioHandlerProvider = Provider<BiuAudioHandler?>((ref) {
  // This will be set during app initialization
  return null;
});

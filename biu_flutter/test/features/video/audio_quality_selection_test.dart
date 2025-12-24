import 'package:biu_flutter/features/video/data/models/play_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashAudio', () {
    test('creates audio stream from JSON', () {
      final json = {
        'id': 30280,
        'baseUrl': 'https://example.com/audio.m4s',
        'bandwidth': 192000,
        'mimeType': 'audio/mp4',
        'codecs': 'mp4a.40.2',
        'backupUrl': ['https://backup.com/audio.m4s'],
      };
      final audio = DashAudio.fromJson(json);

      expect(audio.id, 30280);
      expect(audio.baseUrl, 'https://example.com/audio.m4s');
      expect(audio.bandwidth, 192000);
      expect(audio.mimeType, 'audio/mp4');
      expect(audio.codecs, 'mp4a.40.2');
      expect(audio.backupUrl, ['https://backup.com/audio.m4s']);
    });

    test('handles snake_case JSON keys', () {
      final json = {
        'id': 30232,
        'base_url': 'https://example.com/audio.m4s',
        'bandwidth': 132000,
        'mime_type': 'audio/mp4',
        'codecs': 'mp4a.40.2',
        'backup_url': ['https://backup.com/audio.m4s'],
      };
      final audio = DashAudio.fromJson(json);

      expect(audio.id, 30232);
      expect(audio.baseUrl, 'https://example.com/audio.m4s');
      expect(audio.bandwidth, 132000);
    });
  });

  group('DashInfo.selectAudioByQuality', () {
    late DashInfo dashInfo;

    setUp(() {
      // Create test audio streams with different qualities
      final audioStreams = [
        const DashAudio(
          id: 30257, // 64K
          baseUrl: 'https://example.com/64k.m4s',
          bandwidth: 64000,
          mimeType: 'audio/mp4',
          codecs: 'mp4a.40.2',
        ),
        const DashAudio(
          id: 30232, // 132K
          baseUrl: 'https://example.com/132k.m4s',
          bandwidth: 132000,
          mimeType: 'audio/mp4',
          codecs: 'mp4a.40.2',
        ),
        const DashAudio(
          id: 30280, // 192K
          baseUrl: 'https://example.com/192k.m4s',
          bandwidth: 192000,
          mimeType: 'audio/mp4',
          codecs: 'mp4a.40.2',
        ),
      ];

      dashInfo = DashInfo(
        duration: 300,
        minBufferTime: 1.5,
        audio: audioStreams,
      );
    });

    test('auto quality returns highest available', () {
      final audio = dashInfo.selectAudioByQuality('auto');
      expect(audio, isNotNull);
      // Should return highest bandwidth (192K)
      expect(audio!.bandwidth, 192000);
    });

    test('high quality returns highest bandwidth audio', () {
      final audio = dashInfo.selectAudioByQuality('high');
      expect(audio, isNotNull);
      expect(audio!.bandwidth, 192000);
    });

    test('standard quality returns middle bandwidth audio', () {
      final audio = dashInfo.selectAudioByQuality('standard');
      expect(audio, isNotNull);
      // Should return middle quality
      expect(audio!.bandwidth, 132000);
    });

    test('low quality returns lowest bandwidth audio', () {
      final audio = dashInfo.selectAudioByQuality('low');
      expect(audio, isNotNull);
      expect(audio!.bandwidth, 64000);
    });

    test('returns null for empty audio list', () {
      const emptyDash = DashInfo(
        duration: 300,
        minBufferTime: 1.5,
      );
      final audio = emptyDash.selectAudioByQuality('high');
      expect(audio, isNull);
    });
  });

  group('DashInfo with FLAC', () {
    test('lossless quality prefers FLAC', () {
      const flacAudio = DashAudio(
        id: 30251, // Hi-Res/FLAC
        baseUrl: 'https://example.com/flac.m4s',
        bandwidth: 900000,
        mimeType: 'audio/flac',
        codecs: 'flac',
      );

      const dashInfo = DashInfo(
        duration: 300,
        minBufferTime: 1.5,
        audio: [
          DashAudio(
            id: 30280,
            baseUrl: 'https://example.com/192k.m4s',
            bandwidth: 192000,
            mimeType: 'audio/mp4',
            codecs: 'mp4a.40.2',
          ),
        ],
        flac: FlacInfo(display: true, audio: flacAudio),
      );

      final audio = dashInfo.selectAudioByQuality('lossless');
      expect(audio, isNotNull);
      expect(audio!.codecs, 'flac');
    });

    test('hasFlac returns true when FLAC available', () {
      const dashInfo = DashInfo(
        duration: 300,
        minBufferTime: 1.5,
        flac: FlacInfo(
          display: true,
          audio: DashAudio(
            id: 30251,
            baseUrl: 'https://example.com/flac.m4s',
            bandwidth: 900000,
            mimeType: 'audio/flac',
            codecs: 'flac',
          ),
        ),
      );

      expect(dashInfo.hasFlac, true);
    });

    test('hasFlac returns false when FLAC not available', () {
      const dashInfo = DashInfo(
        duration: 300,
        minBufferTime: 1.5,
      );

      expect(dashInfo.hasFlac, false);
    });
  });

  group('DashInfo with Dolby', () {
    test('auto quality prefers Dolby over standard audio', () {
      const dolbyAudio = DashAudio(
        id: 30250, // Dolby
        baseUrl: 'https://example.com/dolby.m4s',
        bandwidth: 384000,
        mimeType: 'audio/mp4',
        codecs: 'ec-3',
      );

      const dashInfo = DashInfo(
        duration: 300,
        minBufferTime: 1.5,
        audio: [
          DashAudio(
            id: 30280,
            baseUrl: 'https://example.com/192k.m4s',
            bandwidth: 192000,
            mimeType: 'audio/mp4',
            codecs: 'mp4a.40.2',
          ),
        ],
        dolby: DolbyInfo(type: 2, audio: [dolbyAudio]),
      );

      final audio = dashInfo.selectAudioByQuality('auto');
      expect(audio, isNotNull);
      expect(audio!.codecs, 'ec-3');
    });

    test('hasDolby returns true when Dolby available', () {
      const dashInfo = DashInfo(
        duration: 300,
        minBufferTime: 1.5,
        dolby: DolbyInfo(
          type: 2,
          audio: [
            DashAudio(
              id: 30250,
              baseUrl: 'https://example.com/dolby.m4s',
              bandwidth: 384000,
              mimeType: 'audio/mp4',
              codecs: 'ec-3',
            ),
          ],
        ),
      );

      expect(dashInfo.hasDolby, true);
    });
  });

  group('DashInfo.getBestAudio', () {
    test('returns FLAC when available', () {
      const dashInfo = DashInfo(
        duration: 300,
        minBufferTime: 1.5,
        audio: [
          DashAudio(
            id: 30280,
            baseUrl: 'https://example.com/192k.m4s',
            bandwidth: 192000,
            mimeType: 'audio/mp4',
            codecs: 'mp4a.40.2',
          ),
        ],
        flac: FlacInfo(
          display: true,
          audio: DashAudio(
            id: 30251,
            baseUrl: 'https://example.com/flac.m4s',
            bandwidth: 900000,
            mimeType: 'audio/flac',
            codecs: 'flac',
          ),
        ),
      );

      final audio = dashInfo.getBestAudio();
      expect(audio, isNotNull);
      expect(audio!.codecs, 'flac');
    });

    test('returns highest bandwidth standard audio when no FLAC/Dolby', () {
      const dashInfo = DashInfo(
        duration: 300,
        minBufferTime: 1.5,
        audio: [
          DashAudio(
            id: 30257,
            baseUrl: 'https://example.com/64k.m4s',
            bandwidth: 64000,
            mimeType: 'audio/mp4',
            codecs: 'mp4a.40.2',
          ),
          DashAudio(
            id: 30280,
            baseUrl: 'https://example.com/192k.m4s',
            bandwidth: 192000,
            mimeType: 'audio/mp4',
            codecs: 'mp4a.40.2',
          ),
        ],
      );

      final audio = dashInfo.getBestAudio();
      expect(audio, isNotNull);
      expect(audio!.bandwidth, 192000);
    });
  });
}

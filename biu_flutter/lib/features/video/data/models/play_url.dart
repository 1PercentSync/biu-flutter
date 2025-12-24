/// DASH audio stream info
class DashAudio {
  const DashAudio({
    required this.id,
    required this.baseUrl,
    required this.bandwidth,
    required this.mimeType,
    required this.codecs,
    this.backupUrl = const [],
  });

  factory DashAudio.fromJson(Map<String, dynamic> json) {
    return DashAudio(
      id: json['id'] as int? ?? 0,
      baseUrl: json['baseUrl'] as String? ?? json['base_url'] as String? ?? '',
      bandwidth: json['bandwidth'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? json['mime_type'] as String? ?? '',
      codecs: json['codecs'] as String? ?? '',
      backupUrl: (json['backupUrl'] as List<dynamic>? ?? json['backup_url'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final int id;
  final String baseUrl;
  final int bandwidth;
  final String mimeType;
  final String codecs;
  final List<String> backupUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'baseUrl': baseUrl,
    'bandwidth': bandwidth,
    'mimeType': mimeType,
    'codecs': codecs,
    'backupUrl': backupUrl,
  };
}

/// DASH video stream info
class DashVideo {
  const DashVideo({
    required this.id,
    required this.baseUrl,
    required this.bandwidth,
    required this.mimeType,
    required this.codecs,
    required this.width,
    required this.height,
    required this.frameRate,
    this.backupUrl = const [],
  });

  factory DashVideo.fromJson(Map<String, dynamic> json) {
    return DashVideo(
      id: json['id'] as int? ?? 0,
      baseUrl: json['baseUrl'] as String? ?? json['base_url'] as String? ?? '',
      bandwidth: json['bandwidth'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? json['mime_type'] as String? ?? '',
      codecs: json['codecs'] as String? ?? '',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      frameRate: json['frameRate'] as String? ?? json['frame_rate'] as String? ?? '0',
      backupUrl: (json['backupUrl'] as List<dynamic>? ?? json['backup_url'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final int id;
  final String baseUrl;
  final int bandwidth;
  final String mimeType;
  final String codecs;
  final int width;
  final int height;
  final String frameRate;
  final List<String> backupUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'baseUrl': baseUrl,
    'bandwidth': bandwidth,
    'mimeType': mimeType,
    'codecs': codecs,
    'width': width,
    'height': height,
    'frameRate': frameRate,
    'backupUrl': backupUrl,
  };
}

/// Flac audio info
class FlacInfo {
  const FlacInfo({
    required this.display,
    this.audio,
  });

  factory FlacInfo.fromJson(Map<String, dynamic> json) {
    return FlacInfo(
      display: json['display'] as bool? ?? false,
      audio: json['audio'] != null
          ? DashAudio.fromJson(json['audio'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool display;
  final DashAudio? audio;

  Map<String, dynamic> toJson() => {
    'display': display,
    'audio': audio?.toJson(),
  };
}

/// Dolby audio info
class DolbyInfo {
  const DolbyInfo({
    required this.type,
    this.audio = const [],
  });

  factory DolbyInfo.fromJson(Map<String, dynamic> json) {
    return DolbyInfo(
      type: json['type'] as int? ?? 0,
      audio: (json['audio'] as List<dynamic>?)
              ?.map((e) => DashAudio.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final int type;
  final List<DashAudio> audio;

  Map<String, dynamic> toJson() => {
    'type': type,
    'audio': audio.map((e) => e.toJson()).toList(),
  };
}

/// DASH stream info
class DashInfo {
  const DashInfo({
    required this.duration,
    required this.minBufferTime,
    this.video = const [],
    this.audio = const [],
    this.flac,
    this.dolby,
  });

  factory DashInfo.fromJson(Map<String, dynamic> json) {
    return DashInfo(
      duration: json['duration'] as int? ?? 0,
      minBufferTime: (json['minBufferTime'] as num?)?.toDouble() ??
                     (json['min_buffer_time'] as num?)?.toDouble() ?? 0,
      video: (json['video'] as List<dynamic>?)
              ?.map((e) => DashVideo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      audio: (json['audio'] as List<dynamic>?)
              ?.map((e) => DashAudio.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      flac: json['flac'] != null
          ? FlacInfo.fromJson(json['flac'] as Map<String, dynamic>)
          : null,
      dolby: json['dolby'] != null
          ? DolbyInfo.fromJson(json['dolby'] as Map<String, dynamic>)
          : null,
    );
  }

  final int duration;
  final double minBufferTime;
  final List<DashVideo> video;
  final List<DashAudio> audio;
  final FlacInfo? flac;
  final DolbyInfo? dolby;

  /// Get best audio stream by quality
  /// Priority: FLAC > Dolby > highest quality standard audio
  DashAudio? getBestAudio() {
    // Try FLAC first (lossless)
    if (flac?.audio != null) {
      return flac!.audio;
    }

    // Try Dolby
    if (dolby != null && dolby!.audio.isNotEmpty) {
      return dolby!.audio.first;
    }

    // Fall back to standard audio
    if (audio.isEmpty) return null;
    // Sort by id (higher = better quality) and bandwidth
    final sorted = List<DashAudio>.from(audio)
      ..sort((a, b) {
        final idCompare = b.id.compareTo(a.id);
        if (idCompare != 0) return idCompare;
        return b.bandwidth.compareTo(a.bandwidth);
      });
    return sorted.first;
  }

  /// Check if FLAC audio is available
  bool get hasFlac => flac?.audio != null;

  /// Check if Dolby audio is available
  bool get hasDolby => dolby != null && dolby!.audio.isNotEmpty;

  /// Get audio stream by quality id
  DashAudio? getAudioByQuality(int qualityId) {
    return audio.where((a) => a.id == qualityId).firstOrNull ??
        audio.where((a) => a.id <= qualityId).firstOrNull;
  }

  /// Sort audio streams by quality (highest first).
  /// Priority: Higher quality ID, then higher bandwidth.
  ///
  /// Reference: `biu/src/common/utils/audio.ts:sortAudio`
  List<DashAudio> _sortAudioByQuality() {
    if (audio.isEmpty) return [];

    // Audio quality sort order (higher index = better)
    const qualitySort = [
      30257, // 64K
      30216, // 64K (legacy)
      30259, // 128K
      30260, // 128K (legacy)
      30232, // 132K
      30280, // 192K
      30250, // Dolby
      30251, // Hi-Res
    ];

    final sorted = List<DashAudio>.from(audio)
      ..sort((a, b) {
        // First sort by bandwidth (higher = better)
        if (a.bandwidth != b.bandwidth) {
          return b.bandwidth.compareTo(a.bandwidth);
        }

        // Then sort by quality ID position
        final indexA = qualitySort.indexOf(a.id);
        final indexB = qualitySort.indexOf(b.id);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexB.compareTo(indexA);
      });

    return sorted;
  }

  /// Select audio by user quality preference.
  ///
  /// [quality] can be:
  /// - 'auto' or 'lossless': FLAC > Dolby > highest standard
  /// - 'high': Highest bitrate standard audio (192K)
  /// - 'standard': Middle bitrate (128K)
  /// - 'low': Lowest bitrate (64K)
  /// - 'hires': Lossless only (FLAC), fallback to Dolby
  ///
  /// Reference: `biu/src/common/utils/audio.ts:selectAudioByQuality`
  DashAudio? selectAudioByQuality(String quality) {
    // For auto and lossless/hires, prefer FLAC and Dolby
    if (quality == 'auto' || quality == 'hires' || quality == 'lossless') {
      // Try FLAC first (lossless)
      if (flac?.audio != null) {
        return flac!.audio;
      }

      // Try Dolby
      if (dolby != null && dolby!.audio.isNotEmpty) {
        return dolby!.audio.first;
      }

      // For 'hires', if no lossless available, still fall back to best standard
      // For 'auto', always fall back to best standard
    }

    // Get sorted standard audio list
    final sortedList = _sortAudioByQuality();
    if (sortedList.isEmpty) return null;

    switch (quality) {
      case 'high':
        // Return highest quality
        return sortedList.first;

      case 'standard':
        // Return middle quality
        final midIndex = (sortedList.length - 1) ~/ 2;
        return sortedList[midIndex];

      case 'low':
        // Return lowest quality
        return sortedList.last;

      default:
        // Default to highest available
        return sortedList.first;
    }
  }

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'minBufferTime': minBufferTime,
    'video': video.map((e) => e.toJson()).toList(),
    'audio': audio.map((e) => e.toJson()).toList(),
    'flac': flac?.toJson(),
    'dolby': dolby?.toJson(),
  };
}

/// Play URL response data
class PlayUrlData {
  const PlayUrlData({
    required this.quality,
    required this.timelength,
    required this.acceptQuality,
    this.dash,
  });

  factory PlayUrlData.fromJson(Map<String, dynamic> json) {
    return PlayUrlData(
      quality: json['quality'] as int? ?? 0,
      timelength: json['timelength'] as int? ?? 0,
      acceptQuality: (json['accept_quality'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      dash: json['dash'] != null
          ? DashInfo.fromJson(json['dash'] as Map<String, dynamic>)
          : null,
    );
  }

  final int quality;
  final int timelength;
  final List<int> acceptQuality;
  final DashInfo? dash;

  Map<String, dynamic> toJson() => {
    'quality': quality,
    'timelength': timelength,
    'accept_quality': acceptQuality,
    'dash': dash?.toJson(),
  };
}

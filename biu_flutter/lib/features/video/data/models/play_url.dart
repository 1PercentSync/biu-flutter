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

/// DASH stream info
class DashInfo {
  const DashInfo({
    required this.duration,
    required this.minBufferTime,
    this.video = const [],
    this.audio = const [],
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
    );
  }

  final int duration;
  final double minBufferTime;
  final List<DashVideo> video;
  final List<DashAudio> audio;

  /// Get best audio stream by quality
  DashAudio? getBestAudio() {
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

  /// Get audio stream by quality id
  DashAudio? getAudioByQuality(int qualityId) {
    return audio.where((a) => a.id == qualityId).firstOrNull ??
        audio.where((a) => a.id <= qualityId).firstOrNull;
  }

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'minBufferTime': minBufferTime,
    'video': video.map((e) => e.toJson()).toList(),
    'audio': audio.map((e) => e.toJson()).toList(),
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

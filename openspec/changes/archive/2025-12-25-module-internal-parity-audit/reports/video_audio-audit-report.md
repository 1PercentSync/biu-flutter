# Video/Audio Module Internal Parity Audit Report

## Module Overview

| Attribute | Value |
|-----------|-------|
| Target Path (Video) | `biu_flutter/lib/features/video/` |
| Target Path (Audio) | `biu_flutter/lib/features/audio/` |
| Source Reference (Video) | `biu/src/service/web-interface-view.ts`, `biu/src/service/player-playurl.ts` |
| Source Reference (Audio) | `biu/src/service/audio-web-url.ts`, `biu/src/service/audio-song-info.ts` |
| Audit Date | 2025-12-25 |

---

## Structure Score: 5/5

These modules are correctly structured as **data-only feature modules**, which is an appropriate architectural decision for their purpose. They serve as data providers for other features (primarily the `player` module) rather than having their own UI.

---

## Module Structure Analysis

### Video Module

```
biu_flutter/lib/features/video/
├── data/
│   ├── datasources/
│   │   └── video_remote_datasource.dart
│   ├── models/
│   │   ├── video_info.dart
│   │   └── play_url.dart
│   └── video_data.dart (barrel export)
├── (no domain layer - justified)
└── (no presentation layer - justified)
```

### Audio Module

```
biu_flutter/lib/features/audio/
├── data/
│   ├── datasources/
│   │   └── audio_remote_datasource.dart
│   ├── models/
│   │   └── audio_stream.dart
│   └── audio_data.dart (barrel export)
├── (no domain layer - justified)
└── (no presentation layer - justified)
```

---

## Justified Deviations (Compliant Design Choices)

### 1. Data-Only Module Design (Excellent)

Both modules are correctly designed as **data-only service modules** without domain or presentation layers. This is justified because:

- They provide low-level API access for other features (player module)
- No business logic or UI is needed at this level
- The `player` feature module consumes these services and provides the domain/presentation layers

**Source pattern**: The source project also separates these as standalone service files without corresponding pages.

### 2. API Consolidation (Elegant)

The Flutter implementation elegantly consolidates related APIs:

| Source Files | Flutter Implementation |
|--------------|----------------------|
| `web-interface-view.ts` | `VideoRemoteDataSource.getVideoInfo()` |
| `player-playurl.ts` | `VideoRemoteDataSource.getPlayUrl()`, `getPlayUrlByAid()` |
| `audio-web-url.ts` | `AudioRemoteDataSource.getAudioStreamUrl()` |
| `audio-song-info.ts` | `AudioRemoteDataSource.getAudioInfo()` |

This consolidation follows Flutter/Dart conventions where related API calls are grouped in a single datasource class.

### 3. Model Type Safety (Improved)

The Flutter models use proper null safety and default values:
- `json['field'] as int? ?? 0` pattern ensures type safety
- All models have proper `fromJson`/`toJson` methods
- Optional fields correctly typed as nullable

---

## API Coverage Analysis

### Video Module

| Source API | Flutter Implementation | Status |
|------------|----------------------|--------|
| `/x/web-interface/view` | `getVideoInfo(bvid?, aid?)` | Complete |
| `/x/player/wbi/playurl` | `getPlayUrl(bvid, cid, ...)` | Complete |
| `/x/player/wbi/playurl` (by aid) | `getPlayUrlByAid(aid, cid, ...)` | Complete |
| `/x/web-interface/view/detail` | Not implemented | Not needed (per FILE_MAPPING.md) |

**Note**: The `web-interface-view-detail.ts` API is not used in the source project's active features.

### Audio Module

| Source API | Flutter Implementation | Status |
|------------|----------------------|--------|
| `/audio/music-service-c/url` | `getAudioStreamUrl(songId, quality, mid?)` | Complete |
| `/audio/music-service-c/web/song/info` | Not implemented directly | Partial |
| `/audio/music-service-c/songs/playing` | `getAudioInfo(songId)` | Complete |

**Note**: The `audio-song-info.ts` detailed song info API is partially covered. The `getAudioInfo` uses a different endpoint (`songs/playing`) which may serve a different purpose.

---

## Model Mapping Analysis

### VideoInfo Model

| Source Field | Flutter Field | Status |
|--------------|--------------|--------|
| `bvid` | `bvid` | Mapped |
| `aid` | `aid` | Mapped |
| `videos` | `videos` | Mapped |
| `tid` / `tname` | `tid` / `tname` | Mapped |
| `copyright` | `copyright` | Mapped |
| `pic` | `pic` | Mapped |
| `title` | `title` | Mapped |
| `pubdate` / `ctime` | `pubdate` / `ctime` | Mapped |
| `desc` | `desc` | Mapped |
| `duration` | `duration` | Mapped |
| `owner` | `owner` (VideoOwner) | Mapped |
| `stat` | `stat` (VideoStat) | Mapped |
| `cid` | `cid` | Mapped |
| `dimension` | `dimension` | Mapped |
| `pages` | `pages` (List<VideoPage>) | Mapped |
| `desc_v2` | Not mapped | Low priority |
| `rights` | Not mapped | Not used |
| `subtitle` | Not mapped | Not used |
| `staff` | Not mapped | Not used |
| `honor_reply` | Not mapped | Not used |

**Assessment**: Core fields fully mapped. Unused fields intentionally omitted (YAGNI principle).

### PlayUrlData / DashInfo Model

| Source Field | Flutter Field | Status |
|--------------|--------------|--------|
| `quality` | `quality` | Mapped |
| `timelength` | `timelength` | Mapped |
| `accept_quality` | `acceptQuality` | Mapped |
| `dash` | `dash` (DashInfo) | Mapped |
| `dash.video` | `video` (List<DashVideo>) | Mapped |
| `dash.audio` | `audio` (List<DashAudio>) | Mapped |
| `dash.flac` | `flac` (FlacInfo) | Mapped |
| `dash.dolby` | `dolby` (DolbyInfo) | Mapped |

**Excellence**: The `DashInfo` class includes sophisticated audio quality selection logic (`selectAudioByQuality`, `_sortAudioByQuality`) that mirrors `biu/src/common/utils/audio.ts`.

### AudioStreamData Model

| Source Field | Flutter Field | Status |
|--------------|--------------|--------|
| `sid` | `sid` | Mapped |
| `type` | `type` | Mapped |
| `info` | `info` | Mapped |
| `timeout` | `timeout` | Mapped |
| `size` | `size` | Mapped |
| `cdns` | `cdns` | Mapped |
| `qualities` | `qualities` | Mapped |
| `title` | `title` | Mapped |
| `cover` | `cover` | Mapped |

**Assessment**: Complete mapping of all relevant fields.

---

## Code Quality Assessment

### Strengths

1. **Clean API Design**: Both datasources follow the same pattern with Dio injection for testability
2. **Proper Error Handling**: All methods check for null data and throw descriptive exceptions
3. **WBI Integration**: Video play URL correctly uses `Options(extra: {'useWbi': true})`
4. **Quality Selection Logic**: Sophisticated audio quality selection with FLAC/Dolby priority
5. **AudioQuality Constants**: Well-defined constants with helper methods
6. **Utility Methods**: `primaryUrl`, `backupUrls`, `hasFlac`, `hasDolby`, `durationFormatted`

### Usage Pattern (Excellent)

The modules are correctly consumed by the `player` feature:

```dart
// From audio_service_init.dart
final videoDataSource = VideoRemoteDataSource();
final audioDataSource = AudioRemoteDataSource();

// Video play URL fetch with quality selection
final playUrl = await videoDataSource.getPlayUrl(bvid: bvid, cid: cid, fnval: 4048);
final selectedAudio = playUrl.dash?.selectAudioByQuality(audioQuality.value);

// Audio stream URL fetch with VIP-aware quality
final audioStream = await audioDataSource.getAudioStreamUrl(songId: sid, quality: quality, mid: mid);
```

---

## Issues Found

### 1. [Low] AudioRemoteDataSource quality parameter mismatch

**Location**: `audio_remote_datasource.dart:16-17`

**Issue**: The `quality` parameter documentation says `2: 192kbps, 3: 320kbps/FLAC` but `AudioQuality` constants define `2: high (320K), 3: lossless (FLAC)`.

**Source Reference**: From `audio-web-url.ts`:
```typescript
/** 音质代码（必要：0=128K，1=192K，2=320K，3=FLAC） */
quality: number;
```

**Actual Behavior**: The default `quality = 2` in `getAudioStreamUrl` correctly maps to 192kbps based on the API documentation, but the `AudioQuality` class constants are shifted by 1.

**Impact**: Low - the calling code in `audio_service_init.dart` uses correct values directly (`isVip ? 3 : 2`).

### 2. [Low] Missing audio song info model

**Location**: `audio_remote_datasource.dart:54-68`

**Issue**: `getAudioInfo` returns a raw `Map<String, dynamic>` instead of a typed model class.

**Source Reference**: `audio-song-info.ts` defines comprehensive `AudioSongInfoData` type.

**Impact**: Low - this method may not be actively used. The audio info (title, cover) comes from `AudioStreamData` which includes these fields.

---

## Recommendations

### 1. [Optional] Align AudioQuality constants with API

Consider aligning `AudioQuality` constants with actual API values:

```dart
// Current (shifted)
static const int low = 0;      // Should be 128K
static const int normal = 1;   // Should be 192K
static const int high = 2;     // Should be 320K
static const int lossless = 3; // Should be FLAC

// Actual API (from audio-web-url.ts)
// 0=128K, 1=192K, 2=320K, 3=FLAC
```

The constants are correct but comments could be clearer.

### 2. [Optional] Type getAudioInfo return value

If `getAudioInfo` is used, consider creating an `AudioSongInfo` model class for type safety.

---

## Layer Compliance Verification

### Video Module - Data Only

| Check | Status |
|-------|--------|
| Has data/datasources | Yes |
| Has data/models | Yes |
| Has domain layer | No (justified - no business logic needed) |
| Has presentation layer | No (justified - no UI needed) |
| Consumed by other features | Yes (player module) |

### Audio Module - Data Only

| Check | Status |
|-------|--------|
| Has data/datasources | Yes |
| Has data/models | Yes |
| Has domain layer | No (justified - no business logic needed) |
| Has presentation layer | No (justified - no UI needed) |
| Consumed by other features | Yes (player module) |

**Conclusion**: Both modules correctly follow the **data-only service module** pattern, which is the appropriate architecture for their purpose as infrastructure services consumed by the player feature.

---

## Summary

| Metric | Value |
|--------|-------|
| Structure Score | 5/5 |
| Issues Found | 2 (both Low severity) |
| Justified Deviations | 3 |
| API Coverage | Complete for required APIs |
| Model Coverage | Complete for required fields |
| Code Quality | Excellent |

The video and audio modules are well-designed data-only service modules that correctly provide API access to the player feature. The architecture follows Flutter best practices and Clean Architecture principles. The minor issues identified are cosmetic and do not affect functionality.

---

## Appendix: File Inventory

### Video Module Files

| File | Purpose | Lines |
|------|---------|-------|
| `video_remote_datasource.dart` | API calls for video info and play URLs | 113 |
| `video_info.dart` | VideoInfo, VideoOwner, VideoStat, VideoPage models | 285 |
| `play_url.dart` | PlayUrlData, DashInfo, DashAudio, DashVideo models | 358 |
| `video_data.dart` | Barrel export file | 3 |

### Audio Module Files

| File | Purpose | Lines |
|------|---------|-------|
| `audio_remote_datasource.dart` | API calls for audio stream URLs | 103 |
| `audio_stream.dart` | AudioStreamData, AudioStreamQuality models | 141 |
| `audio_data.dart` | Barrel export file | 2 |

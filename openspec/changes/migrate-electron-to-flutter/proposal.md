# Change: Migrate Biu Music Player from Electron to Flutter

## Why
The existing Biu music player is an Electron-based desktop application. To extend the application to mobile platforms (primarily iOS), we need to migrate to Flutter. Flutter provides:
- True cross-platform support (iOS, Android, Windows, macOS)
- Native performance without JavaScript bridge overhead
- Single codebase for all platforms
- Rich ecosystem for audio playback and UI

## What Changes
This is a **greenfield migration** - building the Flutter application from scratch while using the Electron codebase as the reference implementation.

### Core Capabilities to Implement
1. **Core Infrastructure** - Project structure, dependency injection, routing, local storage
2. **Bilibili API Client** - HTTP client, WBI signature, BUVID/Ticket, response handling
3. **Authentication System** - QR code login, password login, SMS login, session management
4. **Audio Player** - Playback engine, playlist management, play modes, media session
5. **User Interface** - Main layout, navigation, playbar, mini player
6. **Favorites Management** - Folder CRUD, resource management, batch operations
7. **Settings System** - App preferences, theme customization, audio quality selection

### Platform-Specific Notes
- **iOS (Primary Target)**
  - Background audio playback with control center integration
  - No FFmpeg (use native audio decoders)
  - Limited download functionality due to sandbox

- **Windows (Development Platform)**
  - Full feature parity for testing
  - System tray support optional

### Out of Scope (Phase 1)
- Video playback (focus on audio only initially)
- Download manager with FFmpeg processing
- Mini player mode (desktop-specific)
- System tray integration

## Impact
- **New specs**: All capabilities are new additions
- **Affected code**: Entire `biu_flutter/` directory
- **Breaking changes**: N/A (new project)

## Source Reference
All implementations should reference the corresponding source code in `./biu/`:

| Capability | Source Location |
|------------|-----------------|
| State Management | `biu/src/store/` |
| API Services | `biu/src/service/` |
| UI Components | `biu/src/components/`, `biu/src/layout/` |
| Pages | `biu/src/pages/` |
| Electron IPC | `biu/electron/ipc/` |
| Shared Types | `biu/shared/` |

## Success Criteria
1. User can log in via QR code
2. User can browse and search content
3. User can play audio with full playback controls
4. User can manage favorites
5. App works on Windows (dev) and iOS (production)
6. Background audio playback works on iOS

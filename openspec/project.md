# Project Context

## Purpose
Biu-Flutter is a cross-platform music player application based on Bilibili's public APIs. This project aims to migrate the existing Electron-based desktop application (biu) to Flutter framework, targeting iOS as the primary platform while using Windows for development and testing.

## Source Project Overview
The original project (./biu) is an Electron + React + TypeScript application with these key features:
- Bilibili account login (QR code, password, SMS verification)
- High-quality audio playback (Flac, Hi-Res, 192K)
- Video/audio download with FFmpeg processing
- Favorites, watch later, history management
- Mini player mode
- System tray integration
- Theme customization

## Tech Stack

### Target Platform
- **Framework**: Flutter (Dart)
- **Primary Target**: iOS
- **Development Platform**: Windows
- **Final Build Platform**: macOS (for iOS packaging)

### Key Dependencies (Planned)
- State Management: Riverpod or flutter_bloc
- HTTP Client: dio
- Audio Playback: just_audio or audioplayers
- Local Storage: shared_preferences, sqflite
- UI Components: Material 3 / Custom widgets

### Source Project Stack (Reference)
- Electron 38.x
- React 19.x
- TypeScript 5.x
- Zustand (state management)
- Axios (HTTP)
- TailwindCSS (styling)

## Project Conventions

### Code Style
- Dart follows official Effective Dart guidelines
- Use `analysis_options.yaml` with flutter_lints
- File naming: snake_case for files, PascalCase for classes
- Feature-first directory structure

### Architecture Patterns
- Clean Architecture with three layers:
  - Presentation (UI, widgets, controllers)
  - Domain (entities, use cases, repository interfaces)
  - Data (API services, local data sources, repository implementations)
- Repository pattern for data access abstraction
- Provider/Riverpod for dependency injection and state management

### Testing Strategy
- Unit tests for business logic and utilities
- Widget tests for UI components
- Integration tests for critical user flows
- Mock API responses for testing

### Git Workflow
- Feature branches from `main`
- Conventional commits (feat:, fix:, refactor:, docs:, test:)
- **IMPORTANT**: Agents MUST commit and push after completing implementation tasks
- Commit message format: `type(scope): description`

## Domain Context

### Bilibili API Integration
- Authentication requires WBI signature for most API calls
- BUVID and bili_ticket are required for certain requests
- Cookie-based session management
- DASH streaming for video/audio content
- Audio quality levels: 64K, 132K, 192K, Dolby, Hi-Res, Flac

### Key Entities
- **User**: Bilibili account with VIP status, favorites, history
- **Video (MV)**: Bilibili video with multiple parts (pages/cid)
- **Audio**: Bilibili music track
- **Playlist**: Local play queue with shuffle/loop modes
- **Favorites Folder**: User's collection of videos

### Platform Considerations
- iOS: Background audio playback, control center integration
- Windows: System tray (development only)
- Network: Handle CORS issues (not applicable in native apps)

## Important Constraints

### Legal & Compliance
- PolyForm Noncommercial License - no commercial use
- Must comply with Bilibili's Terms of Service
- No circumventing login/VIP restrictions
- No bulk scraping or malicious access

### Technical Constraints
- No FFmpeg on iOS (use platform-native audio decoding)
- Audio download limited by iOS sandbox
- Background playback requires proper configuration
- Network requests must handle Bilibili's anti-scraping measures

### Migration Priorities
1. Core playback functionality
2. Authentication system
3. Search and browse
4. Favorites management
5. Settings and preferences
6. Download functionality (if feasible on iOS)

## External Dependencies

### Bilibili APIs (via bilibili-API-collect)
- passport.bilibili.com - Authentication
- api.bilibili.com - User data, video info
- api.live.bilibili.com - Audio streaming
- app.bilibili.com - Mobile-optimized endpoints

### Third-party Services
- None (all data from Bilibili APIs)

## Agent Instructions

### Implementation Requirements
After completing any implementation task:
1. Ensure all code compiles without errors
2. Run `flutter analyze` to check for issues
3. Create a git commit with conventional commit message
4. Push to remote repository

### Commit Format
```
git commit -m "type(scope): brief description"
git push
```

### Common Scopes
- core, auth, player, api, ui, settings, favorites, download

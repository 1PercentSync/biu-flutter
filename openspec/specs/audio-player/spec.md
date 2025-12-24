# audio-player Specification

## Purpose
TBD - created by archiving change migrate-electron-to-flutter. Update Purpose after archive.
## Requirements
### Requirement: Audio Playback Engine
The application SHALL provide robust audio playback using just_audio package.

#### Scenario: Initialize player
- **GIVEN** app starts
- **WHEN** audio player is initialized
- **THEN** player SHALL be ready to receive audio sources

#### Scenario: Play audio from URL
- **GIVEN** a valid audio stream URL
- **WHEN** play is requested
- **THEN** audio SHALL start playing with buffering indicator

#### Scenario: Background playback (iOS)
- **GIVEN** app is on iOS
- **WHEN** user switches to another app or locks screen
- **THEN** audio playback SHALL continue in background

### Requirement: Playback Controls
The application SHALL provide standard playback controls.

#### Scenario: Play/Pause
- **GIVEN** audio is loaded
- **WHEN** play/pause button is pressed
- **THEN** playback state SHALL toggle accordingly

#### Scenario: Seek
- **GIVEN** audio is playing or paused
- **WHEN** user drags progress slider
- **THEN** playback position SHALL update to selected time

#### Scenario: Volume control
- **GIVEN** audio is playing
- **WHEN** volume slider is adjusted
- **THEN** audio volume SHALL change (0-100%)

#### Scenario: Playback speed
- **GIVEN** audio is playing
- **WHEN** speed is changed (0.5x, 0.75x, 1x, 1.25x, 1.5x, 2x)
- **THEN** playback rate SHALL adjust accordingly

### Requirement: Playlist Management
The application SHALL manage a play queue with multiple tracks.

#### Scenario: Add to playlist
- **GIVEN** user selects a track
- **WHEN** play button is pressed
- **THEN** track SHALL be added to playlist and start playing

#### Scenario: Add to next
- **GIVEN** current track is playing
- **WHEN** user selects "play next" on another track
- **THEN** track SHALL be inserted after current track in queue

#### Scenario: Remove from playlist
- **GIVEN** playlist has multiple tracks
- **WHEN** user removes a track
- **THEN** track SHALL be removed and playback continues

#### Scenario: Clear playlist
- **GIVEN** playlist has tracks
- **WHEN** user clears playlist
- **THEN** all tracks SHALL be removed and playback stops

### Requirement: Play Modes
The application SHALL support multiple play modes.

#### Scenario: Sequential mode
- **GIVEN** play mode is Sequential
- **WHEN** track ends
- **THEN** next track in order SHALL play; stops at end of list

#### Scenario: Loop mode
- **GIVEN** play mode is Loop
- **WHEN** last track ends
- **THEN** playlist SHALL restart from first track

#### Scenario: Single repeat mode
- **GIVEN** play mode is Single
- **WHEN** track ends
- **THEN** same track SHALL repeat

#### Scenario: Shuffle mode
- **GIVEN** play mode is Shuffle
- **WHEN** track ends
- **THEN** a random track (not current) SHALL play

#### Scenario: Shuffle with page order
- **GIVEN** shuffle mode is enabled AND track has multiple pages (video parts)
- **WHEN** current page ends
- **THEN** next page SHALL play in order before shuffling to another video

### Requirement: Track Information
The application SHALL display current track information.

#### Scenario: Display metadata
- **GIVEN** track is playing
- **WHEN** playbar is visible
- **THEN** title, artist, cover image SHALL be displayed

#### Scenario: Audio quality indicator
- **GIVEN** track is playing
- **WHEN** audio source is high quality (Flac, Hi-Res, Dolby)
- **THEN** quality badge SHALL be shown

#### Scenario: Progress display
- **GIVEN** track is playing
- **WHEN** playbar is visible
- **THEN** current time, total duration, and progress bar SHALL update

### Requirement: Media Session Integration
The application SHALL integrate with system media controls.

#### Scenario: Lock screen controls (iOS)
- **GIVEN** audio is playing on iOS
- **WHEN** device is locked
- **THEN** lock screen SHALL show track info and controls

#### Scenario: Control Center (iOS)
- **GIVEN** audio is playing on iOS
- **WHEN** Control Center is opened
- **THEN** now playing widget SHALL show with play/pause/skip controls

#### Scenario: Media notification (Windows)
- **GIVEN** audio is playing on Windows
- **WHEN** system media controls are accessed
- **THEN** track info and controls SHALL be available

### Requirement: Playlist Persistence
The application SHALL persist playlist state across app restarts.

#### Scenario: Save playlist
- **GIVEN** playlist has tracks
- **WHEN** app is closed
- **THEN** playlist state (tracks, current index, position) SHALL be saved

#### Scenario: Restore playlist
- **GIVEN** app restarts with saved playlist
- **WHEN** player initializes
- **THEN** playlist SHALL be restored with previous state
- **AND** playback SHALL remain paused until user initiates


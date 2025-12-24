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

### Requirement: URL Validity Pre-Check

The audio player SHALL validate audio stream URLs before attempting playback by checking the deadline parameter embedded in the URL.

#### Scenario: Valid URL proceeds to playback
- **WHEN** audio URL deadline is in the future
- **THEN** playback proceeds normally
- **AND** no URL refresh is triggered

#### Scenario: Expired URL triggers refresh
- **WHEN** audio URL deadline has passed
- **THEN** a fresh URL is fetched before playback
- **AND** the playlist item is updated with new URL
- **AND** playback proceeds with refreshed URL

#### Scenario: URL without deadline treated as valid
- **WHEN** audio URL does not contain deadline parameter
- **THEN** URL is treated as valid
- **AND** playback proceeds normally

#### Scenario: URL check on app resume
- **WHEN** app returns to foreground during playback
- **THEN** current URL validity is checked
- **AND** URL is refreshed if expired

---

### Requirement: User Audio Quality Selection

The audio player SHALL allow users to select their preferred audio quality level, which is applied when fetching audio streams.

#### Scenario: Quality preference stored in settings
- **WHEN** user selects audio quality in settings
- **THEN** preference is persisted
- **AND** preference is applied to subsequent audio fetches

#### Scenario: Auto quality selects best available
- **WHEN** quality preference is "Auto"
- **THEN** audio selection prioritizes: FLAC > Dolby > highest bitrate
- **AND** the best available quality for user's VIP status is selected

#### Scenario: Lossless quality selection
- **WHEN** quality preference is "Lossless"
- **THEN** FLAC audio is selected if available
- **AND** falls back to Dolby if FLAC unavailable
- **AND** falls back to highest bitrate if neither available

#### Scenario: High quality selection
- **WHEN** quality preference is "High"
- **THEN** highest bitrate standard audio is selected
- **AND** FLAC/Dolby are not prioritized

#### Scenario: Medium quality selection
- **WHEN** quality preference is "Medium"
- **THEN** middle-tier bitrate audio is selected from available options

#### Scenario: Low quality selection
- **WHEN** quality preference is "Low"
- **THEN** lowest bitrate audio is selected
- **AND** saves bandwidth for users on limited data

---

### Requirement: Playback Rate Adjustment UI

The audio player SHALL provide a user interface for adjusting playback speed.

#### Scenario: Rate selector in full player
- **WHEN** user opens full player screen
- **THEN** playback rate control is visible
- **AND** current rate is displayed

#### Scenario: Select playback rate
- **WHEN** user taps rate selector
- **THEN** rate options are displayed: 0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 2.0x
- **AND** current rate is highlighted

#### Scenario: Apply rate change
- **WHEN** user selects a rate option
- **THEN** playback speed changes immediately
- **AND** rate preference is persisted

---

### Requirement: Add To Next Queue Behavior

The playlist management SHALL correctly handle "Add to Next" for multi-part videos by inserting after all parts of the currently playing video.

#### Scenario: Add to next during single video playback
- **WHEN** user adds item to next while playing a single-part video
- **THEN** new item is inserted immediately after current item

#### Scenario: Add to next during multi-part video playback
- **WHEN** user adds item to next while playing part N of a multi-part video
- **THEN** new item is inserted after the last part of current video
- **AND** remaining parts of current video play in sequence first

#### Scenario: Add to next for audio type
- **WHEN** user adds item to next while playing audio (non-video)
- **THEN** new item is inserted immediately after current audio item


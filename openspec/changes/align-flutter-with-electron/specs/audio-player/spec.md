# Audio Player Capability - Delta Specification

## ADDED Requirements

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

## MODIFIED Requirements

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

# settings Specification

## Purpose
TBD - created by archiving change migrate-electron-to-flutter. Update Purpose after archive.
## Requirements
### Requirement: Settings Screen
The application SHALL provide a settings screen for user preferences.

#### Scenario: Access settings
- **GIVEN** user is logged in
- **WHEN** settings is accessed from profile or menu
- **THEN** settings screen SHALL display all configurable options

### Requirement: Audio Quality Selection

The settings system SHALL provide comprehensive audio quality selection options matching the source application.

#### Scenario: Audio quality options
- **WHEN** user opens audio quality settings
- **THEN** options are displayed: Auto, Low (64K), Standard (128K), High (192K), Hi-Res (Lossless)

#### Scenario: VIP-only quality indication
- **WHEN** user is not VIP and views Hi-Res option
- **THEN** option indicates VIP requirement
- **AND** selection is still allowed (API will fallback)

#### Scenario: Quality preference persistence
- **WHEN** user selects audio quality
- **THEN** preference is persisted
- **AND** subsequent audio fetches use this preference

#### Scenario: Quality applied to playback
- **WHEN** audio is fetched for playback
- **THEN** quality selection logic uses user preference
- **AND** best available quality within preference is selected

### Requirement: Theme Customization
The application SHALL allow basic theme customization.

#### Scenario: Primary color
- **GIVEN** settings screen
- **WHEN** primary color picker is used
- **THEN** accent color throughout app SHALL update

#### Scenario: Background colors
- **GIVEN** settings screen
- **WHEN** background colors are customized
- **THEN** main and content backgrounds SHALL update

### Requirement: Playback Settings
The application SHALL allow playback preference configuration.

#### Scenario: Default play mode
- **GIVEN** settings screen
- **WHEN** default play mode is set
- **THEN** new playlists SHALL start with that mode

#### Scenario: Keep page order in shuffle
- **GIVEN** shuffle mode is active
- **WHEN** this option is enabled
- **THEN** multi-part videos SHALL play pages in order before shuffling

### Requirement: Account Settings
The application SHALL display account-related settings.

#### Scenario: Account info
- **GIVEN** user is logged in
- **WHEN** account section is shown
- **THEN** username, VIP status, and avatar SHALL be displayed

#### Scenario: Logout
- **GIVEN** account section
- **WHEN** logout is selected
- **THEN** confirmation dialog SHALL appear before logging out

### Requirement: About Section
The application SHALL display app information.

#### Scenario: Version info
- **GIVEN** about section
- **WHEN** displayed
- **THEN** app version, build number SHALL be shown

#### Scenario: Open source licenses
- **GIVEN** about section
- **WHEN** licenses link is tapped
- **THEN** third-party license information SHALL be displayed

### Requirement: Settings Persistence
The application SHALL persist all settings.

#### Scenario: Save settings
- **GIVEN** any setting is changed
- **WHEN** change is made
- **THEN** it SHALL be immediately persisted to local storage

#### Scenario: Restore settings
- **GIVEN** app restarts
- **WHEN** settings are loaded
- **THEN** previous values SHALL be restored

### Requirement: Cache Management
The application SHALL allow users to manage cached data.

#### Scenario: Clear image cache
- **GIVEN** settings screen
- **WHEN** clear cache is selected
- **THEN** cached images SHALL be deleted

#### Scenario: Cache size display
- **GIVEN** cache management section
- **WHEN** displayed
- **THEN** current cache size SHALL be shown

### Requirement: Display Mode Setting

The settings system SHALL provide an option to switch between card and list display modes for content listings.

#### Scenario: Display mode options
- **WHEN** user opens display settings
- **THEN** options for "Card" and "List" mode are available

#### Scenario: Card mode selected
- **WHEN** user selects card display mode
- **THEN** content listings (search, favorites, etc.) use grid/card layout
- **AND** preference is persisted

#### Scenario: List mode selected
- **WHEN** user selects list display mode
- **THEN** content listings use vertical list layout
- **AND** preference is persisted

#### Scenario: Display mode applied globally
- **WHEN** display mode is changed
- **THEN** all applicable screens reflect the new mode
- **AND** no app restart is required

---

### Requirement: Menu Customization

The settings system SHALL allow users to hide specific favorites folders from navigation menu.

#### Scenario: View hidden folders settings
- **WHEN** user opens menu customization settings
- **THEN** list of favorites folders is displayed
- **AND** each folder has visibility toggle

#### Scenario: Hide folder
- **WHEN** user toggles folder visibility off
- **THEN** folder is hidden from navigation menu
- **AND** folder remains accessible via favorites screen
- **AND** hidden folder IDs are persisted

#### Scenario: Show hidden folder
- **WHEN** user toggles previously hidden folder visibility on
- **THEN** folder reappears in navigation menu

#### Scenario: Hidden folders persist across sessions
- **WHEN** app is restarted
- **THEN** hidden folder preferences are restored
- **AND** menu reflects saved visibility state


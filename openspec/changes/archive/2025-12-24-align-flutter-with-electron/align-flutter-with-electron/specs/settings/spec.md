# Settings Capability - Delta Specification

## ADDED Requirements

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

## MODIFIED Requirements

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

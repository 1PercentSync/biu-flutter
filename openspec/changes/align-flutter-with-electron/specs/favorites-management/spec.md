# Favorites Management Capability - Delta Specification

## ADDED Requirements

### Requirement: Folder Content Search and Filter

The favorites system SHALL support searching and filtering content within a favorites folder.

#### Scenario: Search within folder
- **WHEN** user enters search keyword in folder detail screen
- **THEN** folder contents are filtered by keyword
- **AND** only matching items are displayed
- **AND** search is performed via API (not client-side)

#### Scenario: Sort folder contents
- **WHEN** user selects sort option
- **THEN** folder contents are sorted accordingly
- **AND** available sort options are: Collection Time, Play Count, Publish Time

#### Scenario: Default sort order
- **WHEN** user opens folder detail without changing sort
- **THEN** contents are sorted by Collection Time (mtime) descending

#### Scenario: Combined search and sort
- **WHEN** user applies both search keyword and sort option
- **THEN** results are filtered by keyword AND sorted by selected option

---

### Requirement: Batch Operations

The favorites system SHALL support batch operations on multiple items within a folder.

#### Scenario: Enter selection mode
- **WHEN** user long-presses an item in folder detail
- **THEN** selection mode is activated
- **AND** item is selected
- **AND** action bar appears at bottom

#### Scenario: Select multiple items
- **WHEN** in selection mode, user taps items
- **THEN** items toggle between selected/unselected
- **AND** selection count is displayed

#### Scenario: Select all items
- **WHEN** user taps "Select All" in selection mode
- **THEN** all visible items are selected

#### Scenario: Batch delete
- **WHEN** user taps "Delete" with items selected
- **THEN** confirmation dialog is shown
- **AND** upon confirmation, selected items are removed from folder
- **AND** API call uses batch-del endpoint

#### Scenario: Batch move
- **WHEN** user taps "Move" with items selected
- **THEN** folder picker is shown
- **AND** upon selection, items are moved to target folder
- **AND** items are removed from source folder

#### Scenario: Batch copy
- **WHEN** user taps "Copy" with items selected
- **THEN** folder picker is shown
- **AND** upon selection, items are copied to target folder
- **AND** items remain in source folder

#### Scenario: Exit selection mode
- **WHEN** user taps "Cancel" or back button in selection mode
- **THEN** selection mode exits
- **AND** all selections are cleared

---

### Requirement: Play All Functionality

The favorites system SHALL support playing all items in a folder with a single action.

#### Scenario: Play all from folder
- **WHEN** user taps "Play All" button in folder header
- **THEN** current playlist is replaced with folder contents
- **AND** playback starts from the first item

#### Scenario: Add all to queue
- **WHEN** user selects "Add to Queue" option
- **THEN** all folder items are appended to current playlist
- **AND** current playback continues

#### Scenario: Play all respects current filter
- **WHEN** user taps "Play All" while search/filter is active
- **THEN** only filtered items are added to playlist

---

### Requirement: Clean Invalid Items

The favorites system SHALL support removing invalid (deleted/unavailable) items from a folder.

#### Scenario: Clean invalid items
- **WHEN** user selects "Clean Invalid" from folder menu
- **THEN** confirmation dialog is shown
- **AND** upon confirmation, API removes all invalid items
- **AND** folder content is refreshed

#### Scenario: Invalid item indication
- **WHEN** folder contains invalid items
- **THEN** invalid items are visually distinguished (dimmed, badge, etc.)
- **AND** user is informed of invalid item presence

---

### Requirement: Video Favorite Status Check

The favorites system SHALL be able to check if a specific video is already favorited.

#### Scenario: Check favorite status
- **WHEN** displaying a video item (in search, history, etc.)
- **THEN** system can query if video is in any favorites folder
- **AND** UI indicates favorited status if applicable

#### Scenario: Favorite status in player
- **WHEN** video is playing
- **THEN** favorite button shows current status
- **AND** tapping toggles favorite state

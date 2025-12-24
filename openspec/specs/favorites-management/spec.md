# favorites-management Specification

## Purpose
TBD - created by archiving change migrate-electron-to-flutter. Update Purpose after archive.
## Requirements
### Requirement: Favorites Folder List
The application SHALL display user's favorites folders.

#### Scenario: Fetch created folders
- **GIVEN** user is logged in
- **WHEN** favorites screen is opened
- **THEN** all user-created folders SHALL be listed with title, count, cover

#### Scenario: Fetch collected folders
- **GIVEN** user is logged in
- **WHEN** collected tab is selected
- **THEN** all subscribed/collected folders from other users SHALL be listed

### Requirement: Folder Content
The application SHALL display contents of a favorites folder.

#### Scenario: List folder items
- **GIVEN** user selects a folder
- **WHEN** folder is opened
- **THEN** all videos in folder SHALL be listed with pagination

#### Scenario: Invalid items
- **GIVEN** folder contains deleted or unavailable videos
- **WHEN** content is displayed
- **THEN** invalid items SHALL be marked or filtered

### Requirement: Create Favorites Folder
The application SHALL allow creating new favorites folders.

#### Scenario: Create folder
- **GIVEN** user is on favorites screen
- **WHEN** create button is pressed and form submitted
- **THEN** new folder SHALL be created with given title and privacy setting

#### Scenario: Privacy options
- **GIVEN** folder creation dialog
- **WHEN** user sets privacy
- **THEN** folder can be public (0) or private (1)

### Requirement: Edit Favorites Folder
The application SHALL allow editing folder properties.

#### Scenario: Rename folder
- **GIVEN** user owns a folder
- **WHEN** edit is selected
- **THEN** folder title and description can be modified

#### Scenario: Change privacy
- **GIVEN** user owns a folder
- **WHEN** privacy toggle is changed
- **THEN** folder visibility SHALL update

### Requirement: Delete Favorites Folder
The application SHALL allow deleting user's own folders.

#### Scenario: Delete folder
- **GIVEN** user owns a folder (not default)
- **WHEN** delete is confirmed
- **THEN** folder and all its references SHALL be removed

#### Scenario: Cannot delete default
- **GIVEN** user's default favorites folder
- **WHEN** delete is attempted
- **THEN** operation SHALL be prevented with message

### Requirement: Add to Favorites
The application SHALL allow adding videos to favorites.

#### Scenario: Quick add to default
- **GIVEN** user is viewing a video
- **WHEN** favorite button is pressed
- **THEN** video SHALL be added to default folder

#### Scenario: Select folders
- **GIVEN** user wants to add to specific folders
- **WHEN** folder selection is opened
- **THEN** user can select multiple folders to add video to

#### Scenario: Already favorited
- **GIVEN** video is already in a folder
- **WHEN** folder list is shown
- **THEN** folders containing this video SHALL be indicated

### Requirement: Remove from Favorites
The application SHALL allow removing videos from favorites.

#### Scenario: Remove single item
- **GIVEN** video is in a folder
- **WHEN** remove is selected
- **THEN** video SHALL be removed from that folder

#### Scenario: Batch remove
- **GIVEN** multiple items selected in folder view
- **WHEN** batch delete is confirmed
- **THEN** all selected items SHALL be removed

### Requirement: Move and Copy
The application SHALL support moving/copying items between folders.

#### Scenario: Move items
- **GIVEN** items selected in source folder
- **WHEN** move is selected and destination chosen
- **THEN** items SHALL be moved (removed from source, added to destination)

#### Scenario: Copy items
- **GIVEN** items selected in source folder
- **WHEN** copy is selected and destination chosen
- **THEN** items SHALL be copied (added to destination, kept in source)

### Requirement: Clean Invalid Items

The application SHALL allow cleaning invalid/deleted items from folders with enhanced UI feedback.

#### Scenario: Clean folder
- **WHEN** user selects "Clean Invalid" from folder menu
- **THEN** confirmation dialog is shown
- **AND** upon confirmation, all invalid items are removed from folder
- **AND** folder content is refreshed

#### Scenario: Invalid item indication
- **WHEN** folder contains invalid items
- **THEN** invalid items are visually distinguished (dimmed, badge, etc.)
- **AND** user is informed of invalid item presence

### Requirement: Subscribe to Folder
The application SHALL allow subscribing to other users' public folders.

#### Scenario: Subscribe
- **GIVEN** viewing another user's public folder
- **WHEN** subscribe button is pressed
- **THEN** folder SHALL appear in user's collected list

#### Scenario: Unsubscribe
- **GIVEN** folder is in collected list
- **WHEN** unsubscribe is selected
- **THEN** folder SHALL be removed from collected list

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


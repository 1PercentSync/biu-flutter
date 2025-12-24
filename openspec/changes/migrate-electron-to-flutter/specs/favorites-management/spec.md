## ADDED Requirements

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
The application SHALL allow cleaning invalid/deleted items from folders.

#### Scenario: Clean folder
- **GIVEN** folder contains invalid items
- **WHEN** clean action is triggered
- **THEN** all invalid items SHALL be removed from folder

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

## Implementation Reference

### Source Files to Reference
- Folder services: `biu/src/service/fav-folder-*.ts`
- Resource services: `biu/src/service/fav-resource*.ts`
- Collection component: `biu/src/layout/side/collection/index.tsx`
- Edit modal: `biu/src/components/favorites-edit-modal/index.tsx`
- Select modal: `biu/src/components/favorites-select-modal/index.tsx`

### API Endpoints
```
# Folders
api.bilibili.com/x/v3/fav/folder/created/list-all
api.bilibili.com/x/v3/fav/folder/created/list
api.bilibili.com/x/v3/fav/folder/collected/list
api.bilibili.com/x/v3/fav/folder/add
api.bilibili.com/x/v3/fav/folder/edit
api.bilibili.com/x/v3/fav/folder/del

# Resources
api.bilibili.com/x/v3/fav/resource/list
api.bilibili.com/x/v3/fav/resource/deal  (add/remove)
api.bilibili.com/x/v3/fav/resource/batch-del
api.bilibili.com/x/v3/fav/resource/move
api.bilibili.com/x/v3/fav/resource/copy
api.bilibili.com/x/v3/fav/resource/clean  (remove invalid)
```

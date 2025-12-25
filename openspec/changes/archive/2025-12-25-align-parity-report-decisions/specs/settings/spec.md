# Settings Capability - Delta Specification

## REMOVED Requirements

### Requirement: Privacy Policy Display

**Reason:** Source project (biu/Electron) does not have an About page with Privacy Policy. This was incorrectly added during Flutter implementation.

**Migration:** Remove Privacy Policy tile from About screen. No user-facing migration needed as this is informational content only.

---

### Requirement: Terms of Service Display

**Reason:** Source project (biu/Electron) does not have an About page with Terms of Service. This was incorrectly added during Flutter implementation.

**Migration:** Remove Terms of Service tile from About screen. No user-facing migration needed as this is informational content only.

---

### Requirement: Downloads Menu Entry

**Reason:** Download system is desktop-only in source project (`biu/electron/ipc/download/*`). Mobile implementation is not planned per decision 3.1.A.

**Migration:** Remove Downloads menu item from Profile screen. Users expecting download functionality should be informed via release notes.

---

## MODIFIED Requirements

### Requirement: About Screen Content

The About screen SHALL display only application information and open source licenses.

#### Scenario: About screen displays minimal content
- **WHEN** user opens About screen from settings
- **THEN** application name and version are displayed
- **AND** Open Source Licenses option is displayed
- **AND** no Privacy Policy option is displayed
- **AND** no Terms of Service option is displayed

#### Scenario: Open source licenses access
- **WHEN** user taps Open Source Licenses
- **THEN** Flutter's standard license page is displayed
- **AND** all dependency licenses are listed

---

### Requirement: Profile Menu Items

The Profile screen menu SHALL not include download-related options.

#### Scenario: Profile menu without downloads
- **WHEN** user views Profile screen
- **THEN** menu shows: Watch Later, Theme, About
- **AND** no Downloads option is displayed

#### Scenario: Watch Later accessible from profile
- **WHEN** user taps Watch Later in profile menu
- **THEN** Watch Later screen is displayed

# Core Infrastructure Capability - Delta Specification

## ADDED Requirements

### Requirement: Module Boundary Enforcement - Core Layer

The core layer (`lib/core/`) SHALL NOT import from the features layer (`lib/features/`).

#### Scenario: Core network imports verification
- **WHEN** code in `lib/core/network/` is analyzed
- **THEN** no import statements reference `lib/features/`
- **AND** cross-layer communication uses abstract interfaces

#### Scenario: Core router imports verification
- **WHEN** code in `lib/core/router/` is analyzed
- **THEN** no import statements reference `lib/features/`
- **AND** route guards use providers, not direct feature imports

#### Scenario: Core utilities imports verification
- **WHEN** code in `lib/core/utils/` is analyzed
- **THEN** no import statements reference `lib/features/`

---

### Requirement: Module Boundary Enforcement - Shared Layer

The shared layer (`lib/shared/`) SHALL NOT import from the features layer (`lib/features/`).

#### Scenario: Shared widgets imports verification
- **WHEN** code in `lib/shared/widgets/` is analyzed
- **THEN** no import statements reference `lib/features/`
- **AND** cross-layer dependencies use providers or callbacks

#### Scenario: Shared theme imports verification
- **WHEN** code in `lib/shared/theme/` is analyzed
- **THEN** no import statements reference `lib/features/`

---

### Requirement: Abstract Handler Pattern for Cross-Layer Communication

Cross-layer communication between core/shared and features SHALL use abstract interfaces with dependency injection.

#### Scenario: Abstract interface definition
- **WHEN** core layer needs feature layer functionality
- **THEN** abstract interface is defined in core
- **AND** implementation is in features
- **AND** registration happens at app initialization

#### Scenario: Provider-based injection
- **WHEN** abstract handler is needed at runtime
- **THEN** handler is retrieved from Riverpod provider
- **AND** null check is performed for safety

---

## REMOVED Requirements

### Requirement: Unused Route Constants

**Reason:** Source project has no `/video/:bvid` or `/audio/:sid` routes. These constants create expectations for non-existent functionality.

**Migration:** Remove from `routes.dart`:
- `videoDetail` constant
- `audioDetail` constant
- `videoDetailPath()` function
- `audioDetailPath()` function

#### Scenario: Route constants alignment (removed behavior)
- **WHEN** routes.dart is reviewed
- ~~**THEN** videoDetail and audioDetail constants exist~~
- **THEN** only routes matching source project are defined

---

## MODIFIED Requirements

### Requirement: Gaia VGate Interceptor Architecture

The Gaia VGate network interceptor SHALL use abstract handler interface instead of direct feature imports.

#### Scenario: Interceptor uses handler interface
- **WHEN** GaiaVgateInterceptor processes response with v_voucher
- **THEN** it calls abstract GaiaVgateHandler methods
- **AND** no imports from `lib/features/auth/` are present

#### Scenario: Handler obtained from provider
- **WHEN** interceptor needs to perform verification
- **THEN** handler is obtained from `gaiaVgateHandlerProvider`
- **AND** null safety is handled gracefully

---

### Requirement: Folder Select Sheet Location

The FolderSelectSheet widget SHALL be located in the shared layer to prevent shared→features dependency.

#### Scenario: Widget in shared layer
- **WHEN** FolderSelectSheet is imported
- **THEN** import path is `lib/shared/widgets/folder_select_sheet.dart`
- **AND** no imports from `lib/features/favorites/presentation/` are required

#### Scenario: Widget used by player
- **WHEN** FullPlayerScreen needs folder selection
- **THEN** FolderSelectSheet is imported from shared
- **AND** folder data is obtained via Riverpod providers

#### Scenario: Widget still functional
- **WHEN** FolderSelectSheet is displayed
- **THEN** user's folders are loaded and displayed
- **AND** folder selection callback works correctly
- **AND** folder creation (if applicable) works correctly

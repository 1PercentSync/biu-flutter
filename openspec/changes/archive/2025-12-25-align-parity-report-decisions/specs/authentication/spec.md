# Authentication Capability - Delta Specification

## MODIFIED Requirements

### Requirement: Password Recovery Flow

The password login screen SHALL open the system browser for password recovery instead of showing an in-app dialog.

#### Scenario: Password recovery via browser
- **WHEN** user taps password recovery button/link during password login
- **THEN** system default browser opens
- **AND** Bilibili password recovery page is loaded
- **AND** URL is `https://passport.bilibili.com/pc/passport/findPassword`

#### Scenario: Password recovery on iOS
- **WHEN** user taps password recovery on iOS device
- **THEN** Safari or default browser opens with recovery URL
- **AND** user can return to app via app switcher

#### Scenario: Password recovery on Android
- **WHEN** user taps password recovery on Android device
- **THEN** default browser opens with recovery URL
- **AND** user can return to app via back navigation

#### Scenario: Browser launch failure
- **WHEN** user taps password recovery
- **AND** browser cannot be launched
- **THEN** error message is displayed to user
- **AND** user can retry or continue with login

---

## ADDED Requirements

### Requirement: Gaia VGate Handler Abstraction

The Gaia VGate verification system SHALL be accessible via an abstract interface in the core layer to prevent module boundary violations.

#### Scenario: Core layer uses abstract handler
- **WHEN** network interceptor detects v_voucher response
- **THEN** abstract GaiaVgateHandler interface is called
- **AND** no direct imports from features/auth are required

#### Scenario: Handler implementation in auth feature
- **WHEN** app initializes
- **THEN** GaiaVgateHandlerImpl is created in auth feature
- **AND** handler is registered with core provider

#### Scenario: Handler performs verification flow
- **WHEN** handler.register() is called with v_voucher
- **THEN** Gaia VGate register API is called
- **AND** Geetest parameters are returned
- **WHEN** handler.showVerification() is called
- **THEN** Geetest dialog is displayed
- **AND** verification result is returned
- **WHEN** handler.validate() is called
- **THEN** Gaia VGate validate API is called
- **AND** grisk_id is returned

#### Scenario: Handler not initialized
- **WHEN** network interceptor detects v_voucher
- **AND** handler is not initialized
- **THEN** verification is skipped
- **AND** original response is passed through

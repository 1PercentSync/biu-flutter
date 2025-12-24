# authentication Specification

## Purpose
TBD - created by archiving change migrate-electron-to-flutter. Update Purpose after archive.
## Requirements
### Requirement: QR Code Login
The application SHALL support login via Bilibili mobile app QR code scanning.

#### Scenario: Generate QR code
- **GIVEN** user opens login screen
- **WHEN** QR code login is selected
- **THEN** a QR code image SHALL be displayed with the login URL

#### Scenario: Poll for scan result
- **GIVEN** QR code is displayed
- **WHEN** polling for login status
- **THEN** status SHALL update showing: waiting, scanned, confirmed, or expired

#### Scenario: Successful login
- **GIVEN** user scans and confirms on mobile app
- **WHEN** poll returns success
- **THEN** session cookies SHALL be stored and user redirected to home

#### Scenario: QR code expiration
- **GIVEN** QR code is displayed for more than 180 seconds
- **WHEN** code expires
- **THEN** user SHALL be prompted to refresh the QR code

### Requirement: Password Login
The application SHALL support login with username/email and password.

#### Scenario: RSA encryption
- **GIVEN** user enters password
- **WHEN** login is submitted
- **THEN** password SHALL be encrypted with RSA public key from server

#### Scenario: Captcha handling
- **GIVEN** login attempt triggers captcha
- **WHEN** captcha is required
- **THEN** Geetest captcha widget SHALL be displayed

#### Scenario: Successful password login
- **GIVEN** correct credentials and captcha (if required)
- **WHEN** login succeeds
- **THEN** session cookies SHALL be stored

### Requirement: SMS Login
The application SHALL support login with phone number and SMS verification code.

#### Scenario: Send SMS code
- **GIVEN** user enters valid phone number with country code
- **WHEN** send code button is pressed
- **THEN** SMS verification code SHALL be sent to the phone

#### Scenario: Verify SMS code
- **GIVEN** user receives SMS code
- **WHEN** code is entered and submitted
- **THEN** login SHALL be completed on valid code

### Requirement: Session Management
The application SHALL manage user session state.

#### Scenario: Session persistence
- **GIVEN** user is logged in
- **WHEN** app restarts
- **THEN** session SHALL be restored from stored cookies

#### Scenario: Session validation
- **GIVEN** app starts with stored session
- **WHEN** session is checked
- **THEN** user info API SHALL be called to verify session validity

#### Scenario: Session refresh
- **GIVEN** session cookies are approaching expiration
- **WHEN** cookie_info indicates refresh needed
- **THEN** refresh token flow SHALL be initiated

#### Scenario: Logout
- **GIVEN** user requests logout
- **WHEN** logout is confirmed
- **THEN** all session data (cookies, tokens, cached user info) SHALL be cleared

### Requirement: User State
The application SHALL maintain current user state.

#### Scenario: Fetch user info
- **GIVEN** user is authenticated
- **WHEN** user info is needed
- **THEN** user profile (nickname, avatar, VIP status, mid) SHALL be available

#### Scenario: Guest mode
- **GIVEN** user is not logged in
- **WHEN** accessing the app
- **THEN** limited functionality (search, play public content) SHALL be available

### Requirement: Geetest Captcha
The application SHALL integrate Geetest captcha for verification challenges.

#### Scenario: Display captcha
- **GIVEN** API returns captcha requirement
- **WHEN** geetest parameters are received
- **THEN** Geetest widget SHALL be shown in WebView

#### Scenario: Captcha validation
- **GIVEN** user completes captcha
- **WHEN** geetest returns validate token
- **THEN** token SHALL be included in subsequent API request

### Requirement: Geetest Captcha Integration

The authentication system SHALL integrate Geetest captcha verification for password and SMS login flows when challenged by the Bilibili API.

#### Scenario: Geetest challenge during password login
- **WHEN** password login API returns a Geetest challenge
- **THEN** Geetest captcha dialog is displayed
- **AND** user must complete the captcha to proceed
- **AND** captcha result is included in retry request

#### Scenario: Geetest challenge before SMS send
- **WHEN** SMS send requires Geetest verification
- **THEN** Geetest captcha dialog is displayed
- **AND** captcha must be completed before SMS is sent

#### Scenario: Geetest verification success
- **WHEN** user completes Geetest captcha successfully
- **THEN** captcha validation tokens are obtained
- **AND** login/SMS request is retried with tokens

#### Scenario: Geetest verification failure
- **WHEN** user fails Geetest captcha
- **THEN** user can retry the captcha
- **OR** user can cancel and return to login form

#### Scenario: Geetest WebView implementation
- **WHEN** Geetest challenge is triggered
- **THEN** challenge is loaded in embedded WebView
- **AND** JavaScript callback captures verification result

---

### Requirement: Complete Cookie Refresh Mechanism

The authentication system SHALL implement the complete cookie refresh flow including CorrespondPath fetch for refresh_csrf token.

#### Scenario: Cookie refresh check on app launch
- **WHEN** app launches with existing session
- **THEN** cookie refresh eligibility is checked
- **AND** refresh is triggered if timestamp exceeded

#### Scenario: Fetch refresh_csrf via CorrespondPath
- **WHEN** cookie refresh is needed
- **THEN** CorrespondPath request is made
- **AND** refresh_csrf is extracted from response

#### Scenario: Execute cookie refresh
- **WHEN** refresh_csrf is obtained
- **THEN** cookie refresh API is called
- **AND** new cookies are stored
- **AND** refresh confirmation is sent

#### Scenario: Cookie refresh failure recovery
- **WHEN** cookie refresh fails
- **THEN** user is prompted to re-login
- **AND** existing session is preserved until explicit logout

---

### Requirement: Bili Ticket Auto-Injection

The authentication system SHALL automatically fetch and inject bili_ticket cookie for API requests that require it.

#### Scenario: Initial bili_ticket fetch
- **WHEN** user logs in successfully
- **THEN** bili_ticket is fetched from Bilibili API
- **AND** ticket is stored with expiry time

#### Scenario: Bili_ticket auto-refresh
- **WHEN** bili_ticket approaches expiry (within 1 day of 3-day validity)
- **THEN** new bili_ticket is fetched automatically
- **AND** cookie jar is updated

#### Scenario: Bili_ticket injection in requests
- **WHEN** API request is made
- **THEN** valid bili_ticket is included in request cookies

---

### Requirement: SMS Login Country Support

The SMS login flow SHALL support international phone numbers with country code selection.

#### Scenario: Default country code
- **WHEN** user opens SMS login
- **THEN** default country code is China (+86)
- **AND** country selector is available

#### Scenario: Country code selection
- **WHEN** user taps country selector
- **THEN** list of supported countries is displayed
- **AND** each shows country name and dial code

#### Scenario: International number validation
- **WHEN** user enters phone number with selected country
- **THEN** validation uses country-appropriate rules
- **AND** full international number is sent to API


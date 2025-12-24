# Authentication Capability - Delta Specification

## ADDED Requirements

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

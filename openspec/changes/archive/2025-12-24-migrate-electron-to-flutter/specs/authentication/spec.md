## ADDED Requirements

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

## Implementation Reference

### Source Files to Reference
- QR login: `biu/src/layout/navbar/login/qrcode-login.tsx`
- Password login: `biu/src/layout/navbar/login/password-login.tsx`
- SMS login: `biu/src/layout/navbar/login/code-login.tsx`
- User store: `biu/src/store/user.ts`
- Token store: `biu/src/store/token.ts`
- Geetest: `biu/src/common/hooks/use-geetest.ts`, `biu/src/common/utils/geetest.ts`

### API Endpoints
```
# QR Code Login
passport.bilibili.com/x/passport-login/web/qrcode/generate
passport.bilibili.com/x/passport-login/web/qrcode/poll

# Password Login
passport.bilibili.com/x/passport-login/web/key  (RSA public key)
passport.bilibili.com/x/passport-login/web/login  (with encrypted password)

# SMS Login
passport.bilibili.com/x/passport-login/web/sms/send
passport.bilibili.com/x/passport-login/web/login/sms

# Session
passport.bilibili.com/x/passport-login/web/cookie/info
passport.bilibili.com/x/passport-login/web/cookie/refresh
passport.bilibili.com/login/exit/v2
```

### Key Dependencies
```yaml
dependencies:
  qr_flutter: ^4.x        # QR code display
  webview_flutter: ^4.x   # Geetest captcha
  encrypt: ^5.x           # RSA encryption
```

## ADDED Requirements

### Requirement: HTTP Client Configuration
The application SHALL configure Dio HTTP client with Bilibili-specific requirements.

#### Scenario: Base configuration
- **GIVEN** the HTTP client is initialized
- **WHEN** making requests to Bilibili API
- **THEN** the following headers SHALL be set:
  - User-Agent: Bilibili mobile app user agent
  - Referer: https://www.bilibili.com
  - Origin: https://www.bilibili.com

#### Scenario: Cookie management
- **GIVEN** user is authenticated
- **WHEN** making API requests
- **THEN** session cookies (SESSDATA, bili_jct, DedeUserID) SHALL be included

### Requirement: WBI Signature
The application SHALL implement WBI (Web Bilibili Interface) signature for authenticated API calls.

#### Scenario: Generate WBI sign
- **GIVEN** an API request requires WBI signature
- **WHEN** the request is prepared
- **THEN** wts (timestamp) and w_rid (signature) parameters SHALL be calculated and appended

#### Scenario: Fetch WBI keys
- **GIVEN** WBI keys are not cached or expired
- **WHEN** a signed request is needed
- **THEN** fresh keys SHALL be fetched from nav API and cached

### Requirement: BUVID Generation
The application SHALL generate and maintain BUVID identifiers.

#### Scenario: Generate BUVID3
- **GIVEN** app launches without stored BUVID
- **WHEN** BUVID is needed for API calls
- **THEN** a new BUVID3 SHALL be generated using the standard algorithm

#### Scenario: Persist BUVID
- **GIVEN** BUVID3 is generated
- **WHEN** app restarts
- **THEN** the same BUVID3 SHALL be used

### Requirement: Bili Ticket
The application SHALL obtain and refresh bili_ticket for certain API calls.

#### Scenario: Fetch bili_ticket
- **GIVEN** bili_ticket is required
- **WHEN** ticket is missing or expired
- **THEN** a new ticket SHALL be fetched from the ticket API

#### Scenario: Auto-refresh
- **GIVEN** bili_ticket exists
- **WHEN** it expires (typically 12 hours)
- **THEN** it SHALL be automatically refreshed

### Requirement: Response Handling
The application SHALL properly parse and handle Bilibili API responses.

#### Scenario: Success response
- **GIVEN** API returns code=0
- **WHEN** response is received
- **THEN** data field SHALL be extracted and parsed

#### Scenario: Error response
- **GIVEN** API returns non-zero code
- **WHEN** response is received
- **THEN** appropriate BilibiliApiException SHALL be thrown with code and message

#### Scenario: Rate limiting
- **GIVEN** API returns rate limit error (code=-412)
- **WHEN** error is caught
- **THEN** request SHALL be retried with exponential backoff

### Requirement: Audio Stream URL
The application SHALL fetch audio streaming URLs for video and music content.

#### Scenario: Video audio (DASH)
- **GIVEN** a video BVID and CID
- **WHEN** audio stream is requested
- **THEN** the highest quality available audio URL SHALL be returned
- **AND** audio quality info (Flac, Hi-Res, Dolby, etc.) SHALL be included

#### Scenario: Music audio
- **GIVEN** an audio SID (song ID)
- **WHEN** audio stream is requested
- **THEN** the audio URL with quality info SHALL be returned

### Requirement: Request Interceptors
The application SHALL use interceptors for cross-cutting concerns.

#### Scenario: Logging interceptor
- **GIVEN** any API request
- **WHEN** request is made
- **THEN** request URL, method, and response status SHALL be logged

#### Scenario: Auth interceptor
- **GIVEN** user is logged in
- **WHEN** any request is made
- **THEN** authentication cookies and tokens SHALL be injected

## Implementation Reference

### Source Files to Reference
- WBI signature: `biu/src/service/request/wbi-sign.ts`
- HTTP interceptors: `biu/src/service/request/request-interceptors.ts`
- Response handling: `biu/src/service/request/response-interceptors.ts`
- Audio URL fetch: `biu/electron/ipc/api/audio-stream-url.ts`, `biu/electron/ipc/api/dash-url.ts`
- BUVID: `biu/electron/network/web-buvid.ts`
- Bili ticket: `biu/electron/network/web-bili-ticket.ts`

### API Endpoints
```
# Authentication
passport.bilibili.com/x/passport-login/web/qrcode/generate
passport.bilibili.com/x/passport-login/web/qrcode/poll

# Video/Audio
api.bilibili.com/x/player/wbi/playurl  (DASH streams)
api.bilibili.com/x/web-interface/view  (video info)
www.bilibili.com/audio/music-service-c/url  (audio streams)

# User
api.bilibili.com/x/web-interface/nav  (user info + WBI keys)
api.bilibili.com/x/v3/fav/folder/created/list-all  (favorites)
```

### Key Dependencies
```yaml
dependencies:
  dio: ^5.x
  dio_cookie_manager: ^3.x
  cookie_jar: ^4.x
  crypto: ^3.x  # For WBI signature
```

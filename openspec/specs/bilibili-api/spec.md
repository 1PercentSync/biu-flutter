# bilibili-api Specification

## Purpose
TBD - created by archiving change migrate-electron-to-flutter. Update Purpose after archive.
## Requirements
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

### Requirement: Music Rank APIs

The API layer SHALL implement Bilibili music ranking endpoints.

#### Scenario: Fetch hot music rank
- **WHEN** music rank data is requested
- **THEN** API call to `/x/copyright-music-publicity/toplist/music_rank` is made
- **AND** response contains list of ranked songs with metadata

#### Scenario: Fetch comprehensive music rank
- **WHEN** comprehensive music list is requested
- **THEN** API call to `/x/copyright-music-publicity/toplist/all_list` is made
- **AND** response contains categorized music rankings

---

### Requirement: History APIs

The API layer SHALL implement Bilibili watch history endpoints with cursor-based pagination.

#### Scenario: Fetch watch history
- **WHEN** history list is requested
- **THEN** API call to `/x/web-interface/history/cursor` is made
- **AND** response contains history items and cursor for next page

#### Scenario: History cursor pagination
- **WHEN** next page of history is requested with cursor
- **THEN** API includes cursor parameters (max, view_at, business)
- **AND** response contains next batch of history items

---

### Requirement: Watch Later APIs

The API layer SHALL implement Bilibili watch later (toview) endpoints for CRUD operations.

#### Scenario: Fetch watch later list
- **WHEN** watch later list is requested
- **THEN** API call to `/x/v2/history/toview` is made
- **AND** response contains saved video items

#### Scenario: Add to watch later
- **WHEN** video is added to watch later
- **THEN** POST to `/x/v2/history/toview/add` with aid parameter
- **AND** success response confirms addition

#### Scenario: Remove from watch later
- **WHEN** video is removed from watch later
- **THEN** POST to `/x/v2/history/toview/del` with aid parameter
- **AND** success response confirms removal

#### Scenario: Clear watch later
- **WHEN** all watch later items are cleared
- **THEN** POST to `/x/v2/history/toview/clear`
- **AND** success response confirms clearing

---

### Requirement: Relation APIs

The API layer SHALL implement Bilibili user relation (follow) endpoints.

#### Scenario: Fetch following list
- **WHEN** following list is requested
- **THEN** API call to `/x/relation/followings` is made with pagination
- **AND** response contains followed user information

#### Scenario: Follow user
- **WHEN** user follows another user
- **THEN** POST to `/x/relation/modify` with act=1 (follow)
- **AND** success response confirms follow action

#### Scenario: Unfollow user
- **WHEN** user unfollows another user
- **THEN** POST to `/x/relation/modify` with act=2 (unfollow)
- **AND** success response confirms unfollow action

#### Scenario: Get relation stats
- **WHEN** relation statistics are requested
- **THEN** API call to `/x/relation/stat` is made
- **AND** response contains following/follower counts

---

### Requirement: User Space APIs

The API layer SHALL implement Bilibili user space (profile) endpoints.

#### Scenario: Fetch user info
- **WHEN** user profile is requested
- **THEN** API call to `/x/space/wbi/acc/info` is made with WBI signature
- **AND** response contains user profile information

#### Scenario: Fetch user videos
- **WHEN** user's videos are requested
- **THEN** API call to `/x/space/wbi/arc/search` is made with WBI signature
- **AND** response contains paginated video list

#### Scenario: Fetch user navigation stats
- **WHEN** user statistics are requested
- **THEN** API call to `/x/space/navnum` is made
- **AND** response contains video/audio/article counts

---

### Requirement: Favorites Batch Operation APIs

The API layer SHALL implement Bilibili favorites batch operation endpoints.

#### Scenario: Batch delete resources
- **WHEN** multiple resources are deleted from folder
- **THEN** POST to `/x/v3/fav/resource/batch-del` with resource IDs
- **AND** success response confirms deletion

#### Scenario: Batch move resources
- **WHEN** multiple resources are moved between folders
- **THEN** POST to `/x/v3/fav/resource/move` with source and target folder IDs
- **AND** success response confirms move operation

#### Scenario: Batch copy resources
- **WHEN** multiple resources are copied to another folder
- **THEN** POST to `/x/v3/fav/resource/copy` with target folder ID
- **AND** success response confirms copy operation

#### Scenario: Clean invalid resources
- **WHEN** invalid resources cleanup is requested
- **THEN** POST to `/x/v3/fav/resource/clean` with folder ID
- **AND** success response confirms cleanup with count of removed items

#### Scenario: Check video favorite status
- **WHEN** video favorite status is checked
- **THEN** API call to `/x/v2/fav/video/favoured` with aid parameter
- **AND** response indicates if video is favorited and in which folders

---

### Requirement: Musician/Artist APIs

The API layer SHALL implement Bilibili musician listing endpoints.

#### Scenario: Fetch musician list
- **WHEN** musician ranking is requested
- **THEN** API call to `/x/copyright-music-publicity/index/uploader_list` is made
- **AND** response contains ranked musicians with stats

---

### Requirement: Search API Enhancement

The search API SHALL support additional parameters for filtering and pagination.

#### Scenario: Search with category filter
- **WHEN** search is performed with category filter
- **THEN** API includes `tids` parameter (e.g., tids=3 for music)
- **AND** results are restricted to specified category

#### Scenario: Search with pagination
- **WHEN** paginated search is performed
- **THEN** API includes `page` and `page_size` parameters
- **AND** response includes total count and pagination info

#### Scenario: User search
- **WHEN** user search is performed
- **THEN** API uses `search_type=bili_user`
- **AND** response contains user profile information


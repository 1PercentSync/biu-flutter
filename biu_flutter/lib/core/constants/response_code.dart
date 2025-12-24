/// Bilibili Common Error Codes
/// Source: https://socialsisteryi.github.io/bilibili-API-collect/docs/misc/errcode.html
enum BiliErrorCode {
  /// Application not found or banned
  appNotFoundOrBanned(-1, 'Application not found or banned'),

  /// Access Key error
  accessKeyError(-2, 'Access Key error'),

  /// API validation key error
  apiValidationKeyError(-3, 'API validation key error'),

  /// No permission for method
  noPermissionForMethod(-4, 'No permission for method'),

  /// Not logged in
  notLoggedIn(-101, 'Not logged in'),

  /// Account banned
  accountBanned(-102, 'Account banned'),

  /// Insufficient points
  insufficientPoints(-103, 'Insufficient points'),

  /// Insufficient coins
  insufficientCoins(-104, 'Insufficient coins'),

  /// Captcha error
  captchaError(-105, 'Captcha error'),

  /// Not formal member or in adaptation period
  notFormalMemberOrAdaptationPeriod(-106, 'Not formal member'),

  /// App not exist or banned
  appNotExistOrBanned(-107, 'App not exist or banned'),

  /// Phone not bound
  phoneNotBound(-108, 'Phone not bound'),

  /// Phone not bound (alt)
  phoneNotBoundAlt(-110, 'Phone not bound'),

  /// CSRF validation failed
  csrfValidationFailed(-111, 'CSRF validation failed'),

  /// System upgrading
  systemUpgrading(-112, 'System upgrading'),

  /// Real name verification required
  realNameVerificationRequired(-113, 'Real name verification required'),

  /// Please bind phone
  pleaseBindPhone(-114, 'Please bind phone'),

  /// Please complete real name verification
  pleaseCompleteRealNameVerification(-115, 'Please complete verification'),

  /// Not modified
  notModified(-304, 'Not modified'),

  /// Redirect collision
  redirectCollision(-307, 'Redirect collision'),

  /// Risk control validation failed (UA or WBI params invalid)
  riskControlValidationFailed(-352, 'Risk control validation failed'),

  /// Bad request
  badRequest(-400, 'Bad request'),

  /// Unauthorized or illegal request
  unauthorizedOrIllegalRequest(-401, 'Unauthorized'),

  /// Forbidden
  forbidden(-403, 'Forbidden'),

  /// Not found
  notFound(-404, 'Not found'),

  /// Method not allowed
  methodNotAllowed(-405, 'Method not allowed'),

  /// Conflict
  conflict(-409, 'Conflict'),

  /// Request intercepted by risk control
  requestInterceptedByRiskControl(-412, 'Request intercepted'),

  /// Internal server error
  internalServerError(-500, 'Internal server error'),

  /// Service unavailable due to overload
  serviceUnavailableDueToOverload(-503, 'Service unavailable'),

  /// Service call timeout
  serviceCallTimeout(-504, 'Service timeout'),

  /// Exceeded limit
  exceededLimit(-509, 'Exceeded limit'),

  /// Uploaded file does not exist
  uploadedFileDoesNotExist(-616, 'File does not exist'),

  /// Uploaded file too large
  uploadedFileTooLarge(-617, 'File too large'),

  /// Too many failed login attempts
  tooManyFailedLoginAttempts(-625, 'Too many login attempts'),

  /// User does not exist
  userDoesNotExist(-626, 'User does not exist'),

  /// Password too weak
  passwordTooWeak(-628, 'Password too weak'),

  /// Invalid username or password
  invalidUsernameOrPassword(-629, 'Invalid username or password'),

  /// Operation object quantity limit
  operationObjectQuantityLimit(-632, 'Quantity limit'),

  /// Locked
  locked(-643, 'Locked'),

  /// User level too low
  userLevelTooLow(-650, 'User level too low'),

  /// Duplicate user
  duplicateUser(-652, 'Duplicate user'),

  /// Token expired
  tokenExpired(-658, 'Token expired'),

  /// Password timestamp expired
  passwordTimestampExpired(-662, 'Password timestamp expired'),

  /// Geographic restriction
  geographicRestriction(-688, 'Geographic restriction'),

  /// Copyright restriction
  copyrightRestriction(-689, 'Copyright restriction'),

  /// Deduction of moral points failed
  deductionOfMoralPointsFailed(-701, 'Deduction failed'),

  /// Too many requests
  tooManyRequests(-799, 'Too many requests'),

  /// Server busy
  serverBusy(-8888, 'Server busy');

  const BiliErrorCode(this.code, this.message);

  /// Error code
  final int code;

  /// Error message
  final String message;

  /// Get BiliErrorCode from code
  static BiliErrorCode? fromCode(int code) {
    try {
      return BiliErrorCode.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Check if the code indicates authentication is required
  static bool isAuthRequired(int code) {
    return code == notLoggedIn.code ||
        code == accountBanned.code ||
        code == tokenExpired.code;
  }
}

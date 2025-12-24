/// Utility functions for URL handling
class UrlUtils {
  UrlUtils._();

  /// Check if a Bilibili media URL is still valid based on its deadline parameter.
  ///
  /// Bilibili audio/video URLs contain a `deadline` query parameter that indicates
  /// when the URL expires. This function checks if the URL is still valid.
  ///
  /// Returns `true` if:
  /// - URL is valid and has no deadline (assumed valid)
  /// - URL is valid and deadline has not passed
  ///
  /// Returns `false` if:
  /// - URL is null or empty
  /// - URL is malformed
  /// - Deadline has passed
  ///
  /// Reference: `biu/src/common/utils/audio.ts:isUrlValid`
  static bool isUrlValid(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      final deadline = uri.queryParameters['deadline'];

      // No deadline parameter - assume URL is valid
      if (deadline == null || deadline.isEmpty) return true;

      final deadlineTime = int.tryParse(deadline);
      if (deadlineTime == null) return true;

      // Compare current time with deadline (deadline is in Unix seconds)
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return nowSeconds < deadlineTime;
    } catch (_) {
      // Malformed URL - consider invalid
      return false;
    }
  }

  /// Ensure URL uses HTTPS protocol
  static String formatProtocol(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  /// Add @.webp suffix to Bilibili image URL for WebP format
  static String toWebp(String? url, {int? width, int? height}) {
    if (url == null || url.isEmpty) return '';

    var result = formatProtocol(url);

    // Remove existing format suffix if present
    result = result.replaceAll(RegExp(r'@\d+w_\d+h.*$'), '');

    // Add WebP suffix with optional dimensions
    if (width != null && height != null) {
      return '$result@${width}w_${height}h.webp';
    } else if (width != null) {
      return '$result@${width}w.webp';
    } else if (height != null) {
      return '$result@${height}h.webp';
    }
    return '$result@.webp';
  }

  /// Check if URL is valid and accessible
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  /// Extract BV ID from Bilibili video URL
  static String? extractBvid(String url) {
    // Match patterns like /video/BV1xx411c7mD or BV1xx411c7mD
    final bvidPattern = RegExp('BV[a-zA-Z0-9]+');
    final match = bvidPattern.firstMatch(url);
    return match?.group(0);
  }

  /// Build Bilibili video URL from BV ID
  static String buildVideoUrl(String bvid) {
    return 'https://www.bilibili.com/video/$bvid';
  }

  /// Build Bilibili audio URL from song ID
  static String buildAudioUrl(int sid) {
    return 'https://www.bilibili.com/audio/au$sid';
  }

  /// Build Bilibili user space URL from mid
  static String buildUserUrl(int mid) {
    return 'https://space.bilibili.com/$mid';
  }
}

/// Extension methods for String.
///
/// Provides HTML stripping and URL utilities for Bilibili content.
///
/// Source: biu/src/common/utils/str.ts#stripHtml
/// Source: biu/src/common/utils/url.ts (toHttps logic)
extension StringExtensions on String {
  /// Remove HTML tags from the string
  /// Used for processing search result titles
  String stripHtml() {
    if (isEmpty) return '';

    // Check if there are any HTML tags
    final hasHtmlTags = RegExp('<[^>]+>').hasMatch(this);
    if (!hasHtmlTags) return this;

    // Remove HTML tags
    var sanitized = this;
    String prev;
    do {
      prev = sanitized;
      sanitized = sanitized.replaceAll(RegExp('<[^>]+>'), '');
    } while (sanitized != prev);

    return sanitized;
  }

  /// Ensure URL uses HTTPS protocol
  String toHttps() {
    if (isEmpty) return '';
    if (startsWith('//')) {
      return 'https:$this';
    }
    if (startsWith('http://')) {
      return replaceFirst('http://', 'https://');
    }
    return this;
  }

  /// Truncate string to specified length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Check if string is a valid BV ID
  bool get isBvid {
    return RegExp(r'^BV[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Check if string is a valid AV ID
  bool get isAvid {
    return RegExp(r'^av\d+$', caseSensitive: false).hasMatch(this);
  }

  /// Extract numeric AV ID from string like "av12345"
  int? get avidNumber {
    if (!isAvid) return null;
    return int.tryParse(replaceFirst(RegExp('^av', caseSensitive: false), ''));
  }
}

/// Extension methods for nullable String
extension NullableStringExtensions on String? {
  /// Returns true if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if string is not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns the string or empty string if null
  String get orEmpty => this ?? '';
}

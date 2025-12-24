import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A widget that renders text with highlighted keywords.
///
/// Parses HTML `<em>` tags (used by Bilibili search results) and renders
/// the wrapped text with highlight styling.
///
/// Source: biu/src/components/music-list-item/index.tsx#isTitleIncludeHtmlTag
/// Source: biu/src/components/mv-card/index.tsx#isTitleIncludeHtmlTag
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    required this.text,
    super.key,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  /// The text to display, may contain `<em>` tags for highlighting
  final String text;

  /// Base text style
  final TextStyle? style;

  /// Style for highlighted portions (defaults to primary color)
  final TextStyle? highlightStyle;

  /// Maximum number of lines
  final int? maxLines;

  /// How to handle text overflow
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final spans = _parseHighlightedText(text, context);

    return RichText(
      text: TextSpan(
        style: style ?? Theme.of(context).textTheme.bodyMedium,
        children: spans,
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Parse text containing `<em>` tags into TextSpans.
  ///
  /// Bilibili search results wrap matching keywords in `<em class="keyword">...</em>`.
  /// This method extracts those and creates highlighted TextSpans.
  List<TextSpan> _parseHighlightedText(String text, BuildContext context) {
    final spans = <TextSpan>[];

    // Pattern to match <em> or <em class="..."> tags
    final pattern = RegExp('<em[^>]*>(.*?)</em>', caseSensitive: false);
    var lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      // Add text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      // Add highlighted text
      final highlightedContent = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: highlightedContent,
          style: highlightStyle ??
              const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text after last match
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    // If no matches found, return the original text (stripped of any other HTML)
    if (spans.isEmpty) {
      spans.add(TextSpan(text: _stripOtherHtml(text)));
    }

    return spans;
  }

  /// Strip HTML tags other than <em> (which we've already processed)
  String _stripOtherHtml(String text) {
    return text.replaceAll(RegExp('<[^>]*>'), '');
  }
}

/// Extension to check if a string contains highlight tags
extension HighlightedTextExtension on String {
  /// Returns true if the string contains `<em>` tags (search highlight)
  bool get hasHighlight => contains(RegExp('<em[^>]*>'));
}

import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../data/models/search_suggest.dart';

/// Widget displaying search suggestions as a list.
///
/// Source: biu/src/layout/navbar/search/index.tsx
/// Displays suggestions with keyword highlighting.
class SearchSuggestionsList extends StatelessWidget {
  const SearchSuggestionsList({
    required this.suggestions,
    required this.onSelect,
    super.key,
  });

  final List<SearchSuggestItem> suggestions;
  final void Function(String value) onSelect;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suggestions.map((item) {
        return _SuggestionItem(
          item: item,
          onTap: () => onSelect(item.value),
        );
      }).toList(),
    );
  }
}

/// Individual suggestion item with highlight support.
class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem({
    required this.item,
    required this.onTap,
  });

  final SearchSuggestItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                size: 18,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHighlightedText(context, item.name),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build text with HTML highlight tags converted to styled spans.
  /// Source: The API returns <em class="suggest_high_light"> tags for highlighting.
  Widget _buildHighlightedText(BuildContext context, String htmlText) {
    // Parse the HTML to extract highlighted and normal parts
    final parts = _parseHighlightHtml(htmlText);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
        children: parts.map((part) {
          if (part.isHighlighted) {
            return TextSpan(
              text: part.text,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            );
          } else {
            return TextSpan(text: part.text);
          }
        }).toList(),
      ),
    );
  }

  /// Parse HTML text with <em class="suggest_high_light"> tags.
  List<_TextPart> _parseHighlightHtml(String html) {
    final parts = <_TextPart>[];

    // Pattern to match <em class="suggest_high_light">...</em>
    final regex = RegExp('<em[^>]*>([^<]*)</em>');
    var lastEnd = 0;

    for (final match in regex.allMatches(html)) {
      // Add text before this match (if any)
      if (match.start > lastEnd) {
        final normalText = html.substring(lastEnd, match.start);
        if (normalText.isNotEmpty) {
          parts.add(_TextPart(text: normalText, isHighlighted: false));
        }
      }

      // Add highlighted text
      final highlightedText = match.group(1) ?? '';
      if (highlightedText.isNotEmpty) {
        parts.add(_TextPart(text: highlightedText, isHighlighted: true));
      }

      lastEnd = match.end;
    }

    // Add remaining text after last match
    if (lastEnd < html.length) {
      final remainingText = html.substring(lastEnd);
      if (remainingText.isNotEmpty) {
        parts.add(_TextPart(text: remainingText, isHighlighted: false));
      }
    }

    // If no parts were found, return the entire text as non-highlighted
    if (parts.isEmpty) {
      parts.add(_TextPart(text: html, isHighlighted: false));
    }

    return parts;
  }
}

/// Represents a part of text with highlight info.
class _TextPart {
  const _TextPart({
    required this.text,
    required this.isHighlighted,
  });

  final String text;
  final bool isHighlighted;
}

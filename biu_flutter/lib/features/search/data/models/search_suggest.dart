/// Search suggestion item from Bilibili API.
///
/// Source: biu/src/service/main-suggest.ts#SearchSuggestTag
class SearchSuggestItem {
  const SearchSuggestItem({
    required this.value,
    required this.name,
  });

  factory SearchSuggestItem.fromJson(Map<String, dynamic> json) {
    return SearchSuggestItem(
      value: json['value'] as String? ?? '',
      name: json['name'] as String? ?? json['value'] as String? ?? '',
    );
  }

  /// Plain text value of the suggestion
  final String value;

  /// Display name with HTML highlight tags (<em class="suggest_high_light">)
  final String name;
}

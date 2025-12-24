/// Search history item entity
class SearchHistoryItem {

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      value: json['value'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? json['time'] as int? ?? 0,
    );
  }
  const SearchHistoryItem({
    required this.value,
    required this.timestamp,
  });

  final String value;
  final int timestamp;

  Map<String, dynamic> toJson() => {
        'value': value,
        'timestamp': timestamp,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchHistoryItem && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

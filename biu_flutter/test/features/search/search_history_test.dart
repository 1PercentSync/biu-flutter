import 'package:biu_flutter/features/search/domain/entities/search_history_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchHistoryItem', () {
    test('creates item with correct values', () {
      final item = SearchHistoryItem(
        value: 'test query',
        timestamp: 1703123456000,
      );
      expect(item.value, 'test query');
      expect(item.timestamp, 1703123456000);
    });

    test('fromJson parses correctly', () {
      final json = {
        'value': '周杰伦',
        'timestamp': 1703123456000,
      };
      final item = SearchHistoryItem.fromJson(json);
      expect(item.value, '周杰伦');
      expect(item.timestamp, 1703123456000);
    });

    test('fromJson handles legacy time field', () {
      final json = {
        'value': 'legacy query',
        'time': 1703123400000,
      };
      final item = SearchHistoryItem.fromJson(json);
      expect(item.value, 'legacy query');
      expect(item.timestamp, 1703123400000);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};
      final item = SearchHistoryItem.fromJson(json);
      expect(item.value, '');
      expect(item.timestamp, 0);
    });

    test('toJson serializes correctly', () {
      final item = SearchHistoryItem(
        value: 'test',
        timestamp: 1703123456000,
      );
      final json = item.toJson();
      expect(json['value'], 'test');
      expect(json['timestamp'], 1703123456000);
    });

    test('equality based on value', () {
      final item1 = SearchHistoryItem(
        value: 'same query',
        timestamp: 1000,
      );
      final item2 = SearchHistoryItem(
        value: 'same query',
        timestamp: 2000,
      );
      final item3 = SearchHistoryItem(
        value: 'different query',
        timestamp: 1000,
      );

      expect(item1 == item2, true); // Same value, different timestamp
      expect(item1 == item3, false); // Different value
    });

    test('hashCode based on value', () {
      final item1 = SearchHistoryItem(
        value: 'test',
        timestamp: 1000,
      );
      final item2 = SearchHistoryItem(
        value: 'test',
        timestamp: 2000,
      );

      expect(item1.hashCode, item2.hashCode);
    });
  });
}

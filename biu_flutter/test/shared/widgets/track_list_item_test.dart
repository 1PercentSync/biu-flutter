import 'package:biu_flutter/shared/widgets/track_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper to wrap widget with MaterialApp for testing
  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('TrackListItem', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(title: 'Test Track'),
      ));

      expect(find.text('Test Track'), findsOneWidget);
    });

    testWidgets('displays artist name when provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(
          title: 'Test Track',
          artistName: 'Test Artist',
        ),
      ));

      expect(find.text('Test Track'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(createWidgetUnderTest(
        TrackListItem(
          title: 'Test Track',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(TrackListItem));
      expect(tapped, true);
    });

    testWidgets('shows trailingAction when provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(
          title: 'Test Track',
          trailingAction: Icon(Icons.star, key: Key('trailing_action')),
        ),
      ));

      expect(find.byKey(const Key('trailing_action')), findsOneWidget);
    });

    testWidgets('applies active style when isActive is true', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(
          title: 'Test Track',
          isActive: true,
        ),
      ));

      expect(find.text('Test Track'), findsOneWidget);
    });
  });
}

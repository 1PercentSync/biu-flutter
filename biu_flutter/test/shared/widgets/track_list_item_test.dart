import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biu_flutter/shared/widgets/track_list_item.dart';

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

    testWidgets('displays formatted duration', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(
          title: 'Test Track',
          duration: 185, // 3:05
        ),
      ));

      expect(find.text('03:05'), findsOneWidget);
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

    testWidgets('triggers onDoubleTap callback', (tester) async {
      var doubleTapped = false;

      await tester.pumpWidget(createWidgetUnderTest(
        TrackListItem(
          title: 'Test Track',
          onDoubleTap: () => doubleTapped = true,
        ),
      ));

      await tester.tap(find.byType(TrackListItem));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(TrackListItem));
      await tester.pumpAndSettle(); // Wait for gesture recognizer to settle
      expect(doubleTapped, true);
    });

    testWidgets('shows more button when onMorePressed is provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        TrackListItem(
          title: 'Test Track',
          onMorePressed: () {},
        ),
      ));

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('hides more button when onMorePressed is null', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(title: 'Test Track'),
      ));

      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('triggers onMorePressed callback', (tester) async {
      var morePressed = false;

      await tester.pumpWidget(createWidgetUnderTest(
        TrackListItem(
          title: 'Test Track',
          onMorePressed: () => morePressed = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.more_vert));
      expect(morePressed, true);
    });

    testWidgets('shows playing indicator when isPlaying is true', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(
          title: 'Test Track',
          isPlaying: true,
        ),
      ));

      expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
    });

    testWidgets('shows pause icon when isActive but not playing', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(
          title: 'Test Track',
          isActive: true,
          isPlaying: false,
        ),
      ));

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('formats play count with 万 suffix', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(
          title: 'Test Track',
          playCount: 15000, // 1.5万
        ),
      ));

      expect(find.text('1.5万'), findsOneWidget);
    });

    testWidgets('formats play count with 亿 suffix', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const TrackListItem(
          title: 'Test Track',
          playCount: 150000000, // 1.5亿
        ),
      ));

      expect(find.text('1.5亿'), findsOneWidget);
    });
  });
}

import 'package:biu_flutter/shared/widgets/video_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper to wrap widget with MaterialApp for testing
  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: child,
          ),
        ),
      ),
    );
  }

  group('VideoCard', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(title: 'Test Video'),
      ));

      expect(find.text('Test Video'), findsOneWidget);
    });

    testWidgets('displays owner name when provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(
          title: 'Test Video',
          ownerName: 'Test Owner',
        ),
      ));

      expect(find.text('Test Owner'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(createWidgetUnderTest(
        VideoCard(
          title: 'Test Video',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(VideoCard));
      expect(tapped, true);
    });

    testWidgets('triggers onLongPress callback', (tester) async {
      var longPressed = false;

      await tester.pumpWidget(createWidgetUnderTest(
        VideoCard(
          title: 'Test Video',
          onLongPress: () => longPressed = true,
        ),
      ));

      await tester.longPress(find.byType(VideoCard));
      expect(longPressed, true);
    });

    testWidgets('uses default aspect ratio of 1.0', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(title: 'Test Video'),
      ));

      final aspectRatio = find.byType(AspectRatio);
      expect(aspectRatio, findsOneWidget);

      final widget = tester.widget<AspectRatio>(aspectRatio);
      expect(widget.aspectRatio, 1.0);
    });

    testWidgets('respects custom aspect ratio', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(
          title: 'Test Video',
          aspectRatio: 16 / 9,
        ),
      ));

      final aspectRatio = find.byType(AspectRatio);
      final widget = tester.widget<AspectRatio>(aspectRatio);
      expect(widget.aspectRatio, 16 / 9);
    });

    testWidgets('shows actionWidget when provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(
          title: 'Test Video',
          actionWidget: Icon(Icons.more_vert, key: Key('action_widget')),
        ),
      ));

      expect(find.byKey(const Key('action_widget')), findsOneWidget);
    });
  });
}

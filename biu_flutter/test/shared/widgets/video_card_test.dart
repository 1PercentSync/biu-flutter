import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biu_flutter/shared/widgets/video_card.dart';

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

    testWidgets('displays formatted duration badge', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(
          title: 'Test Video',
          duration: 3665, // 1:01:05
        ),
      ));

      expect(find.text('01:01:05'), findsOneWidget);
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

    testWidgets('displays view count with play icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(
          title: 'Test Video',
          viewCount: 12345,
        ),
      ));

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.text('1.2万'), findsOneWidget);
    });

    testWidgets('displays danmaku count with comment icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(
          title: 'Test Video',
          danmakuCount: 500,
        ),
      ));

      expect(find.byIcon(Icons.comment), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('shows border when isActive is true', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(
          title: 'Test Video',
          isActive: true,
        ),
      ));

      // Find the Container that should have the border
      final container = find.byType(Container).evaluate().firstWhere(
        (element) {
          final widget = element.widget as Container;
          if (widget.decoration is BoxDecoration) {
            final decoration = widget.decoration as BoxDecoration;
            return decoration.border != null;
          }
          return false;
        },
      );

      expect(container, isNotNull);
    });

    testWidgets('formats view count with 亿 suffix for large numbers', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(
          title: 'Test Video',
          viewCount: 150000000, // 1.5亿
        ),
      ));

      expect(find.text('1.5亿'), findsOneWidget);
    });

    testWidgets('maintains 16:9 aspect ratio for cover', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const VideoCard(title: 'Test Video'),
      ));

      final aspectRatio = find.byType(AspectRatio);
      expect(aspectRatio, findsOneWidget);

      final widget = tester.widget<AspectRatio>(aspectRatio);
      expect(widget.aspectRatio, 16 / 9);
    });
  });
}

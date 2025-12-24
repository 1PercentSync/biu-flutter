import 'package:biu_flutter/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper to wrap widget with MaterialApp for testing
  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('EmptyState', () {
    testWidgets('displays default message when no props provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const EmptyState()));

      expect(find.text('No content'), findsOneWidget);
      expect(find.byIcon(Icons.not_interested), findsOneWidget);
    });

    testWidgets('displays custom message', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const EmptyState(message: 'Custom message'),
      ));

      expect(find.text('Custom message'), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const EmptyState(
          title: 'Empty Title',
          message: 'Empty message',
        ),
      ));

      expect(find.text('Empty Title'), findsOneWidget);
      expect(find.text('Empty message'), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const EmptyState(
          icon: Icon(Icons.search_off),
        ),
      ));

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.byIcon(Icons.not_interested), findsNothing);
    });

    testWidgets('displays action widget when provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        EmptyState(
          message: 'No results',
          action: ElevatedButton(
            onPressed: () {},
            child: const Text('Retry'),
          ),
        ),
      ));

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('action button is tappable', (tester) async {
      var tapped = false;

      await tester.pumpWidget(createWidgetUnderTest(
        EmptyState(
          action: ElevatedButton(
            onPressed: () => tapped = true,
            child: const Text('Retry'),
          ),
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, true);
    });

    testWidgets('is centered on screen', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const EmptyState()));

      final center = find.byType(Center);
      expect(center, findsWidgets); // At least one Center widget
    });
  });
}

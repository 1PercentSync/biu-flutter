// Basic Flutter widget test for BiuApp.
//
// This test verifies the basic structure of the application.
// More specific tests will be added as features are implemented.

import 'package:biu_flutter/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BiuApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: BiuApp(),
      ),
    );

    // Verify that the app starts (basic smoke test).
    // The app should show the home screen with navigation.
    await tester.pumpAndSettle();

    // Verify that navigation destinations are visible.
    // Note: NavigationBar may render multiple text widgets for animation,
    // so we use findsWidgets instead of findsOneWidget.
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Favorites'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Ensure these paths match your project structure exactly
import 'package:kindora/screens/news_feed_screen.dart';

void main() {
  group('News Feed Screen Tests', () {

    testWidgets('News Feed renders search bar and initial data', (WidgetTester tester) async {
      // Load the Feed Screen
      await tester.pumpWidget(const MaterialApp(home: FeedScreen()));

      // 1. Verify Search Bar exists
      expect(find.byType(TextField), findsOneWidget);

      // 2. Check for the "Jaffna" news item on initial load
      expect(find.textContaining('Jaffna Water Project'), findsOneWidget);

      // 3. Check for the "URGENT" status tag
      expect(find.text('URGENT'), findsOneWidget);
    });

    testWidgets('Search bar filters the news list correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FeedScreen()));

      // 1. Find the Search Bar and type "Jaffna"
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Jaffna');

      // 2. Re-render the UI after typing
      await tester.pumpAndSettle();

      // 3. Verify Jaffna is still there
      expect(find.textContaining('Jaffna Water Project'), findsOneWidget);

      // 4. Type something that doesn't exist
      await tester.enterText(searchField, 'NonExistentProject');
      await tester.pumpAndSettle();

      // 5. Verify the list is now empty or Jaffna is gone
      expect(find.textContaining('Jaffna Water Project'), findsNothing);
    });
  });
}
// Automated tests for News Feed

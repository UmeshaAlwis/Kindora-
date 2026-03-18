// UI Navigation Test: Verifies flow from Recommendation Card to Donation Selection Screen
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindora/screens/recommendation_screen.dart';

void main() {
  group('Recommendation Flow Tests', () {
    testWidgets('Tapping a recommendation card opens Detail Screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecommendationScreen()));

      // 1. Find and tap the "Clean Water Initiative" card
      final waterCard = find.text('Clean Water Initiative');
      expect(waterCard, findsOneWidget);
      await tester.tap(waterCard);
      await tester.pumpAndSettle(); // Wait for navigation animation

      // 2. Verify we are on the Detail Screen
      expect(find.text('Matches your interest in Sustainability'), findsOneWidget);
      expect(find.text('Donate Now'), findsOneWidget);
    });

    testWidgets('Donate Now button opens Amount Selection Screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecommendationScreen()));

      // Go to details
      await tester.tap(find.text('Emergency Food Aid'));
      await tester.pumpAndSettle();

      // Tap Donate Now
      await tester.tap(find.text('Donate Now'));
      await tester.pumpAndSettle();

      // 3. Verify we are on the "Choose Amount" screen
      expect(find.text('Choose Amount'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
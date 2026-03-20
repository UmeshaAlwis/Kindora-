import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
// Ensure this path matches your actual project structure
import 'package:kindora/screens/recommendation_screen.dart';

void main() {
  group('Recommendation Flow & Donation Logic Tests', () {

    testWidgets('Step 1: Tapping a card opens CauseDetailScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecommendationScreen()));

      final waterCard = find.text('Clean Water Initiative');
      expect(waterCard, findsOneWidget);

      await tester.tap(waterCard);
      await tester.pumpAndSettle();

      // Verify we navigated (Check for title in the detail body)
      expect(find.text('Clean Water Initiative'), findsAtLeastNWidgets(1));
      expect(find.text('Donate Now'), findsOneWidget);
    });

    testWidgets('Step 2: Donate Now button opens DonationAmountScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecommendationScreen()));

      await tester.tap(find.text('Emergency Food Aid'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Donate Now'));
      await tester.pumpAndSettle();

      expect(find.text('Select Amount'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Step 3: Confirm Donation shows Success Dialog and pops to home', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecommendationScreen()));

      await tester.tap(find.text('Rural School Library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Donate Now'));
      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(find.byType(TextField), '25');
      await tester.pump();

      // Tap Confirm & Pay
      await tester.tap(find.text('Confirm & Pay'));
      await tester.pumpAndSettle();

      // ✅ THE FIX: Look for the text specifically within the AlertDialog
      // This differentiates it from the text still in the TextField
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(AlertDialog),
              matching: find.textContaining('25')
          ),
          findsOneWidget
      );
      expect(find.byIcon(LucideIcons.checkCircle), findsOneWidget);

      // Final navigation check
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('AI Recommendations'), findsOneWidget);
    });
  });
}
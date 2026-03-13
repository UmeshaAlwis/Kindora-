import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindora/screens/rewards_screen.dart'; // Ensure this path is correct
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  group('Rewards Screen Professional QA Tests', () {

    testWidgets('1. Verify Header Title and Points exist', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RewardsScreen()));

      // Looking for your specific level and points
      expect(find.text('Level 3 Helper'), findsOneWidget);
      expect(find.text('150 Points'), findsOneWidget);

      // Verify the trophy icon in the blue header
      expect(find.byIcon(LucideIcons.trophy), findsOneWidget);
    });

    testWidgets('2. Verify "Your Badges" section is visible', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RewardsScreen()));

      expect(find.text('Your Badges'), findsOneWidget);

      // Verify that at least one of your badges is rendered
      expect(find.text('First Gift'), findsOneWidget);
      expect(find.text('Eco Warrior'), findsOneWidget);
    });

    testWidgets('3. Test Badge Flipping Interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RewardsScreen()));

      // Before tapping, we should see the front label
      expect(find.text('First Gift'), findsOneWidget);

      // Tap the badge to flip it
      await tester.tap(find.text('First Gift'));
      await tester.pumpAndSettle(); // Wait for animation to finish

      // After tapping, the front text is gone and the description appears
      expect(find.text('First donation award!'), findsOneWidget);
    });

    testWidgets('4. Verify Progress Indicator', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RewardsScreen()));

      // Check if the percentage text is present
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Progress to Level 4'), findsOneWidget);
    });
  });
}
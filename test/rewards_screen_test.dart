import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindora/screens/rewards_screen.dart'; // Check your path!

void main() {
  // This is a Widget Test
  testWidgets('Rewards Screen has a title and a back button', (WidgetTester tester) async {
    // 1. Build our widget
    await tester.pumpWidget(const MaterialApp(home: RewardsScreen()));

    // 2. Search for the Title (Change 'Rewards' to your actual title text)
    expect(find.text('Rewards'), findsOneWidget);

    // 3. Search for a Back Button icon
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}
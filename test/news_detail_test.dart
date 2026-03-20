import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindora/screens/news_detail_screen.dart';

void main() {
  testWidgets('News Detail Screen displays correct campaign information', (WidgetTester tester) async {
    // 1. Provide mock data to the screen
    await tester.pumpWidget(
      const MaterialApp(
        home: NewsDetailScreen(
          title: 'Test Campaign',
          subtitle: 'This is a test description.',
          status: 'URGENT',
          color: Colors.red,
        ),
      ),
    );

    // 2. Verify the Title and Status appear
    expect(find.text('Test Campaign'), findsOneWidget);
    expect(find.text('URGENT'), findsOneWidget);
    expect(find.text('Project Overview'), findsOneWidget);

    // 3. Verify the Action Button exists
    expect(find.text('Share this Update'), findsOneWidget);
  });
}
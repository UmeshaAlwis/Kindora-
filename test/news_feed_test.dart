import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// 1. Make sure this import matches your actual file path
import 'package:kindora/screens/news_feed_screen.dart';
import 'package:kindora/screens/news_detail_screen.dart';

void main() {
  testWidgets('News Feed renders all campaign types', (WidgetTester tester) async {
    // 2. We use FeedScreen() here because that is the class name in your file
    await tester.pumpWidget(const MaterialApp(home: FeedScreen()));

    // 3. Check for your specific "Jaffna" news item
    expect(find.textContaining('Jaffna Water Project'), findsOneWidget);

    // 4. Check for a status tag
    expect(find.text('URGENT'), findsOneWidget);
  });
}
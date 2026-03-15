// Rewards Logic Test
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Reward badge should be "Gold" if points > 100', () {
    int points = 150;
    String badge;

    if (points > 100) {
      badge = 'Gold';
    } else {
      badge = 'Silver';
    }

    expect(badge, 'Gold'); // The test passes if badge is Gold
  });
}
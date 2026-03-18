import 'package:flutter_test/flutter_test.dart';

// This function simulates your app's reward logic
int calculateNewTotal(int currentPoints, int earnedPoints) {
  return currentPoints + earnedPoints;
}

void main() {
  group('Reward System Logic Tests', () {

    test('Points should increment correctly after a donation', () {
      int initialPoints = 50;
      int pointsEarned = 10;

      int newTotal = calculateNewTotal(initialPoints, pointsEarned);

      // This is the core check: 50 + 10 must equal 60
      expect(newTotal, 60);
    });

    test('Badge status should update correctly based on point thresholds', () {
      int points = 150;
      String badge = (points > 100) ? 'Gold' : 'Silver';

      expect(badge, 'Gold');
    });

  });
}
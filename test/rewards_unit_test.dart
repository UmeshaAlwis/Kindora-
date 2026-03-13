import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Reward points should increment correctly', () {
    int currentPoints = 50;
    int pointsEarned = 20;

    int total = currentPoints + pointsEarned;

    // This is the "Test" - confirming the math is correct
    expect(total, 70);
  });
}
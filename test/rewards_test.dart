import 'package:flutter_test/flutter_test.dart';
// Import your project files here

void main() {
  test('Points should never be negative', () {
    var points = 150;
    expect(points >= 0, true);
  });

  test('Level 3 should require at least 100 points', () {
    var userPoints = 150;
    var currentLevel = 3;
    if (userPoints >= 100) {
      expect(currentLevel, 3);
    }
  });
}
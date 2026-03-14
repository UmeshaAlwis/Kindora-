// Badge model for Kindora
// import 'package:flutter/material.dart';

class BadgeModel {
  final String name;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  BadgeModel({
    required this.name,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
  });
}
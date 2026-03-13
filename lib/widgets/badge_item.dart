import 'package:flutter/material.dart';
import '../models/badge_model.dart';

class BadgeItem extends StatelessWidget {
  final BadgeModel badge;

  const BadgeItem({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: badge.isUnlocked ? badge.color.withOpacity(0.2) : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            badge.icon,
            size: 30,
            color: badge.isUnlocked ? badge.color : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          badge.title,
          style: TextStyle(
            fontSize: 12,
            color: badge.isUnlocked ? Colors.black87 : Colors.grey,
            fontWeight: badge.isUnlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
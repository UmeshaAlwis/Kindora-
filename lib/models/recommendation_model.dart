import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Recommendation {
  final int id;
  final String title;
  final String reason;
  final String category;
  final int impactScore;
  final IconData icon;
  final Color themeColor;

  Recommendation({
    required this.id,
    required this.title,
    required this.reason,
    required this.category,
    required this.impactScore,
    required this.icon,
    required this.themeColor,
  });

  // ✅ The "Factory" constructor: Converts Supabase Map to Recommendation Object
  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'] as int,
      title: map['title'] ?? 'Untitled Cause',
      reason: map['match_reason'] ?? 'Recommended for you',
      category: map['category'] ?? 'General',
      impactScore: map['impact_score'] ?? 0,
      icon: _mapIcon(map['icon_name']),
      themeColor: _mapColor(map['category']),
    );
  }

  // Helper to turn Database String into Lucide Icon
  static IconData _mapIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'leaf': return LucideIcons.leaf;
      case 'droplet': return LucideIcons.droplets;
      case 'monitor': return LucideIcons.monitor;
      case 'heart': return LucideIcons.heart;
      case 'zap': return LucideIcons.zap;
      default: return LucideIcons.sparkles;
    }
  }

  // Helper to turn Category into specific Branding Colors
  static Color _mapColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'sustainability': return const Color(0xFF4CAF50); // Green
      case 'education': return const Color(0xFF0C0C79);      // Primary Blue
      case 'health': return Colors.redAccent;
      default: return const Color(0xFFFF751F);               // Primary Orange
    }
  }
}
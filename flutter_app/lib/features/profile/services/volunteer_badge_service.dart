import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:kindora/config/app_env.dart';

/// Single unlocked badge from GET /campaigns/volunteer/badges
class VolunteerBadge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool unlocked;

  const VolunteerBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  factory VolunteerBadge.fromJson(Map<String, dynamic> json) {
    return VolunteerBadge(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      unlocked: json['unlocked'] == true,
    );
  }
}

class VolunteerBadgeSummary {
  final int campaignsJoined;
  final int distinctOrganizers;
  final List<VolunteerBadge> badges;

  const VolunteerBadgeSummary({
    required this.campaignsJoined,
    required this.distinctOrganizers,
    required this.badges,
  });
}

class VolunteerBadgeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<VolunteerBadgeSummary> getSummary() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = await user.getIdToken();
    final response = await http.get(
      Uri.parse('${AppEnv.apiBaseUrl}/campaigns/volunteer/badges'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('Invalid badge response');
    }
    final body = Map<String, dynamic>.from(decoded);
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to load volunteer badges');
    }

    final rawData = body['data'];
    if (rawData is! Map) {
      throw Exception('Invalid badge payload');
    }
    final data = Map<String, dynamic>.from(rawData);
    final rawStats = data['stats'];
    final stats = rawStats is Map
        ? Map<String, dynamic>.from(rawStats)
        : <String, dynamic>{};
    final badgesRaw = data['badges'] is List ? data['badges'] as List : const [];

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return VolunteerBadgeSummary(
      campaignsJoined: parseInt(stats['campaigns_joined']),
      distinctOrganizers: parseInt(stats['distinct_organizers']),
      badges: badgesRaw
          .whereType<Map>()
          .map((e) => VolunteerBadge.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:kindora/config/app_env.dart';

int _parseStatInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _parseStatDouble(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

class DonorBadge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool unlocked;

  const DonorBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  factory DonorBadge.fromJson(Map<String, dynamic> json) {
    return DonorBadge(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      unlocked: json['unlocked'] == true,
    );
  }
}

class DonorBadgeSummary {
  final double totalDonated;
  final int campaignsSupported;
  final int successfulDonations;
  final List<DonorBadge> badges;

  const DonorBadgeSummary({
    required this.totalDonated,
    required this.campaignsSupported,
    required this.successfulDonations,
    required this.badges,
  });
}

class DonorBadgeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DonorBadgeSummary> getSummary() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = await user.getIdToken();
    final response = await http.get(
      Uri.parse('${AppEnv.apiBaseUrl}/donations/badges'),
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
      throw Exception(body['error'] ?? 'Failed to load badge summary');
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

    return DonorBadgeSummary(
      totalDonated: _parseStatDouble(stats['total_donated']),
      campaignsSupported: _parseStatInt(stats['campaigns_supported']),
      successfulDonations: _parseStatInt(stats['successful_donations']),
      badges: badgesRaw
          .whereType<Map>()
          .map((e) => DonorBadge.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

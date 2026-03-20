import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:kindora/config/app_env.dart';

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

    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to load badge summary');
    }

    final data = body['data'] as Map<String, dynamic>;
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    final badgesRaw = (data['badges'] as List?) ?? const [];

    return DonorBadgeSummary(
      totalDonated: (stats['total_donated'] as num?)?.toDouble() ?? 0,
      campaignsSupported: (stats['campaigns_supported'] as num?)?.toInt() ?? 0,
      successfulDonations: (stats['successful_donations'] as num?)?.toInt() ?? 0,
      badges: badgesRaw
          .map((e) => DonorBadge.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

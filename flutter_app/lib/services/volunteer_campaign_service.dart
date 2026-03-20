import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:kindora/config/app_env.dart';

class VolunteerCampaign {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime? endDate;
  final bool needsVolunteers;
  final String donorId;
  final String donorFullName;
  final bool isJoined;

  const VolunteerCampaign({
    required this.id,
    required this.title,
    required this.needsVolunteers,
    required this.donorId,
    required this.donorFullName,
    required this.isJoined,
    this.description,
    this.imageUrl,
    this.endDate,
  });

  factory VolunteerCampaign.fromJson(Map<String, dynamic> json) {
    return VolunteerCampaign(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      needsVolunteers: json['needs_volunteers'] == true,
      donorId: (json['donor_id'] ?? json['user_id'] ?? '').toString(),
      donorFullName:
          (json['donor_full_name'] ?? '').toString().isEmpty
              ? 'User'
              : json['donor_full_name'].toString(),
      isJoined: json['is_joined'] == true,
    );
  }
}

class VolunteerCampaignService {
  Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final idToken = await user.getIdToken();
    return {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };
  }

  Future<List<VolunteerCampaign>> getAvailableCampaigns({int limit = 50}) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppEnv.apiBaseUrl}/campaigns/volunteer/available?limit=$limit'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load volunteer campaigns');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List? ?? [];
    return data
        .map((e) => VolunteerCampaign.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VolunteerCampaign>> getJoinedCampaigns() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppEnv.apiBaseUrl}/campaigns/volunteer/joined'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load joined campaigns');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List? ?? [];
    return data
        .map((e) => VolunteerCampaign.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> joinCampaign(String campaignId) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppEnv.apiBaseUrl}/campaigns/volunteer/$campaignId/join'),
      headers: headers,
      body: jsonEncode({}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Failed to join campaign');
    }
  }

  Future<void> leaveCampaign(String campaignId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${AppEnv.apiBaseUrl}/campaigns/volunteer/$campaignId/join'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Failed to leave campaign');
    }
  }
}


import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for campaign creation request
class CreateCampaignRequest {
  final String title;
  final String description;
  final String category;
  final double targetAmount;
  final String? beneficiaryDetails;
  final String? beneficiaryLocation;
  final String? imageUrl;
  final List<String>? galleryUrls;
  final DateTime? endDate;
  final String charityId;

  CreateCampaignRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.targetAmount,
    this.beneficiaryDetails,
    this.beneficiaryLocation,
    this.imageUrl,
    this.galleryUrls,
    this.endDate,
    required this.charityId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'target_amount': targetAmount,
      if (beneficiaryDetails != null) 'beneficiary_details': beneficiaryDetails,
      if (beneficiaryLocation != null) 'beneficiary_location': beneficiaryLocation,
      if (imageUrl != null) 'image_url': imageUrl,
      if (galleryUrls != null) 'gallery_urls': galleryUrls,
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      'charityId': charityId,
    };
  }
}

/// Campaign Service for backend communication
class CampaignService {
  static const String _baseUrl = 'http://localhost:3000/api';

  /// Create a new campaign
  /// 
  /// Submits campaign data to the backend and returns campaign ID on success
  static Future<String> createCampaign(
    CreateCampaignRequest request,
    String authToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/campaigns'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data']['id'] ?? '';
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception('Validation Error: ${error['message']}');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to create campaign: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all campaigns with optional filters
  static Future<List<Map<String, dynamic>>> getCampaigns({
    int page = 1,
    int limit = 20,
    String? status,
    String? category,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/campaigns').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (status != null) 'status': status,
          if (category != null) 'category': category,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to fetch campaigns: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get campaign details by ID
  static Future<Map<String, dynamic>> getCampaignById(String campaignId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/campaigns/$campaignId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else if (response.statusCode == 404) {
        throw Exception('Campaign not found');
      } else {
        throw Exception('Failed to fetch campaign: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

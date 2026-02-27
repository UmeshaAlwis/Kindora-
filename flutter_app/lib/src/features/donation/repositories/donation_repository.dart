import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/donation_model.dart';

class DonationRepository {
  final String baseUrl;
  final String Function() getToken; // Callback to get Firebase token

  DonationRepository({
    this.baseUrl = 'http://localhost:3000',
    String Function()? getToken,
  }) : getToken = getToken ?? (() => 'mock_token');

  Future<DonationSummary> fetchDonationSummary() async {
    try {
      final token = getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/analytics/summary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return DonationSummary.fromJson(json);
      } else {
        throw Exception('Failed to load donation summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching donation summary: $e');
    }
  }

  Future<List<Donation>> fetchDonationHistory({int page = 1, int limit = 10}) async {
    try {
      final token = getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/donations/history?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is List) {
          return (json)
              .map((item) => Donation.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (json is Map && json['donations'] != null) {
          return (json['donations'] as List)
              .map((item) => Donation.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load donation history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching donation history: $e');
    }
  }

  Future<List<RecurringDonation>> fetchRecurringDonations() async {
    try {
      final token = getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/donations/recurring'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is List) {
          return (json)
              .map((item) => RecurringDonation.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (json is Map && json['donations'] != null) {
          return (json['donations'] as List)
              .map((item) => RecurringDonation.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load recurring donations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recurring donations: $e');
    }
  }

  Future<List<CategoryBreakdown>> fetchCategoryBreakdown() async {
    try {
      final token = getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/analytics/summary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map && json['breakdown'] != null) {
          return (json['breakdown'] as List)
              .map((item) => CategoryBreakdown.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load category breakdown: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching category breakdown: $e');
    }
  }

  Future<void> cancelRecurringDonation(String donationId) async {
    try {
      final token = getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/donations/recurring/$donationId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel recurring donation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error canceling recurring donation: $e');
    }
  }

  Future<String> downloadReceipt(String donationId) async {
    try {
      final token = getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/donations/$donationId/receipt'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // In a real app, this would be a PDF URL or the PDF bytes
        // For now, we'll return a success message
        return 'Receipt downloaded successfully';
      } else {
        throw Exception('Failed to download receipt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading receipt: $e');
    }
  }
}

import 'package:dio/dio.dart';
import 'api_client.dart';

class DonationService {
  static const String _endpoint = '/donations';

  /// Create a new donation
  static Future<Map<String, dynamic>> createDonation({
    required String charityId,
    required double amount,
    required String currency,
    required String paymentMethod,
  }) async {
    try {
      final response = await apiClient.post(
        _endpoint,
        data: {
          'charityId': charityId,
          'amount': amount,
          'currency': currency,
          'paymentMethod': paymentMethod,
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Donation created successfully',
        };
      }

      return {
        'success': false,
        'message': 'Failed to create donation',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.message}',
        'error': e,
      };
    }
  }

  /// Get all donations for a user
  static Future<Map<String, dynamic>> getUserDonations(String userId) async {
    try {
      final response = await apiClient.get(
        _endpoint,
        params: {'userId': userId},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': 'Failed to fetch donations',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.message}',
        'error': e,
      };
    }
  }

  /// Get donation by ID
  static Future<Map<String, dynamic>> getDonation(String donationId) async {
    try {
      final response = await apiClient.get('$_endpoint/$donationId');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': 'Donation not found',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.message}',
        'error': e,
      };
    }
  }

  /// Update donation status
  static Future<Map<String, dynamic>> updateDonationStatus(
    String donationId,
    String status,
  ) async {
    try {
      final response = await apiClient.put(
        '$_endpoint/$donationId',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Donation updated successfully',
        };
      }

      return {
        'success': false,
        'message': 'Failed to update donation',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.message}',
        'error': e,
      };
    }
  }
}

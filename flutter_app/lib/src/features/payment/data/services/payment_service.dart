import 'package:dio/dio.dart';
import '../models/payment_model.dart';

class PaymentService {
  static const String apiBaseUrl = 'http://localhost:5000/api/payments';
  late Dio _dio;

  PaymentService() {
    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  /// Create a donation payment
  Future<PaymentModel> createPayment({
    required String campaignId,
    required double amount,
    required String paymentMethod, // 'card', 'mobile_wallet', 'bank_transfer', 'crypto'
    String donationType = 'one-time',
    String? recurringFrequency,
    String? message,
    bool isAnonymous = false,
    String? authToken,
  }) async {
    try {
      final payload = {
        'campaign_id': campaignId,
        'amount': amount,
        'payment_method': paymentMethod,
        'donation_type': donationType,
        'recurring_frequency': recurringFrequency,
        'message': message,
        'is_anonymous': isAnonymous,
      };

      final headers = authToken != null ? {'Authorization': 'Bearer $authToken'} : <String, dynamic>{};

      final response = await _dio.post(
        '/create',
        data: payload,
        options: Options(headers: headers),
      );

      if (response.statusCode == 201) {
        return PaymentModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create payment: ${response.data['error']}');
      }
    } catch (e) {
      throw Exception('Payment creation error: $e');
    }
  }

  /// Get payment status
  Future<PaymentModel> getPaymentStatus(String paymentId, String? authToken) async {
    try {
      final headers = authToken != null ? {'Authorization': 'Bearer $authToken'} : <String, dynamic>{};

      final response = await _dio.get(
        '/$paymentId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return PaymentModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch payment: ${response.data['error']}');
      }
    } catch (e) {
      throw Exception('Payment fetch error: $e');
    }
  }

  /// Verify payment with PayHere
  Future<bool> verifyPayment({
    required String paymentId,
    required String transactionId,
    String? authToken,
  }) async {
    try {
      final headers = authToken != null ? {'Authorization': 'Bearer $authToken'} : <String, dynamic>{};

      final response = await _dio.post(
        '/verify',
        data: {
          'payment_id': paymentId,
          'transaction_id': transactionId,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data['success'] ?? true;
      } else {
        throw Exception('Payment verification failed: ${response.data['error']}');
      }
    } catch (e) {
      throw Exception('Payment verification error: $e');
    }
  }

  /// Get PayHere payment URL
  Future<String> getPaymentUrl(String paymentId, String? authToken) async {
    try {
      final headers = authToken != null ? {'Authorization': 'Bearer $authToken'} : <String, dynamic>{};

      final response = await _dio.get(
        '/$paymentId/payment-url',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data['payment_url'] ?? '';
      } else {
        throw Exception('Failed to get payment URL: ${response.data['error']}');
      }
    } catch (e) {
      throw Exception('Payment URL fetch error: $e');
    }
  }

  /// Get user's donation history
  Future<List<PaymentModel>> getDonationHistory({
    required String userId,
    int page = 1,
    int limit = 20,
    String? authToken,
  }) async {
    try {
      final headers = authToken != null ? {'Authorization': 'Bearer $authToken'} : <String, dynamic>{};

      final response = await _dio.get(
        '/user/$userId/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((item) => PaymentModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch donation history');
      }
    } catch (e) {
      throw Exception('Donation history fetch error: $e');
    }
  }

  /// Cancel recurring donation
  Future<bool> cancelRecurringDonation(String paymentId, String? authToken) async {
    try {
      final headers = authToken != null ? {'Authorization': 'Bearer $authToken'} : <String, dynamic>{};

      final response = await _dio.post(
        '/$paymentId/cancel',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data['success'] ?? true;
      } else {
        throw Exception('Failed to cancel recurring donation');
      }
    } catch (e) {
      throw Exception('Cancellation error: $e');
    }
  }
}

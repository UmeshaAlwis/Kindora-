import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:kindora/config/app_env.dart';
import 'package:kindora/services/api_dio.dart';

class StripeService {
  late final String _stripeCreateIntentUrl;
  late final String _stripeConfirmPaymentUrl;

  StripeService() {
    _stripeCreateIntentUrl = AppEnv.stripeCreateIntentUrl;
    _stripeConfirmPaymentUrl = AppEnv.stripeConfirmPaymentUrl;
  }

  final Dio _dio = createApiDio();

  /// Creates a payment intent on the backend
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String donorName,
    required String donorEmail,
    required String campaignId,
    required String currency,
  }) async {
    try {
      final response = await _dio.post(
        _stripeCreateIntentUrl,
        data: {
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': currency,
          'donor_name': donorName,
          'donor_email': donorEmail,
          'campaign_id': campaignId,
          'payment_method': 'stripe',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to create payment intent: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Stripe Error: ${e.message}');
    }
  }

  /// Confirms payment with Stripe
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _dio.post(
        _stripeConfirmPaymentUrl,
        data: {
          'payment_intent_id': paymentIntentId,
          'payment_method_id': paymentMethodId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to confirm payment: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Stripe Confirmation Error: ${e.message}');
    }
  }

  /// Initialize payment sheet for Stripe
  Future<void> initPaymentSheet({
    required String clientSecret,
    required String customerId,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customerId: customerId,
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Kindora',
        ),
      );
    } catch (e) {
      throw Exception('Error initializing payment sheet: $e');
    }
  }

  /// Process payment using Stripe Payment Sheet
  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw Exception('Payment cancelled by user');
      } else {
        throw Exception('Payment failed: ${e.error.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../config/payhere_config.dart';

/// PayHere Payment Service using WebView approach (no SDK required)
class PayHerePaymentService {
  static final PayHerePaymentService _instance =
      PayHerePaymentService._internal();

  factory PayHerePaymentService() {
    return _instance;
  }

  PayHerePaymentService._internal();

  /// PayHere Sandbox Payment URL
  static const String sandboxPaymentUrl =
      'https://sandbox.payhere.lk/pay/checkout';

  /// PayHere Production Payment URL
  static const String productionPaymentUrl =
      'https://www.payhere.lk/pay/checkout';

  /// Generate MD5 hash for PayHere payment signature
  String generateHash(
    String merchantId,
    String orderId,
    double amount,
    String merchantSecret,
  ) {
    // If merchant secret is base64 encoded, decode it first
    String secret = merchantSecret;
    try {
      if (merchantSecret.contains('=') || merchantSecret.length % 4 == 0) {
        secret = utf8.decode(base64.decode(merchantSecret));
      }
    } catch (e) {
      // If decoding fails, use as-is
      debugPrint('Could not decode merchant secret, using as-is');
    }

    final hashString = '$merchantId$orderId${amount.toStringAsFixed(2)}$secret';

    debugPrint('Hash input: $hashString');
    final generatedHash = md5.convert(utf8.encode(hashString)).toString();
    debugPrint('Generated hash: $generatedHash');

    return generatedHash;
  }

  /// Build PayHere checkout URL with payment parameters for WebView
  String buildPaymentUrl({
    required Payment payment,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String campaignDescription,
  }) {
    final merchantId = PayHereConfig.merchantId;
    final amount = payment.amount.toStringAsFixed(2);
    final firstName = customerName.split(' ').first;
    final lastName = customerName.split(' ').length > 1
        ? customerName.split(' ').sublist(1).join(' ')
        : 'Donor';

    final hash = generateHash(
      merchantId,
      orderId,
      payment.amount,
      PayHereConfig.merchantSecret,
    );

    const paymentUrl =
        PayHereConfig.isProduction ? productionPaymentUrl : sandboxPaymentUrl;

    // Build URL with ONLY required PayHere parameters
    final params = {
      'merchant_id': merchantId,
      'return_url': PayHereConfig.sandboxReturnUrl,
      'cancel_url': PayHereConfig.sandboxCancelUrl,
      'notify_url': PayHereConfig.sandboxNotifyUrl,
      'order_id': orderId,
      'items': campaignDescription,
      'amount': amount,
      'currency': 'LKR',
      'first_name': firstName,
      'last_name': lastName,
      'email': customerEmail,
      'phone': customerPhone,
      'hash': hash,
    };

    // Build query string with proper URL encoding
    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$paymentUrl?$queryString';
  }

  /// Get payment parameters as map (for debugging/logging)
  Map<String, String> getPaymentParameters({
    required Payment payment,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String campaignDescription,
  }) {
    final merchantId = PayHereConfig.merchantId;
    final amount = payment.amount.toStringAsFixed(2);
    final firstName = customerName.split(' ').first;
    final lastName = customerName.split(' ').length > 1
        ? customerName.split(' ').sublist(1).join(' ')
        : 'Donor';

    final hash = generateHash(
      merchantId,
      orderId,
      payment.amount,
      PayHereConfig.merchantSecret,
    );

    return {
      'merchant_id': merchantId,
      'return_url': PayHereConfig.sandboxReturnUrl,
      'cancel_url': PayHereConfig.sandboxCancelUrl,
      'notify_url': PayHereConfig.sandboxNotifyUrl,
      'order_id': orderId,
      'items': campaignDescription,
      'amount': amount,
      'currency': 'LKR',
      'first_name': firstName,
      'last_name': lastName,
      'email': customerEmail,
      'phone': customerPhone,
      'hash': hash,
    };
  }

  /// Verify payment response hash from PayHere
  bool verifyPaymentHash({
    required String merchantId,
    required String orderId,
    required String amount,
    required String responseHash,
  }) {
    final hashString =
        '$merchantId$orderId${double.parse(amount).toStringAsFixed(2)}${PayHereConfig.merchantSecret}';
    final calculatedHash = md5.convert(utf8.encode(hashString)).toString();
    return calculatedHash == responseHash;
  }
}

final payHereService = PayHerePaymentService();

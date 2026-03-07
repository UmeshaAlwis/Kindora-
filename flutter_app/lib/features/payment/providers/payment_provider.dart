import '../models/payment_model.dart';

// Mock payment processing service
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() {
    return _instance;
  }

  PaymentService._internal();

  final List<Payment> _payments = [];

  Future<bool> processPayment(Payment payment) async {
    // Simulate API call to payment gateway
    await Future.delayed(const Duration(seconds: 2));
    _payments.add(payment);
    return true;
  }

  Future<List<Payment>> getPaymentHistory(String? campaignId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (campaignId == null) {
      return _payments;
    }
    return _payments.where((p) => p.campaignId == campaignId).toList();
  }

  int getTotalDonationsCount() => _payments.length;

  double getTotalDonationsAmount() {
    return _payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }
}

// Singleton instance
final paymentService = PaymentService();

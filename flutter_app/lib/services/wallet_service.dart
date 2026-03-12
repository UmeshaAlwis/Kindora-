import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet_model.dart';

class WalletService {
  static const String baseUrl =
      'http://localhost:5001'; // Backend server port (from .env PORT=5001)

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's wallet balance
  Future<double> getWalletBalance() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/wallet/balance'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['balance'] as num?)?.toDouble() ?? 0.0;
      } else if (response.statusCode == 404) {
        // Wallet doesn't exist, initialize it
        await initializeWallet();
        return 0.0;
      } else {
        throw Exception(
            'Failed to fetch wallet balance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wallet balance: $e');
    }
  }

  /// Initialize wallet for new user
  Future<Wallet> initializeWallet() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$baseUrl/wallet/initialize'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': user.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Wallet.fromJson(data['wallet'] ?? data);
      } else {
        throw Exception('Failed to initialize wallet: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error initializing wallet: $e');
    }
  }

  /// Get wallet transactions (paginated)
  Future<List<WalletTransaction>> getWalletTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/wallet/transactions?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> transactions = data['transactions'] ?? [];
        return transactions.map((t) => WalletTransaction.fromJson(t)).toList();
      } else {
        throw Exception('Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  /// Top-up wallet balance (Stripe/Card payment)
  Future<void> topUpWallet({
    required double amount,
    required String paymentMethodId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$baseUrl/wallet/topup'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'payment_method_id': paymentMethodId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to top-up wallet: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error topping up wallet: $e');
    }
  }

  /// Process wallet payment for donation
  Future<void> processWalletPayment({
    required double amount,
    required String campaignId,
    required String donorName,
    required String donorEmail,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$baseUrl/donation/create'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'campaign_id': campaignId,
          'amount': amount,
          'payment_method': 'wallet',
          'donor_name': donorName,
          'donor_email': donorEmail,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to process wallet payment',
        );
      }
    } catch (e) {
      throw Exception('Error processing wallet payment: $e');
    }
  }

  /// Get full wallet details
  Future<Wallet> getWalletDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/wallet/details'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Wallet.fromJson(data['wallet'] ?? data);
      } else {
        throw Exception(
            'Failed to fetch wallet details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wallet details: $e');
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet_model.dart';
import '../config/app_env.dart';

class WalletService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's wallet balance
  Future<double> getWalletBalance() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse('${AppEnv.apiBaseUrl}/wallet/balance'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[WalletService] Response: $data');

        // Backend returns: { success: true, data: { balance } }
        final balance = (data['data']?['balance'] as num?)?.toDouble() ?? 0.0;
        print('[WalletService] Parsed balance: $balance');
        return balance;
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
        Uri.parse('${AppEnv.apiBaseUrl}/wallet/initialize'),
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
        // Backend returns: { success: true, data: { ... wallet data ... } }
        return Wallet.fromJson(data['data'] ?? data);
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
        Uri.parse(
            '${AppEnv.apiBaseUrl}/wallet/transactions?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns: { success: true, data: [ transactions ], total, page, limit, pages }
        final List<dynamic> transactions = data['data'] ?? [];
        return transactions.map((t) => WalletTransaction.fromJson(t)).toList();
      } else {
        throw Exception('Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  /// Top-up wallet balance (Demo/Mock implementation)
  Future<Map<String, dynamic>> topUpWallet({
    required double amount,
    required String paymentMethodId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('${AppEnv.apiBaseUrl}/wallet/topup'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'payment_method': paymentMethodId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'Failed to top-up wallet: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      return data['data'] ?? data;
    } catch (e) {
      throw Exception('Error topping up wallet: $e');
    }
  }

  /// Process wallet payment for donation
  Future<void> processWalletPayment({
    required double amount,
    required String campaignId,
    String? beneficiaryCampaignId,
    required String donorName,
    required String donorEmail,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      // Determine if this is a beneficiary campaign donation
      final isBeneficiaryDonation =
          beneficiaryCampaignId != null && beneficiaryCampaignId.isNotEmpty;

      // Build request body
      final body = {
        'amount': amount,
        'payment_method': 'wallet',
        'donor_name': donorName,
        'donor_email': donorEmail,
      };

      if (isBeneficiaryDonation) {
        body['beneficiary_campaign_id'] = beneficiaryCampaignId;
      } else {
        body['campaign_id'] = campaignId;
      }

      // Use different endpoint for beneficiary donations
      final endpoint =
          isBeneficiaryDonation ? '/beneficiary-donations' : '/donations';

      final response = await http.post(
        Uri.parse('${AppEnv.apiBaseUrl}$endpoint'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
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
        Uri.parse('${AppEnv.apiBaseUrl}/wallet/details'),
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

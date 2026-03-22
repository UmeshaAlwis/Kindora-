import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:kindora/config/app_env.dart';

int _parseApiInt(dynamic value, int fallback) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _parseApiDouble(dynamic value, double fallback) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

/// One row from `GET /api/donations/history` (donations table).
class DonationHistoryEntry {
  final String id;
  final double amount;
  final String status;
  final String? paymentMethod;
  final DateTime? createdAt;
  final String? campaignId;
  final String? beneficiaryCampaignId;

  const DonationHistoryEntry({
    required this.id,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.createdAt,
    this.campaignId,
    this.beneficiaryCampaignId,
  });

  factory DonationHistoryEntry.fromJson(Map<String, dynamic> json) {
    final bc = json['beneficiary_campaign_id'];
    final camp = json['campaign_id'];
    return DonationHistoryEntry(
      id: (json['id'] ?? json['donation_id'] ?? '').toString(),
      amount: _parseApiDouble(json['amount'], 0),
      status: (json['status'] ?? '').toString().toLowerCase(),
      paymentMethod: json['payment_method']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      campaignId: camp?.toString(),
      beneficiaryCampaignId: bc?.toString(),
    );
  }

  bool get isBeneficiary =>
      beneficiaryCampaignId != null && beneficiaryCampaignId!.isNotEmpty;

  bool get isCampaign =>
      !isBeneficiary && campaignId != null && campaignId!.isNotEmpty;

  String get typeLabel {
    if (isBeneficiary) return 'Beneficiary campaign';
    if (isCampaign) return 'Campaign';
    return 'Donation';
  }
}

class DonationHistoryPageResult {
  final List<DonationHistoryEntry> items;
  final int total;

  const DonationHistoryPageResult({
    required this.items,
    required this.total,
  });
}

class DonorDonationHistoryService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Paginated history; `total` is full count from API (for "See more").
  Future<DonationHistoryPageResult> fetchHistoryPage({
    int page = 1,
    int limit = 30,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = await user.getIdToken();
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/donations/history')
        .replace(queryParameters: {'page': '$page', 'limit': '$limit'});

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('Invalid donation history response');
    }
    final body = Map<String, dynamic>.from(decoded);
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to load donation history');
    }

    final raw = body['data'];
    final List<dynamic> list = raw is List<dynamic> ? raw : <dynamic>[];
    final items = list
        .map((e) {
          if (e is! Map) {
            return null;
          }
          return DonationHistoryEntry.fromJson(
            Map<String, dynamic>.from(e),
          );
        })
        .whereType<DonationHistoryEntry>()
        .toList();
    final total = _parseApiInt(body['total'], items.length);

    return DonationHistoryPageResult(items: items, total: total);
  }

  Future<List<DonationHistoryEntry>> fetchHistory({int limit = 30}) async {
    final r = await fetchHistoryPage(page: 1, limit: limit);
    return r.items;
  }
}

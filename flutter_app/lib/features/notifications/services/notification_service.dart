import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:kindora/config/app_env.dart';

import '../models/notification_model.dart';

class NotificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final token = await user.getIdToken();

    final uri = Uri.parse(
      '${AppEnv.apiBaseUrl}/notifications?page=$page&limit=$limit',
    );
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final jsonBody = jsonDecode(res.body);
    if (res.statusCode != 200 || jsonBody['success'] != true) {
      throw Exception(jsonBody['error'] ?? 'Failed to load notifications');
    }

    final data = jsonBody['data'] ?? {};
    final notificationsJson = (data['notifications'] as List? ?? []);
    return notificationsJson
        .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final token = await user.getIdToken();

    final uri = Uri.parse('${AppEnv.apiBaseUrl}/notifications/unread-count');
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final jsonBody = jsonDecode(res.body);
    if (res.statusCode != 200 || jsonBody['success'] != true) {
      throw Exception(jsonBody['error'] ?? 'Failed to load unread count');
    }

    final data = jsonBody['data'] ?? {};
    final unread = data['unread_count'];
    if (unread is int) return unread;
    if (unread is num) return unread.toInt();
    return 0;
  }

  Future<void> markAllRead() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final token = await user.getIdToken();

    final uri = Uri.parse('${AppEnv.apiBaseUrl}/notifications/mark-read-all');
    final res = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final jsonBody = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(jsonBody['error'] ?? 'Failed to mark as read');
    }
  }
}


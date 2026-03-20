import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../config/app_env.dart';

class UserContext {
  final String userId;
  final String role;
  final String displayName;

  const UserContext({
    required this.userId,
    required this.role,
    required this.displayName,
  });
}

class DirectMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;

  const DirectMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
  });

  factory DirectMessage.fromJson(Map<String, dynamic> json) {
    return DirectMessage(
      id: (json['id'] ?? '').toString(),
      senderId: (json['sender_id'] ?? '').toString(),
      receiverId: (json['receiver_id'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}

class ConversationPreview {
  final String partnerId;
  final String partnerName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String lastMessageSenderId;
  final int unreadCount;

  const ConversationPreview({
    required this.partnerId,
    required this.partnerName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastMessageSenderId,
    required this.unreadCount,
  });
}

class DirectMessageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<Map<String, String>> _authHeaders() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw Exception('User not authenticated');
    }
    final token = await firebaseUser.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<UserContext> getCurrentUserContext() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppEnv.apiBaseUrl}/messages/me'),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to load user context');
    }

    final me = data['data'] as Map<String, dynamic>;
    return UserContext(
      userId: (me['userId'] ?? '').toString(),
      role: (me['role'] ?? 'donor').toString(),
      displayName: (me['displayName'] ?? 'User').toString(),
    );
  }

  Future<String> getUserDisplayName(String userId) async {
    final previews = await getConversationPreviews();
    final match = previews.where((p) => p.partnerId == userId).toList();
    if (match.isNotEmpty) return match.first.partnerName;
    return 'User';
  }

  Future<bool> isCurrentUserDonor() async {
    final ctx = await getCurrentUserContext();
    return ctx.role == 'donor';
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    final text = content.trim();
    if (text.isEmpty) return;

    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppEnv.apiBaseUrl}/messages'),
      headers: headers,
      body: jsonEncode({
        'recipient_id': receiverId,
        'content': text,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to send message');
    }
  }

  Future<List<DirectMessage>> getConversation(String partnerId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppEnv.apiBaseUrl}/messages/conversation/$partnerId'),
      headers: headers,
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to load conversation');
    }

    return (body['data'] as List)
        .map((e) => DirectMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConversationPreview>> getConversationPreviews() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppEnv.apiBaseUrl}/messages/conversations'),
      headers: headers,
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to load conversations');
    }

    return (body['data'] as List)
        .map((e) {
          final row = e as Map<String, dynamic>;
          return ConversationPreview(
            partnerId: (row['partnerId'] ?? '').toString(),
            partnerName: (row['partnerName'] ?? 'User').toString(),
            lastMessage: (row['lastMessage'] ?? '').toString(),
            lastMessageAt: row['lastMessageAt'] != null
                ? DateTime.parse(row['lastMessageAt'].toString())
                : DateTime.now(),
            lastMessageSenderId: (row['lastMessageSenderId'] ?? '').toString(),
            unreadCount: row['unreadCount'] is int
                ? row['unreadCount'] as int
                : int.tryParse((row['unreadCount'] ?? '0').toString()) ?? 0,
          );
        })
        .toList();
  }
}

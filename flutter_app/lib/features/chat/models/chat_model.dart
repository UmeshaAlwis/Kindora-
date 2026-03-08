/// Chat message model
class ChatMessage {
  final String id;
  final String content;
  final bool isUser; // true if sent by user, false if from bot
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Chat session model
class ChatSession {
  final String sessionId;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final bool isActive;

  ChatSession({
    required this.sessionId,
    required this.messages,
    required this.createdAt,
    this.isActive = true,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['sessionId'] ?? '',
      messages: (json['messages'] as List?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

/// Chat response from backend
class ChatResponse {
  final String reply;
  final String messageId;
  final bool success;
  final String? error;

  ChatResponse({
    required this.reply,
    required this.messageId,
    required this.success,
    this.error,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      reply: json['reply'] ?? '',
      messageId: json['messageId'] ?? '',
      success: json['success'] ?? true,
      error: json['error'],
    );
  }
}

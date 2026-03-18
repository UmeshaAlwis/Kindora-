import 'package:equatable/equatable.dart';

enum MessageStatus { sending,sent, delivered, read }
enum MessageType { text, image, attachment}

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final String? attachmentUrl;

  const MessageModel({
    required this.id,
    required this.conversationId,
     required this.receiverId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.attachmentUrl,
  });

  bool get isSentByMe => senderId == 'current_user'; // Replace with actual auth

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      type: MessageType.values.firstWhere((e) => e.name == (json['type'] ?? 'text'),
      orElse:() => MessageType.text),

    status: MessageStatus.values.firstWhere(
      (e) => e.name == (json['status'] ?? 'sent'),
      orElse: () => MessageStatus.sent,
    ),
    timestamp: DateTime.parse(json['timestamp']),
    attachmentUrl: json['attachment_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'content': content,
    'type': type.name,
    'status': status.name,
    'timestamp': timestamp.toIso8601String(),
    'attachment_url': attachmentUrl,
  };

  @override
  List<Object?> get props =>
  [id, conversationId, senderId, content, status, timestamp];
}

class ConversationModel extends Equatable{
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatarUrl;
  final bool isCharity;
  final String? campaignId;
  final String? campaignTitle;
  final MessageModel? lastMessage;
  final int unreadCount;
  final bool isOnline;

  const ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatarUrl,
    this.isCharity = false,
    this.campaignId,
    this.campaignTitle,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [id, participantId, unreadCount];
} 
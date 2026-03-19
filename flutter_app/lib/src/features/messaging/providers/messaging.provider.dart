import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Mock data – replace with real API / Supabase calls
// ---------------------------------------------------------------------------

final _uuid = Uuid();

List <ConversationModel> _mockConversations = [
  ConversationModel(
    id: 'conv_1',
    participantId: 'charity_1',
    participantName: 'Hope Foundation',
    isCharity: true,
    campaignId: 'camp_1',
    campaignTitle: 'Build School Library',
    unreadCount: 3,
    isOnline: true,
    lastMessage: MessageModel(
      id: 'msg_last_1',
      conversationId: 'conv_1',
      senderId: 'charity_1',
      receiverId: 'current_user',
      content: 'Thank you for your support! We have a new update on the campaign.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      status:MessageStatus.sent,
    ),
  ),
  ConversationModel(
    id: 'conv_2',
    participantId: 'charity_2',
    participantName: 'Green Earth Org',
    isCharity: true,
    campaignId: 'camp_2',
    campaignTitle: 'Plant 1000 Trees',
    unreadCount: 0,
    isOnline: false,
    lastMessage: MessageModel(
      id: 'msg_last_2',
      conversationId: 'conv_2',
      senderId: 'current_user',
      receiverId: 'charity_2',
      content: 'Hi! I have a question about the tree planting campaign.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status:MessageStatus.sent,
    ),
  ),

  ConversationModel(
    id: 'conv_3',
    participantId: 'charity_3',
    participantName: 'Food for All',
    isCharity: true,
    campaignId: 'camp_3',
    campaignTitle: 'Feed the Hungry',
    unreadCount: 1,
    isOnline: true,
    lastMessage: MessageModel(
      id: 'msg_last_3',
      conversationId: 'conv_3',
      senderId: 'charity_3',
      receiverId: 'current_user',
      content: 'We just reached 50% of our goal! Thank you for being part of this journey.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      status:MessageStatus.sent,
    ),
  ),
];

final Map<String, List<MessageModel>> _mockMessages = {
  'conv_1': [
    MessageModel(
      id: 'msg_1',
      conversationId: 'conv_1',
      senderId: 'current_user',
      receiverId: 'charity_1',
      content: 'Hello! I just donated to your campaign. Can you tell me more about how the funds will be used?',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status:MessageStatus.sent,
    ),
    MessageModel(
      id: 'msg_2',
      conversationId: 'conv_1',
      senderId: 'charity_1',
      receiverId: 'current_user',
      content: 'Hi! Thank you so much for your donation. The funds will go towards purchasing bookshelves and new books for the school library.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status:MessageStatus.sent,
    ),
    MessageModel(
      id: 'msg_3',
      conversationId: 'conv_1',
      senderId: 'current_user',
      receiverId: 'charity_1',
      content: 'That\’s wonderful to hear! Do you have an estimated timeline for when the library will be set up?',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      status:MessageStatus.sent,
    ),

    MessageModel(
      id: 'msg_4',
      conversationId: 'conv_1',
      senderId: 'charity_1',
      receiverId: 'current_user',
      content: 'We are aiming to have the library up and running within the next 3 months. We will keep you updated on our progress!',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      status:MessageStatus.sent,
    ),

     MessageModel(
      id: 'msg_5',
      conversationId: 'conv_1',
      senderId: 'current_user',
      receiverId: 'charity_1',
      content: 'Thank you for the update! I\’m excited to see the impact of my donation.',
      timestamp: DateTime.now().subtract(const Duration(hours: 20)),
      status:MessageStatus.sent,
    ),

     MessageModel(
      id: 'msg_6',
      conversationId: 'conv_1',
      senderId: 'charity_1',
      receiverId: 'current_user',
      content: 'We just wanted to share a quick update, we have started construction on the library foundation!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      status:MessageStatus.sent,
    ),
  ],

  'conv_2': [
    MessageModel(
      id: 'msg_2_1',
      conversationId: 'conv_2', 
      senderId: 'charity_2',
      receiverId: 'current_user',
      content: 'Hi! I have a question about the tree planting campaign.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      status: MessageStatus.read,
    ),

    MessageModel(
      id: 'msg_2_2',
      conversationId: 'conv_2',
      senderId: 'current_user',
      receiverId: 'charity_2',
      content: 'Can you tell me more about the tree planting campaign?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      status: MessageStatus.sent,
    ),
  ],

  'conv_3': [
    MessageModel(
      id: 'msg_3_1',
      conversationId: 'conv_3',
      senderId: 'charity_3',
      receiverId: 'current_user',
      content: 'We just reached 50% of our goal! Thank you for being part of this journey.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      status: MessageStatus.sent,
    ),
  ],
};

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, List<ConversationModel>>(
  (ref) => ConversationsNotifier(),
);

class ConversationsNotifier extends StateNotifier<List<ConversationModel>> {
  ConversationsNotifier() : super(_mockConversations);

  void markAsRead(String conversationId) {
    state = state.map((c) {
      if (c.id == conversationId) {
        return ConversationModel(
          id: c.id,
          participantId: c.participantId,
          participantName: c.participantName,
          participantAvatarUrl: c.participantAvatarUrl,
          isCharity: c.isCharity,
          campaignId: c.campaignId,
          campaignTitle: c.campaignTitle,
          lastMessage: c.lastMessage,
          unreadCount: 0,
          isOnline: c.isOnline,
        );
      }
      return c;
    }).toList();
  }

  void updateLastMessage(String conversationId, MessageModel message) {
    state = state.map((c) {
      if (c.id == conversationId) {
        return ConversationModel(
          id: c.id,
          participantId: c.participantId,
          participantName: c.participantName,
          participantAvatarUrl: c.participantAvatarUrl,
          isCharity: c.isCharity,
          campaignId: c.campaignId,
          campaignTitle: c.campaignTitle,
          lastMessage: message,
          unreadCount: c.unreadCount,
          isOnline: c.isOnline,
        );
      }
      return c;
    }).toList();
  }
}

//---------------------------------------------------------------------------

final messagesProvider = StateNotifierProvider.family<MessagesNotifier, List<MessageModel>, String>(
  (ref, conversationId) => MessagesNotifier(conversationId, ref),
);

class MessagesNotifier extends StateNotifier<List<MessageModel>> {
  final String conversationId;
  final Ref _ref;

  MessagesNotifier(this.conversationId, this._ref)
      : super(_mockMessages[conversationId] ?? []);

  Future<void> sendMessage(String content, String receiverId) async {
    final newMsg = MessageModel(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: 'current_user',
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    state = [...state, newMsg];

    // Simulate API call delay

    await Future.delayed(const Duration(milliseconds: 600));

    state = state.map((m) {
      if (m.id == newMsg.id) {
        return MessageModel(
          id: m.id,
          conversationId: m.conversationId,
          senderId: m.senderId,
          receiverId: m.receiverId,
          content: m.content,
          timestamp: m.timestamp,
          status: MessageStatus.sent,
        );
      }
      return m;
    }).toList();

    _ref
        .read(conversationsProvider.notifier)
        .updateLastMessage(conversationId, state.last);
  }
}
  
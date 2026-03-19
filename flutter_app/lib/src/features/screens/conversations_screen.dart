import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../features/messaging/models/message_model.dart';
import 'chat_screen.dart';

class ConversationsNotifier extends StateNotifier<List<ConversationModel>> {
  ConversationsNotifier() : super([]);

  void markAsRead(String conversationId) {
    // TODO: Implement markAsRead logic
  }
}

// Define the conversations provider
final conversationsProvider = StateNotifierProvider<ConversationsNotifier, List<ConversationModel>>((ref) {
  return ConversationsNotifier();
});

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    final filtered = conversations
        .where((c) =>
            c.participantName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (c.campaignTitle
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();

    final totalUnread = conversations.fold<int>(
        0, (sum, c) => sum + (c.unreadCount));

    return Scaffold(
      backgroundColor: KindoraColors.background,
      appBar: _buildAppBar(totalUnread),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSectionHeader('Messages', filtered.length),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                    itemBuilder: (context, index) =>
                      _ConversationTile(conversation: filtered[index]),
                  ),
          ),
        ],  
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int totalUnread) {
    return AppBar(
      backgroundColor: KindoraColors.surface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: KindoraColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chat_rounded, color: Colors.white, size:20),
          ),
          const SizedBox(width: 10),
          const Text('Messages',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: KindoraColors.textPrimary,
            ),
          ),

          if (totalUnread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: KindoraColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$totalUnread',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.edit_square, color: KindoraColors.primary),
          onPressed: () {}, // New conversation
          tooltip: 'New Message',
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: KindoraColors.border),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: KindoraColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle:
              const TextStyle(color: KindoraColors.textHint, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: KindoraColors.textHint, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: KindoraColors.textSecondary, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: KindoraColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: KindoraColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: const TextStyle(
              color: KindoraColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: KindoraColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 40, color: KindoraColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(
              color: KindoraColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Donate to a cause and start chatting\nwith charities directly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: KindoraColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conversation List Tile
// ---------------------------------------------------------------------------

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.conversation});

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = conversation.unreadCount > 0;

    return Material(
      color: hasUnread ? KindoraColors.primarySurface : KindoraColors.surface,
      child: InkWell(
        onTap: () {
          ref.read(conversationsProvider.notifier).markAsRead(conversation.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(conversation: conversation),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent(hasUnread)),
              _buildTrailing(hasUnread),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: KindoraColors.primaryLight,
          backgroundImage: conversation.participantAvatarUrl != null
              ? NetworkImage(conversation.participantAvatarUrl!)
              : null,
          child: conversation.participantAvatarUrl == null
              ? Text(
                  (conversation.participantName.isNotEmpty)
                      ? conversation.participantName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                )
              : null,
        ),
        if (conversation.isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: KindoraColors.online,
                shape: BoxShape.circle,
                border: Border.all(color: KindoraColors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(bool hasUnread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (conversation.isCharity)
              Container(
                margin: const EdgeInsets.only(right: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: KindoraColors.accentLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Charity',
                  style: TextStyle(
                    color: KindoraColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                conversation.participantName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: KindoraColors.textPrimary,
                  fontWeight:
                      hasUnread ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),

        if (conversation.campaignTitle != null) ...[
          const SizedBox(height: 2),
          Text(
            '📌 ${conversation.campaignTitle}',
            style: const TextStyle(
                color: KindoraColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 4),
        Text(
          conversation.lastMessage?.content ?? 'No messages yet',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: hasUnread
                ? KindoraColors.textPrimary
                : KindoraColors.textSecondary,
            fontSize: 13,
            fontWeight:
                hasUnread ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing(bool hasUnread) {
    final ts = conversation.lastMessage?.timestamp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ts != null ? _formatTime(ts) : '',
          style: TextStyle(
            color: hasUnread
                ? KindoraColors.primary
                : KindoraColors.textHint,
            fontSize: 11,
            fontWeight:
                hasUnread ? FontWeight.w600 : FontWeight.w400,
          ),
        ),

        const SizedBox(height: 6),
        hasUnread
          ?Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: KindoraColors.unreadBadge,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
          )
          :
            _buildMessageStatusIcon(),
      ],
    );  
  }

  Widget _buildMessageStatusIcon() {
    final status = conversation.lastMessage?.status;
    final isMine =
        conversation.lastMessage?.senderId == 'current_user';
    if (!isMine || status == null) return const SizedBox(width: 20, height: 20);
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time_rounded,
            size: 14, color: KindoraColors.textHint);
      case MessageStatus.sent:
        return const Icon(Icons.check_rounded,
            size: 14, color: KindoraColors.textHint);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all_rounded,
            size: 14, color: KindoraColors.textHint);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded,
            size: 14, color: KindoraColors.primary);
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return DateFormat('h:mm a').format(dt);
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('d MMM').format(dt);
  }
}











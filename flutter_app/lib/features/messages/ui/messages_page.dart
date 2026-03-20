import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'direct_chat_page.dart';
import '../services/direct_message_service.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final DirectMessageService _messageService = DirectMessageService();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatRecent(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.messages),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0C0C79),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: Future.wait([
            _messageService.getCurrentUserContext(),
            _messageService.getConversationPreviews(),
          ]).then((values) => {
                'me': values[0] as UserContext,
                'conversations': values[1] as List<ConversationPreview>,
              }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0C0C79)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '${l10n.failedToLoadMessages}: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final me = snapshot.data!['me'] as UserContext;
            final conversations =
                snapshot.data!['conversations'] as List<ConversationPreview>;

            if (conversations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Text(
                      l10n.noMessagesYetStartConversation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }

            final searched = conversations.where((c) {
              final q = _searchQuery.trim().toLowerCase();
              if (q.isEmpty) return true;
              return c.partnerName.toLowerCase().contains(q) ||
                  c.lastMessage.toLowerCase().contains(q);
            }).toList();

            final filtered = searched.where((c) {
              if (_selectedFilter == 'all') return true;
              final replied = c.lastMessageSenderId == me.userId;
              return _selectedFilter == 'replied' ? replied : !replied;
            }).toList();
            filtered.sort((a, b) {
              final unreadCompare = b.unreadCount.compareTo(a.unreadCount);
              if (unreadCompare != 0) return unreadCompare;
              return b.lastMessageAt.compareTo(a.lastMessageAt);
            });

            final recentActive = List<ConversationPreview>.from(conversations)
              ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search conversations',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Replied', 'replied'),
                      const SizedBox(width: 8),
                      _buildFilterChip("Haven't replied", 'not_replied'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Recently active',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 78,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentActive.length > 8 ? 8 : recentActive.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final c = recentActive[index];
                        final title =
                            c.partnerName.isEmpty ? l10n.user : c.partnerName;
                        final safeTitle = title.trim();
                        final avatarText =
                            safeTitle.isEmpty ? 'U' : safeTitle[0].toUpperCase();

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DirectChatPage(
                                  receiverId: c.partnerId,
                                  receiverName: title,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: const Color(0xFF0C0C79),
                                    child: Text(
                                      avatarText,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  if (c.unreadCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            c.unreadCount > 9
                                                ? '9+'
                                                : '${c.unreadCount}',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatRecent(c.lastMessageAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No conversations for selected filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blueGrey.shade600),
                      ),
                    ),
                  ...filtered.map((c) {
                    final title = c.partnerName.isEmpty ? l10n.user : c.partnerName;
                    final safeTitle = title.trim();
                    final avatarText =
                        safeTitle.isEmpty ? 'U' : safeTitle[0].toUpperCase();
                    final replied = c.lastMessageSenderId == me.userId;
                    final hasUnread = c.unreadCount > 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          radius: 23,
                          backgroundColor: const Color(0xFF0C0C79),
                          child: Text(
                            avatarText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              _formatTime(c.lastMessageAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey.shade500,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: hasUnread
                                      ? const Color(0xFFE3F2FD)
                                      : (replied
                                          ? const Color(0xFFE8F5E9)
                                          : const Color(0xFFFFF3E0)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  hasUnread
                                      ? 'Unread ${c.unreadCount > 99 ? '99+' : c.unreadCount}'
                                      : (replied ? 'Replied' : "Haven't replied"),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: hasUnread
                                        ? const Color(0xFF1565C0)
                                        : (replied
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFFEF6C00)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DirectChatPage(
                                receiverId: c.partnerId,
                                receiverName: title,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: const Color(0xFF0C0C79).withOpacity(0.12),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF0C0C79) : Colors.blueGrey.shade700,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF0C0C79).withOpacity(0.3)
            : Colors.blueGrey.shade200,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
    );
  }
}

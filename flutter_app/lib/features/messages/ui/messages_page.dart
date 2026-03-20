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

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.messages),
        backgroundColor: const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<List<ConversationPreview>>(
          future: _messageService.getConversationPreviews(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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

            final conversations = snapshot.data ?? [];
            if (conversations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.noMessagesYetStartConversation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final c = conversations[index];
                  final title = c.partnerName.isEmpty ? l10n.user : c.partnerName;
                  final avatarText = title.substring(0, 1).toUpperCase();
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0C0C79),
                      child: Text(
                        avatarText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      c.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(_formatTime(c.lastMessageAt)),
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
                  );
                },
                physics: const AlwaysScrollableScrollPhysics(),
              ),
            );
          },
        ),
      ),
    );
  }
}

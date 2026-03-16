import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ChatScreen extends StatefulWidget {
  final String name;

  const ChatScreen({super.key, required this.name});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late final RealtimeChannel channel;

  Future loadMessages() async {

  final data = await supabase
      .from('messages')
      .select()
      .order('created_at');

  setState(() {
    messages = List<Map<String, dynamic>>.from(data);
  });
  Future.delayed(const Duration(milliseconds: 100), () {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  });

}

@override
void initState() {
  super.initState();
  loadMessages();

  channel = supabase.channel ('message_channel')
    ..onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload){
        loadMessages();
      }
   )
    ..subscribe();

}

  final supabase = Supabase.instance.client;

List<Map<String, dynamic>> messages = [];



void sendMessage() async {
  final text = controller.text.trim();
  if (text.isEmpty) return;

  await supabase.from('messages').insert({
    "content": text,
    "sender_id": "0e29b-41d4-a716-44665544000",
    "receiver_id": "0e29b-41d4-a716-44665544001",
  });

  controller.clear();
}

@override
void dispose() {
  supabase.removeChannel(channel);
  controller.dispose();
  super.dispose();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.indigo,
              child: Icon(Icons.volunteer_activism, color: Colors.white),
              
              
            ),
            const SizedBox(width: 10),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // CHAT MESSAGES
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              itemBuilder:(context, index) {
                final msg = messages[index];

                final isMe = msg["sender_id"] == "0e29b-41d4-a716-44665544000";

                return MessageBubble(
                  message: msg["content"],
                  isMe: isMe,
                  time: msg["created_at"].toString(),
                );
              }
            ),
          ),

          // INPUT BAR
          MessageInputBar(
            controller: controller,
            onSend: sendMessage,
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.indigo
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isMe)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe
                    ? Colors.white70
                    : Colors.black45,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });
  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
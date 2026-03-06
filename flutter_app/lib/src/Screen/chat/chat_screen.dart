import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String name;

  const ChatScreen({super.key, required this.name});

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
              name,
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                MessageBubble(
                  message: "Hello! Thank you for supporting our campaign.",
                  isMe: false,
                ),
                MessageBubble(
                  message: "Happy to help! Keep up the great work.",
                  isMe: true,
                ),
                MessageBubble(
                  message: "We truly appreciate your generosity.",
                  isMe: false,
                ),
              ],
            ),
          ),

          // INPUT BAR
          const MessageInputBar(),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
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
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class MessageInputBar extends StatelessWidget {
  const MessageInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Expanded(
            child: TextField(
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
              onPressed: () {},
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
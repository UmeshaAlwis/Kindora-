import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String name;

  const ChatScreen({super.key, required this.name});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

List<Map<String, dynamic>> messages = [
  {"text": "Hello! Thank you for supporting our campaign.", "isMe": false, "time": "5m ago"},
  {"text": "Happy to help! Keep up the great work.", "isMe": true, "time": "4m ago"},
  {"text": "We truly appreciate your generosity.", "isMe": false, "time": "3m ago"},
  {"text": "It's our pleasure! Let us know if there are other ways we can assist.", "isMe": true, "time": "2m ago"},
  {"text": "Will do! Thanks again for your support.", "isMe": false, "time": "1m ago"},
  {"text": "You're very welcome! We're here to help anytime.", "isMe": true, "time": "Just now"},
  {"text": "We truly appreciate your generosity.", "isMe": false, "time": "10:20 AM"},
];


final TextEditingController controller = TextEditingController();


void sendMessage() {
  if (controller.text.trim().isEmpty) return;

  setState(() {
    messages.add({
      "text": controller.text,
      "isMe": true,
    });
  });

  controller.clear();
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: messages
                  .map((msg) => MessageBubble(
                        message: msg["text"],
                        isMe: msg["isMe"],
                        time: msg["time"],
                      ))
                  .toList(),
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
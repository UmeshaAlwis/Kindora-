import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            for (int i = 0; i < 5; i++)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF0C0C79),
                  child: Text(
                    'U$i',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('Contact ${i + 1}'),
                subtitle: const Text('No messages yet...'),
                trailing: const Text('Now'),
                onTap: () {},
              ),
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mail,
                      size: 64,
                      color: Color(0xFF0C0C79),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Messaging System Coming Soon',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C0C79),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF751F),
        child: const Icon(Icons.message),
        onPressed: () {},
      ),
    );
  }
}

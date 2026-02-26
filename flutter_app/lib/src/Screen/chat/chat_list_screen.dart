import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(),
            Expanded(child: _buildChatList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Messages",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search here",
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.search, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  // CATEGORY CHIPS
  Widget _buildCategoryChips() {
    final categories = [
      "All",
      "Animals",
      "Children",
      "Education",
      "Health"
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = index == 0;
            return Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigo : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // CHAT LIST
  Widget _buildChatList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: const [
        _ChatTile(
          name: "Caritas Sri Lanka - SEDEC",
          message: "That's a wonderful news! Happy to support",
          time: "5m ago",
          unread: 2,
        ),
        _ChatTile(
          name: "Sri Lankan Red Cross",
          message: "Thank you for your recent donation",
          time: "1h ago",
          unread: 1,
        ),
      ],
    );
  }

  // BOTTOM NAVIGATION
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: Colors.indigo,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: "Feed"),
        BottomNavigationBarItem(icon: Icon(Icons.send), label: "Messages"),
        BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Merch"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final int unread;

  const _ChatTile({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(name:name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(Icons.favorite, color: Colors.red),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(time,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'news_feed_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 1; // Default to Feed tab

  final List<Widget> _pages = [
    const Center(child: Text("Home Page")),
    const FeedScreen(), // Your high-fidelity feed
    const Center(child: Text("Messages Page")),
    const Center(child: Text("Merch Store")),
    const Center(child: Text("Profile Page")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0C0C79),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.rss), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.messageSquare), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.heart), label: 'Merch'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}
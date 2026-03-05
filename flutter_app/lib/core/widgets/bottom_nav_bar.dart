import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0C0C79),
      unselectedItemColor: Colors.grey,

      onTap: onTap,

      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.rss_feed_outlined),
          activeIcon: Icon(Icons.rss_feed),
          label: "Feed",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.send_outlined),
          activeIcon: Icon(Icons.send),
          label: "Messages",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.monitor_heart_outlined),
          activeIcon: Icon(Icons.favorite),
          label: "Merch",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profile",
        ),

      ],
    );
  }
}
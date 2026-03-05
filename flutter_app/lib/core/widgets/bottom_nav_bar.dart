import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

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
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xFF0C0C79),
        unselectedItemColor: Colors.grey,

        elevation: 0,
        enableFeedback: false,

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
            icon: Icon(FeatherIcons.heart),
            activeIcon: Icon(FeatherIcons.heart),
            label: "Merch",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
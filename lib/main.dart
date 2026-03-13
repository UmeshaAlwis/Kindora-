import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'screens/news_feed_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/rewards_screen.dart';

void main() {
  runApp(const KindoraApp());
}

class KindoraApp extends StatelessWidget {
  const KindoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kindora',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1A1A40),
      ),
      home: const MainParent(),
    );
  }
}

class MainParent extends StatefulWidget {
  const MainParent({super.key});

  @override
  State<MainParent> createState() => _MainParentState();
}

class _MainParentState extends State<MainParent> {
  int _selectedIndex = 1; // Default to 'Feed' tab

  // REMOVED 'const' from this list to prevent LucideIcon crashes
  final List<Widget> _screens = [
    const RecommendationScreen(),
    const FeedScreen(),
    const RewardsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The IndexedStack keeps the state of your screens alive when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF1A1A40),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.sparkles),
            label: 'AI Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layout),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.trophy),
            label: 'Rewards',
          ),
        ],
      ),
    );
  }
}
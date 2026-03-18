import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added Supabase
import 'package:lucide_icons/lucide_icons.dart';
import 'screens/news_feed_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/rewards_screen.dart';

Future<void> main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Supabase with your dashboard credentials
  await Supabase.initialize(
    // REPLACE these strings with the values from your Supabase screenshot
    url: 'https://your-project-id.supabase.co',
    anonKey: 'your-anon-public-key-here',
  );

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
        // Adding a global color scheme for consistency
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A1A40)),
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
  int _selectedIndex = 1; // Default to 'Feed' (Center Tab)

  // This list holds the actual screens for navigation
  final List<Widget> _screens = [
    const RecommendationScreen(),
    const NewsFeedScreen(), // Changed FeedScreen to NewsFeedScreen to match your backend setup
    const RewardsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves the state (scroll position, etc.) of each tab
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
        items: const [
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
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Screens - Ensure these class names match your files exactly
import 'screens/news_feed_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/rewards_screen.dart';

Future<void> main() async {
  // 1. Required for Flutter to handle async Supabase initialization
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Supabase with your actual project credentials
  await Supabase.initialize(
    url: 'https://ucxqakixdpqqmbbpeptm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjeHFha2l4ZHBxcW1iYnBlcHRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1MzY1NDcsImV4cCI6MjA4NjExMjU0N30.lqbexF_zdeKXtcwpG-Ou0rw1IaBhYsMIgWa2yHfxDBY',
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A40),
          primary: const Color(0xFF1A1A40),
          secondary: const Color(0xFF4CAF50), // Kindora Green
        ),
        fontFamily: 'Roboto',
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
  // We start at index 1 (News Feed) to see your backend progress immediately
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const RecommendationScreen(),
    const NewsFeedScreen(),
    const RewardsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps the state of your screens alive when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
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
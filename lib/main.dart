import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Ensure these paths match your actual folder structure in Android Studio
import 'screens/news_feed_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/rewards_screen.dart';

Future<void> main() async {
  // 1. Mandatory for async initializations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Supabase
  // 💡 Tip: Keep these keys safe. If you haven't replaced them, the app will
  // load but won't fetch data.
  await Supabase.initialize(
    url: 'https://your-project-url.supabase.co',
    anonKey: 'your-anon-key-here',
  );

  runApp(const KindoraApp());
}

class KindoraApp extends StatelessWidget {
  const KindoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kindoraBlue = Color(0xFF0C0C79); // Matches your Feed Screen

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kindora',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: kindoraBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kindoraBlue,
          primary: kindoraBlue,
        ),
        // Ensures your AppBar and BottomNav use consistent fonts
        fontFamily: 'Poppins',
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
  // We start at index 1 (NewsFeedScreen) as the home tab
  int _selectedIndex = 1;

  // List of screens connected to the Bottom Navigation Bar
  final List<Widget> _screens = [
    const RecommendationScreen(),
    const NewsFeedScreen(),
    const RewardsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack is great because it doesn't "reset" the screen
      // when you switch tabs.
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
        selectedItemColor: const Color(0xFF0C0C79),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        backgroundColor: Colors.white,
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
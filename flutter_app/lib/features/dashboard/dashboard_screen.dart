import 'package:flutter/material.dart';
import 'dashboard_home.dart';
import '../profile/profile_page.dart';
import '../../core/widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardHome(),   // Home
    Placeholder(),     // Feed
    Placeholder(),     // Messages
    Placeholder(),     // Merch
    ProfilePage(),     // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
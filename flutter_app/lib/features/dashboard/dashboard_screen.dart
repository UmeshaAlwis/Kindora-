import 'package:flutter/material.dart';
import 'package:kindora/features/home/ui/home_screen.dart';
import 'package:kindora/features/profile/ui/profile_page.dart';
import 'package:kindora/core/widgets/app_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    Center(child: Text("Feed coming soon")),
    Center(child: Text("Messages coming soon")),
    Center(child: Text("Merch coming soon")),
    ProfilePage(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:kindora/features/home/ui/home_screen.dart';
import 'package:kindora/features/profile/ui/profile_page.dart';
import 'package:kindora/core/widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const HomeScreen(),
      const Center(child: Text("Feed coming soon")),
      const Center(child: Text("Messages coming soon")),
      const Center(child: Text("Merch coming soon")),
      const ProfilePage(),
    ];
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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
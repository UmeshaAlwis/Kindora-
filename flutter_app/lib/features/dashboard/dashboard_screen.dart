import 'package:flutter/material.dart';
import 'dashboard_home.dart';
import '../profile/profile_page.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../campaign_home_page.dart';
import '../../src/features/payment/presentation/pages/charity_list_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardHome(),   // Home
    CampaignHomePage(),     // Campaigns
    CharityListPage(), // Charities/Donations
    Center(child: Text("Messages coming soon")), // Messages
    ProfilePage(),     // Profile
  ];

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
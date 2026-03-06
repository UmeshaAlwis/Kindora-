import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../src/features/profile/screens/profile_screen.dart';
import '../../src/features/profile/models/profile_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFF0C0C79),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: const ProfileScreen(),
      ),
    );
  }
}
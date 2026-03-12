import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../settings/settings_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final supabase = Supabase.instance.client;

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    /// Redirect to login
    context.go('/login');
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    return data;
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    const primaryColor = Color(0xFF0C0C79);

    /// If user not logged in → redirect
    if (user == null) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox();
    }

    return Scaffold(

      /// APP BAR
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),

      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: getProfile(user.uid),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Failed to load profile"));
            }

            final profile = snapshot.data;

            final name = profile?['name'] ?? "User";
            final email = user.email ?? "";

            final firstLetter =
                name.isNotEmpty ? name[0].toUpperCase() : "?";

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              children: [

                /// PROFILE IMAGE
                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: primaryColor,
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontSize: 34,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// NAME
                Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                /// EMAIL
                Center(
                  child: Text(
                    email,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    "Active Donor Since 2024",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 14),

                /// VERIFIED BADGE
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Verified Humanitarian",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                /// STATS
                Row(
                  children: [

                    Expanded(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Text(
                                "LKR 45K",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text("Total Donated"),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Text(
                                "23",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text("Campaigns Supported"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                /// ACHIEVEMENTS
                const Text(
                  "Achievements",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _badge(Icons.emoji_events, "Top Donor", Colors.orange),
                    _badge(Icons.local_fire_department, "Streak Week", Colors.blueGrey),
                    _badge(Icons.eco, "Eco Warrior", Colors.green),
                  ],
                ),

                const SizedBox(height: 35),

                /// EDIT PROFILE
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    context.push('/edit-profile');
                  },
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 16),

                /// LOGOUT
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  onPressed: logout,
                ),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _badge(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
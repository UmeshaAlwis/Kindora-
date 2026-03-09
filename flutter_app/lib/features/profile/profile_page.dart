import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../settings/settings_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final supabase = Supabase.instance.client;

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
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

    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: getProfile(user.uid),
        builder: (context, snapshot) {

          /// Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// Error
          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load profile"));
          }

          final profile = snapshot.data;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              /// SETTINGS ICON
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),

              /// PROFILE IMAGE
              Stack(
                alignment: Alignment.center,
                children: [

                  const CircleAvatar(
                    radius: 55,
                    child: Icon(Icons.person, size: 45),
                  ),

                  Positioned(
                    bottom: 0,
                    right: MediaQuery.of(context).size.width / 2 - 60,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: primaryColor,
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// NAME
              Center(
                child: Text(
                  profile?['name'] ?? "User",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              /// DONOR STATUS
              const Center(
                child: Text(
                  "Active Donor Since 2024",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 10),

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

              const SizedBox(height: 30),

              /// STATS CARDS
              Row(
                children: [

                  Expanded(
                    child: Card(
                      elevation: 2,
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
                      elevation: 2,
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

              const SizedBox(height: 30),

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

                  _badge(Icons.local_fire_department,
                      "Streak Week", Colors.blueGrey),

                  _badge(Icons.eco, "Eco Warrior", Colors.green),
                ],
              ),

              const SizedBox(height: 30),

              /// EDIT PROFILE BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  );
                },
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              /// LOGOUT
              OutlinedButton(
                onPressed: logout,
                child: const Text("Logout"),
              ),
            ],
          );
        },
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
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../settings/settings_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    const primaryColor = Color(0xFF0C0C79);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// PROFILE HEADER
          Column(
            children: [
              const CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 40),
              ),

              const SizedBox(height: 12),

              Text(
                user?.email ?? "No email",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                user?.emailVerified == true
                    ? "Email Verified ✓"
                    : "Email Not Verified",
                style: TextStyle(
                  color: user?.emailVerified == true
                      ? Colors.green
                      : Colors.red,
                ),
              ),

              const SizedBox(height: 16),

              /// EDIT PROFILE BUTTON
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
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
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// SETTINGS CARD
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [

                /// SETTINGS
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                /// LOGOUT
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
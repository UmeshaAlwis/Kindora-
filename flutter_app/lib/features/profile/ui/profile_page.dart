import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kindora/l10n/app_localizations.dart';

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

    context.go('/login');
  }

  /// GET PROFILE FROM SUPABASE
  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      return data;
    } catch (e) {
      debugPrint("Supabase profile error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    const primaryColor = Color(0xFF0C0C79);

    final t = AppLocalizations.of(context)!;

    /// If user not logged in
    if (user == null) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox();
    }

    return Scaffold(

      /// APP BAR
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t.profile),
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
<<<<<<< HEAD

      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: getProfile(user.uid),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              debugPrint("Profile error: ${snapshot.error}");
            }

            final profile = snapshot.data;

            /// SAFE FALLBACK
            final t = AppLocalizations.of(context)!;
            final name = profile?['name'] ?? t.user;
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

                Center(
                  child: Text(
                    t.activeDonorSince,
                    style: const TextStyle(color: Colors.grey),
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
                    child: Text(
                      t.verifiedHumanitarian,
                      style: const TextStyle(
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
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Text(
                                "LKR 45K",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(t.totalDonated),
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
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Text(
                                "23",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(t.campaignsSupported),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                  child: Text(
                    t.editProfile,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 16),

                /// LOGOUT
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(t.logout),
                  onPressed: logout,
                ),

                const SizedBox(height: 40),
              ],
            );
          },
=======
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                /// PROFILE SECTION
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF0C0C79),
                  child: Text(
                    user?.displayName?[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),

                /// APP SETTINGS SECTION
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C0C79),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                /// LOGOUT BUTTON
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
>>>>>>> origin/main
        ),
      ),
    );
  }
}
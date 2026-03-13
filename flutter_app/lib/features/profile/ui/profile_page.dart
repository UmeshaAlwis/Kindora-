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

  static const primaryColor = Color(0xFF0C0C79);

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
    final t = AppLocalizations.of(context)!;

    if (user == null) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox();
    }

    return Scaffold(

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

      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: getProfile(user.uid),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = snapshot.data;

            final name = profile?['name'] ?? t.user;
            final email = user.email ?? "";
            final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "?";

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              children: [

                /// PROFILE IMAGE + NAME
                Column(
                  children: [

                    Stack(
                      children: [

                        CircleAvatar(
                          radius: 50,
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

                        /// EDIT ICON
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              context.push('/edit-profile');
                            },
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      t.activeDonorSince,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    Container(
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
                  ],
                ),

                const SizedBox(height: 28),

                /// STATS
                Row(
                  children: [

                    Expanded(
                      child: _statCard(
                        icon: Icons.volunteer_activism,
                        iconColor: Colors.green,
                        value: "LKR 45K",
                        label: t.totalDonated,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: _statCard(
                        icon: Icons.campaign,
                        iconColor: Colors.blue,
                        value: "23",
                        label: t.campaignsSupported,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// ACHIEVEMENTS TITLE
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    "Achievements",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// BADGES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    _badge(
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                      label: "Top Donor",
                    ),

                    _badge(
                      icon: Icons.local_fire_department,
                      color: Colors.blueGrey,
                      label: "Streak Week",
                    ),

                    _badge(
                      icon: Icons.park,
                      color: Colors.green,
                      label: "Eco Warrior",
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                /// FILLED LOGOUT BUTTON
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.logout,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      t.logout,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: logout,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  /// STAT CARD
  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [

            CircleAvatar(
              radius: 16,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, size: 18, color: iconColor),
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(label),
          ],
        ),
      ),
    );
  }

  /// BADGE
  Widget _badge({
    required IconData icon,
    required Color color,
    required String label,
  }) {

    return Column(
      children: [

        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),

        const SizedBox(height: 6),

        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
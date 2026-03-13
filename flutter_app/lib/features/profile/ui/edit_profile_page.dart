import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final nameController = TextEditingController();
  final bioController = TextEditingController();

  final supabase = Supabase.instance.client;

  bool isLoading = false;
  bool notificationsEnabled = true;

  String language = "en";
  String role = "donor";

  static const primaryColor = Color(0xFF0C0C79);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// LOAD PROFILE FROM SUPABASE
  Future<void> loadProfile() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.uid)
          .maybeSingle();

      if (data != null) {

        nameController.text = data['name'] ?? "";
        bioController.text = data['bio'] ?? "";

        notificationsEnabled = data['notifications_enabled'] ?? true;
        language = data['language'] ?? "en";
        role = data['role'] ?? "donor";

        setState(() {});
      }

    } catch (e) {
      debugPrint("Profile load error: $e");
    }
  }

  /// SAVE PROFILE
  Future<void> saveProfile() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {

      final existing = await supabase
          .from('profiles')
          .select()
          .eq('id', user.uid)
          .maybeSingle();

      if (existing != null) {

        /// UPDATE EXISTING PROFILE
        await supabase
            .from('profiles')
            .update({
              'name': nameController.text.trim(),
              'bio': bioController.text.trim(),
              'language': language,
              'notifications_enabled': notificationsEnabled,
              'role': role,
            })
            .eq('id', user.uid);

      } else {

        /// INSERT NEW PROFILE
        await supabase
            .from('profiles')
            .insert({
              'id': user.uid,
              'email': user.email,
              'name': nameController.text.trim(),
              'bio': bioController.text.trim(),
              'language': language,
              'notifications_enabled': notificationsEnabled,
              'role': role,
            });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();

    } catch (e) {

      debugPrint("Profile update error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update profile"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [

            /// PROFILE IMAGE
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 40),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: primaryColor,
                      child: const Icon(Icons.edit,size:16,color:Colors.white),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// EMAIL (READ ONLY)
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: user?.email ?? "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ROLE (DISPLAY ONLY)
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Account Type",
                hintText: role,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// NAME
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// BIO
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LANGUAGE SELECTOR
            DropdownButtonFormField<String>(
              value: language,
              decoration: InputDecoration(
                labelText: "Language",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [

                DropdownMenuItem(
                  value: "en",
                  child: Text("English"),
                ),

                DropdownMenuItem(
                  value: "si",
                  child: Text("සිංහල"),
                ),

                DropdownMenuItem(
                  value: "ta",
                  child: Text("தமிழ்"),
                ),

              ],
              onChanged: (value) {
                setState(() {
                  language = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            /// NOTIFICATIONS
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),

            const SizedBox(height: 25),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: isLoading ? null : saveProfile,

                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
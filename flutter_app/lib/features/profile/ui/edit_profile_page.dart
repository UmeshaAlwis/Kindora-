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

  static const primaryColor = Color(0xFF0C0C79);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// LOAD PROFILE DATA
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

    setState(() {
      isLoading = true;
    });

    try {

      await supabase
          .from('profiles')
          .update({
            'name': nameController.text.trim(),
            'bio': bioController.text.trim(),
          })
          .eq('id', user.uid);

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
      setState(() {
        isLoading = false;
      });
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
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 25),

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
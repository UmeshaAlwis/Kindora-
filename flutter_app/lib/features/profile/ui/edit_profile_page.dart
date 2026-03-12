import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final nameController = TextEditingController();
  final bioController = TextEditingController();

  final Color primaryColor = const Color(0xFF0C0C79);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// PROFILE IMAGE
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 20),

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

            const SizedBox(height: 24),

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

                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
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
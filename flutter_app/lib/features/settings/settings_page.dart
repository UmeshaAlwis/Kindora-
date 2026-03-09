import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  final Color primaryColor = const Color(0xFF0C0C79);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),

      body: ListView(
        children: [

          const SizedBox(height: 10),

          /// NOTIFICATIONS
          SwitchListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Receive campaign updates"),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),

          const Divider(),

          /// DARK MODE
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable dark theme"),
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() {
                darkModeEnabled = value;
              });
            },
          ),

          const Divider(),

          /// LANGUAGE
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            subtitle: const Text("English"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const Divider(),

          /// PRIVACY POLICY
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const Divider(),

          /// TERMS
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Terms & Conditions"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const Divider(),

          /// ABOUT
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About Kindora"),
            subtitle: const Text("Version 1.0.0"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const SizedBox(height: 20),

        ],
      ),
    );
  }
}
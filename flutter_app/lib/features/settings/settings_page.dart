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
        title: const Text("Settings"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [

          const SizedBox(height: 10),

          /// NOTIFICATIONS
          SwitchListTile(
            activeColor: primaryColor,
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
            activeColor: primaryColor,
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
            leading: Icon(Icons.language, color: primaryColor),
            title: const Text("Language"),
            subtitle: const Text("English"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const Divider(),

          /// PRIVACY POLICY
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: primaryColor),
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const Divider(),

          /// TERMS
          ListTile(
            leading: Icon(Icons.description_outlined, color: primaryColor),
            title: const Text("Terms & Conditions"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const Divider(),

          /// ABOUT
          ListTile(
            leading: Icon(Icons.info_outline, color: primaryColor),
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
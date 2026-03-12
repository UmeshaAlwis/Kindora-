import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool notificationsEnabled = true;
  final Color primaryColor = const Color(0xFF0C0C79);

  @override
  Widget build(BuildContext context) {

    final themeController = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [

            const SizedBox(height: 20),

            /// GENERAL SETTINGS
            Text(
              "General",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// NOTIFICATIONS
            SwitchListTile(
              activeThumbColor: primaryColor,
              activeTrackColor: primaryColor.withOpacity(0.4),
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
              activeThumbColor: primaryColor,
              activeTrackColor: primaryColor.withOpacity(0.4),
              title: const Text("Dark Mode"),
              subtitle: const Text("Enable dark theme"),
              value: themeController.isDarkMode,
              onChanged: (value) {
                context.read<ThemeController>().toggleTheme(value);
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

            const SizedBox(height: 25),

            /// LEGAL
            Text(
              "Legal",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

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

            const SizedBox(height: 25),

            /// ABOUT
            Text(
              "About",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ListTile(
              leading: Icon(Icons.info_outline, color: primaryColor),
              title: const Text("About Kindora"),
              subtitle: const Text("Version 1.0.0"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
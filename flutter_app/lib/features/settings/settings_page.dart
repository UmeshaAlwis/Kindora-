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

  static const Color primaryColor = Color(0xFF0C0C79);

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

            /// GENERAL
            _sectionTitle(context, "General"),

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
              leading: const Icon(Icons.language),
              title: const Text("Language"),
              subtitle: const Text("English"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Language selection coming soon"),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            /// LEGAL
            _sectionTitle(context, "Legal"),

            const SizedBox(height: 10),

            /// PRIVACY POLICY
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text("Privacy Policy"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Privacy policy page coming soon"),
                  ),
                );
              },
            ),

            const Divider(),

            /// TERMS
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text("Terms & Conditions"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Terms & Conditions page coming soon"),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            /// ABOUT
            _sectionTitle(context, "About"),

            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Kindora"),
              subtitle: const Text("Version 1.0.0"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Kindora",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2026 Kindora Team",
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// SECTION TITLE WIDGET
  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
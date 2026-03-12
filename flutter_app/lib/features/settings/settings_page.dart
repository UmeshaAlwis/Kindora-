import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kindora/l10n/app_localizations.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../core/language/language_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool notificationsEnabled = true;

  final supabase = Supabase.instance.client;

  static const Color primaryColor = Color(0xFF0C0C79);

  @override
  void initState() {
    super.initState();
    loadNotificationSetting();
  }

  /// LOAD NOTIFICATION SETTING FROM SUPABASE
  Future<void> loadNotificationSetting() async {

    try {

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final data = await supabase
          .from('profiles')
          .select('notifications_enabled')
          .eq('id', user.uid)
          .maybeSingle();

      if (data != null) {
        setState(() {
          notificationsEnabled = data['notifications_enabled'] ?? true;
        });
      }

    } catch (e) {
      debugPrint("Notification load error: $e");
    }
  }

  /// SAVE NOTIFICATION SETTING
  Future<void> updateNotificationSetting(bool value) async {

    try {

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await supabase
          .from('profiles')
          .update({
            'notifications_enabled': value,
          })
          .eq('id', user.uid);

    } catch (e) {
      debugPrint("Notification save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    final themeController = context.watch<ThemeController>();
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(t.settings),
        centerTitle: true,
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          children: [

            const SizedBox(height: 20),

            /// GENERAL
            _sectionTitle(context, t.general),

            const SizedBox(height: 10),

            /// NOTIFICATIONS
            SwitchListTile(
              activeThumbColor: primaryColor,
              activeTrackColor: primaryColor.withOpacity(0.4),
              title: Text(t.notifications),
              subtitle: Text(t.receiveCampaignUpdates),
              value: notificationsEnabled,
              onChanged: (value) async {

                setState(() {
                  notificationsEnabled = value;
                });

                await updateNotificationSetting(value);
              },
            ),

            const Divider(),

            /// DARK MODE
            SwitchListTile(
              activeThumbColor: primaryColor,
              activeTrackColor: primaryColor.withOpacity(0.4),
              title: Text(t.darkMode),
              subtitle: Text(t.enableDarkTheme),
              value: themeController.isDarkMode,
              onChanged: (value) {
                context.read<ThemeController>().toggleTheme(value);
              },
            ),

            const Divider(),

            /// LANGUAGE
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(t.language),
              subtitle: Text(_currentLanguage(context)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {

                showModalBottomSheet(
                  context: context,
                  builder: (context) {

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        ListTile(
                          title: const Text("English"),
                          onTap: () {
                            context.read<LanguageController>().changeLanguage('en');
                            Navigator.pop(context);
                          },
                        ),

                        ListTile(
                          title: const Text("සිංහල"),
                          onTap: () {
                            context.read<LanguageController>().changeLanguage('si');
                            Navigator.pop(context);
                          },
                        ),

                        ListTile(
                          title: const Text("தமிழ்"),
                          onTap: () {
                            context.read<LanguageController>().changeLanguage('ta');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 25),

            /// SECURITY
            _sectionTitle(context, t.security),

            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(t.changePassword),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(t.deleteAccount),
            ),

            const SizedBox(height: 25),

            /// LEGAL
            _sectionTitle(context, t.legal),

            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(t.privacyPolicy),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(t.termsConditions),
            ),

            const SizedBox(height: 25),

            /// ABOUT
            _sectionTitle(context, t.about),

            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(t.aboutKindora),
              subtitle: const Text("Version 1.0.0"),
            ),

            const SizedBox(height: 20),

            /// LOGOUT
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(t.logout),
              onTap: () async {

                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                context.go('/login');
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  /// CURRENT LANGUAGE LABEL
  String _currentLanguage(BuildContext context) {

    final locale =
        context.watch<LanguageController>().locale.languageCode;

    switch (locale) {
      case 'si':
        return "සිංහල";
      case 'ta':
        return "தமிழ்";
      default:
        return "English";
    }
  }
}
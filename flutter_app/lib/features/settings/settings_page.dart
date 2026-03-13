import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kindora/l10n/app_localizations.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../core/language/language_controller.dart';

import 'ui/privacy_policy_page.dart';
import 'ui/terms_conditions_page.dart';

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

      if (data != null && mounted) {
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
          .update({'notifications_enabled': value})
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
            _settingsTile(
              icon: Icons.language,
              title: t.language,
              subtitle: _currentLanguage(context),
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

            _settingsTile(
              icon: Icons.lock_outline,
              title: t.changePassword,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),

            const Divider(),

            _settingsTile(
              icon: Icons.delete_forever,
              iconColor: Colors.red,
              title: t.deleteAccount,
              onTap: () async {

                final confirm = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(t.deleteAccount),
                      content: Text(t.deleteAccountConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(t.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            t.delete,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {

                  try {

                    final user = FirebaseAuth.instance.currentUser;
                    await user?.delete();

                    if (!mounted) return;

                    context.go('/login');

                  } catch (e) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please re-login before deleting account"),
                      ),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 25),

            /// LEGAL
            _sectionTitle(context, t.legal),
            const SizedBox(height: 10),

            _settingsTile(
              icon: Icons.privacy_tip_outlined,
              title: t.privacyPolicy,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyPage(),
                  ),
                );
              },
            ),

            const Divider(),

            _settingsTile(
              icon: Icons.description_outlined,
              title: t.termsConditions,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsConditionsPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            /// ABOUT
            _sectionTitle(context, t.about),
            const SizedBox(height: 10),

            _settingsTile(
              icon: Icons.info_outline,
              title: t.aboutKindora,
              subtitle: "Version 1.0.0",
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Kindora",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2026 Kindora Team",
                );
              },
            ),

            const SizedBox(height: 20),

            /// LOGOUT
            _settingsTile(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: t.logout,
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

  /// PASSWORD CHANGE DIALOG
  Future<void> _showChangePasswordDialog(BuildContext context) async {

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Current Password",
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () async {

                  if (user.email == null) return;

                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: user.email!,
                  );

                  if (!mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password reset email sent"),
                    ),
                  );
                },
                child: const Text("Forgot current password?"),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () async {

                if (currentPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill all fields"),
                    ),
                  );
                  return;
                }

                try {

                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPasswordController.text,
                  );

                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPasswordController.text);

                  if (!mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password updated successfully"),
                    ),
                  );

                } on FirebaseAuthException catch (e) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message ?? "Password update failed")),
                  );
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  /// REUSABLE SETTINGS TILE
  Widget _settingsTile({
    IconData? icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: iconColor) : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
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
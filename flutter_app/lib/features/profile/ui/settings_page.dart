import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/language_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    final notificationsEnabled = true;
    final selectedLanguageCode = currentLanguage.languageCode;
    final selectedLanguageName =
        languageNotifier.getLanguageName(selectedLanguageCode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// GENERAL SECTION
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'General',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildToggleTile(
                title: 'Notifications',
                subtitle: 'Receive campaign updates',
                value: notificationsEnabled,
                onChanged: (value) {
                  // TODO: Implement notification preferences
                },
              ),
              _buildDivider(),
              _buildToggleTile(
                title: 'Dark Mode',
                subtitle: 'Enable dark theme',
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleDarkMode(value);
                },
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: selectedLanguageName,
                onTap: () {
                  _showLanguageDialog(context, ref, selectedLanguageCode);
                },
                showArrow: true,
              ),
              const SizedBox(height: 32),

              /// SECURITY SECTION
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildActionTile(
                icon: Icons.lock,
                title: 'Change Password',
                subtitle: '',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Change Password - Coming Soon')),
                  );
                },
                showArrow: true,
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: '',
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
                showArrow: false,
                isDestructive: true,
              ),
              const SizedBox(height: 32),

              /// LEGAL SECTION
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Legal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildActionTile(
                icon: Icons.shield,
                title: 'Privacy Policy',
                subtitle: '',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Privacy Policy - Coming Soon')),
                  );
                },
                showArrow: true,
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.description,
                title: 'Terms & Conditions',
                subtitle: '',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Terms & Conditions - Coming Soon')),
                  );
                },
                showArrow: true,
              ),
              const SizedBox(height: 32),

              /// ABOUT SECTION
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0C0C79),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showArrow,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isDestructive ? Colors.red : Colors.grey.shade600,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? Colors.red : Colors.black,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey.shade300,
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, String currentLanguageCode) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                  'en', 'English', dialogContext, ref, currentLanguageCode),
              _buildLanguageOption(
                  'si', 'සිංහල', dialogContext, ref, currentLanguageCode),
              _buildLanguageOption(
                  'ta', 'தமிழ்', dialogContext, ref, currentLanguageCode),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String languageCode,
    String languageName,
    BuildContext dialogContext,
    WidgetRef ref,
    String currentLanguageCode,
  ) {
    return ListTile(
      title: Text(languageName),
      trailing: currentLanguageCode == languageCode
          ? const Icon(Icons.check, color: Color(0xFF0C0C79))
          : null,
      onTap: () {
        Navigator.pop(dialogContext);
        ref.read(languageProvider.notifier).changeLanguage(languageCode);
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(content: Text('Language changed to $languageName')),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                      content: Text('Account deletion - Coming Soon')),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

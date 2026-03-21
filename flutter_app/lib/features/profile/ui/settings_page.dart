import 'package:kindora/config/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../providers/theme_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../config/app_env.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _savingName = false;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;
      _nameController.text = (firebaseUser.displayName ?? '').trim();

      final token = await firebaseUser.getIdToken();
      final response = await http.get(
        Uri.parse('${AppEnv.apiBaseUrl}/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        final me = data['data'] as Map<String, dynamic>? ?? {};
        _role = (me['role'] ?? '').toString();
        _nameController.text = (me['full_name'] ?? '').toString();
      }
    } catch (_) {
      // Ignore load failures and keep settings usable.
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must be at least 2 characters')),
      );
      return;
    }

    setState(() {
      _savingName = true;
    });

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      final token = await firebaseUser.getIdToken();
      final response = await http.patch(
        Uri.parse('${AppEnv.apiBaseUrl}/users/me/name'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'full_name': name}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully')),
        );
      } else {
        throw Exception(data['error'] ?? 'Failed to update name');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update name: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingName = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = ref.watch(themeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    const notificationsEnabled = true;
    final selectedLanguageCode = currentLanguage.languageCode;
    final selectedLanguageName =
        languageNotifier.getLanguageName(selectedLanguageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
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
                  l10n.general,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildToggleTile(
                title: l10n.notifications,
                subtitle: l10n.receiveCampaignUpdates,
                value: notificationsEnabled,
                onChanged: (value) {
                  // TODO: Implement notification preferences
                },
              ),
              _buildDivider(),
              _buildToggleTile(
                title: l10n.darkMode,
                subtitle: l10n.enableDarkTheme,
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleDarkMode(value);
                },
              ),
              _buildDivider(),
              if (_role != 'beneficiary') ...[
                _buildActionTile(
                  icon: Icons.person_outline,
                  title: 'Display Name',
                  subtitle:
                      _nameController.text.trim().isEmpty ? 'Not set' : _nameController.text.trim(),
                  onTap: () {
                    _showNameDialog(context);
                  },
                  showArrow: true,
                ),
                _buildDivider(),
              ],
              _buildActionTile(
                icon: Icons.language,
                title: l10n.language,
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
                  l10n.security,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildActionTile(
                icon: Icons.lock,
                title: l10n.changePassword,
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
                title: l10n.deleteAccount,
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
                  l10n.legal,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildActionTile(
                icon: Icons.shield,
                title: l10n.privacyPolicy,
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
                title: l10n.termsConditions,
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
                  l10n.about,
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
                      l10n.version,
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

  void _showNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Set your name'),
          content: TextField(
            controller: _nameController,
            maxLength: 100,
            decoration: const InputDecoration(
              hintText: 'Enter your full name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _savingName
                  ? null
                  : () async {
                      await _saveName();
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        setState(() {});
                      }
                    },
              child: _savingName
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
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
            activeThumbColor: AppColors.primaryBlue,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.language),
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
              child: Text(l10n.cancel),
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
          ? const Icon(Icons.check, color: AppColors.primaryBlue)
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteAccount),
          content: Text(l10n.deleteAccountConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                      content: Text('Account deletion - Coming Soon')),
                );
              },
              child: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

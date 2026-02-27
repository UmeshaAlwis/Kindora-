import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_provider.dart';
import '../models/user_profile_model.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const ProfileScreen({
    Key? key,
    this.scrollController,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfileData();
    });
  }

  void _showExitAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final profile = provider.userProfile;
        final preferences = provider.preferences;

        if (provider.isLoading && profile == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF6B21A8),
              ),
            ),
          );
        }

        if (profile == null) {
          return EmptyProfileState(
            message: provider.error ?? 'Failed to load profile',
          );
        }

        return ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            ProfileHeader(
              profile: profile,
              onEditTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile coming soon'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Regular Donation Section
            RegularDonationCard(
              preferences: preferences,
              onChanged: (value) {
                final newPrefs = (preferences ?? const UserPreferences(
                  regularDonationEnabled: false,
                  donationReminderEnabled: true,
                  notificationsEnabled: true,
                )).copyWith(regularDonationEnabled: value);
                provider.updatePreferences(newPrefs);
              },
            ),
            const SizedBox(height: 16),
            // Donation Reminder Toggle
            ToggleMenuItem(
              icon: Icons.schedule,
              title: 'Donation reminder',
              value: preferences?.donationReminderEnabled ?? false,
              onChanged: (value) {
                final newPrefs = (preferences ?? const UserPreferences(
                  regularDonationEnabled: false,
                  donationReminderEnabled: true,
                  notificationsEnabled: true,
                )).copyWith(donationReminderEnabled: value);
                provider.updatePreferences(newPrefs);
              },
            ),
            // Donation Balance
            MenuItem(
              icon: Icons.account_balance_wallet,
              title: 'Donation balance',
              value: '\$${profile.totalDonations.toStringAsFixed(0)}',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/donation');
              },
            ),
            // Turn on Notification
            MenuItem(
              icon: Icons.notifications_outlined,
              title: 'Turn on notification',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications settings coming soon'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Settings
            MenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings coming soon'),
                  ),
                );
              },
            ),
            // FAQ & Chat Centre
            MenuItem(
              icon: Icons.help_outline,
              title: 'FAQ & Chat centre',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat Centre coming soon'),
                  ),
                );
              },
            ),
            // About the app
            MenuItem(
              icon: Icons.info_outlined,
              title: 'About the app',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('About App coming soon'),
                  ),
                );
              },
            ),
            // Give the rating
            MenuItem(
              icon: Icons.star_outline,
              title: 'Give the rating',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rate Us coming soon'),
                  ),
                );
              },
            ),
            // Terms & Condition
            MenuItem(
              icon: Icons.description_outlined,
              title: 'Terms & Condition',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms & Conditions coming soon'),
                  ),
                );
              },
            ),
            // Exit the app
            MenuItem(
              icon: Icons.logout,
              title: 'Exit the app',
              iconColor: Colors.red,
              showArrow: false,
              onTap: _showExitAppDialog,
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../profile/models/profile_provider.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserProfile();
    });
  }

  void _openProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ProfileScreen(scrollController: scrollController),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        title: const Text(
          'Kindora',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: _openProfile,
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  final profile = profileProvider.userProfile;
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6B21A8),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.purple[300],
                      backgroundImage: profile?.profileImageUrl != null
                          ? NetworkImage(profile!.profileImageUrl!)
                          : null,
                      child: profile?.profileImageUrl == null
                          ? Text(
                              profile?.firstName[0].toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  final profile = profileProvider.userProfile;
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6B21A8),
                          const Color(0xFF9333EA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile?.fullName ?? 'User',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Track your donations and manage your preferences',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Quick Stats Section
              Text(
                'Your Impact',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  final profile = profileProvider.userProfile;
                  return GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _StatTile(
                        label: 'Total Donated',
                        value:
                            '\$${profile?.totalDonations.toStringAsFixed(0) ?? "0"}',
                        icon: Icons.favorite,
                        color: Colors.red,
                      ),
                      _StatTile(
                        label: 'Campaigns',
                        value: profile?.totalCampaignsSupported.toString() ?? '0',
                        icon: Icons.campaign,
                        color: Colors.blue,
                      ),
                      _StatTile(
                        label: 'Kind Points',
                        value: profile?.kindPoints.toString() ?? '0',
                        icon: Icons.star,
                        color: Colors.amber,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              // Quick Actions Section
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.favorite_border,
                title: 'View Donations',
                subtitle: 'See your donation history',
                color: Colors.red,
                onTap: () {
                  Navigator.of(context).pushNamed('/donation');
                },
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.settings,
                title: 'Manage Preferences',
                subtitle: 'Update your settings',
                color: Colors.blue,
                onTap: _openProfile,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.help_outline,
                title: 'Need Help?',
                subtitle: 'Chat with our support team',
                color: Colors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat support coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kindora/config/themes/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../services/donor_badge_service.dart';
import '../services/donor_donation_history_service.dart';
import 'donation_history_list_tile.dart';
import 'donation_history_full_page.dart';

class _ProfileBundle {
  final DonorBadgeSummary summary;
  final List<DonationHistoryEntry> history;
  final int historyTotal;
  final String? historyError;

  const _ProfileBundle({
    required this.summary,
    required this.history,
    required this.historyTotal,
    this.historyError,
  });
}

/// Badge accents use only brand blue + orange (tints / depth variants).
({Color accent, Color accent2, Color surface}) _badgePalette(String badgeId) {
  switch (badgeId) {
    case 'first_gift':
      return (
        accent: AppColors.primaryOrange,
        accent2: Color.lerp(AppColors.primaryOrange, Colors.white, 0.35)!,
        surface: AppColors.orangeSurface,
      );
    case 'starter_supporter':
      return (
        accent: AppColors.primaryBlue,
        accent2: AppColors.blueDeep,
        surface: AppColors.blueSurface,
      );
    case 'golden_donor':
      return (
        accent: Color.lerp(AppColors.primaryOrange, AppColors.primaryBlue, 0.25)!,
        accent2: AppColors.primaryOrange,
        surface: AppColors.orangeSurface,
      );
    case 'three_campaign_backer':
      return (
        accent: AppColors.blueDeep,
        accent2: AppColors.primaryBlue,
        surface: AppColors.blueSurface,
      );
    case 'monthly_giver':
      return (
        accent: AppColors.primaryBlue,
        accent2: Color.lerp(AppColors.primaryBlue, AppColors.primaryOrange, 0.4)!,
        surface: AppColors.blueSurface,
      );
    case 'rapid_responder':
      return (
        accent: AppColors.primaryOrange,
        accent2: AppColors.primaryBlue,
        surface: AppColors.orangeSurface,
      );
    default:
      return (
        accent: AppColors.primaryBlue,
        accent2: AppColors.primaryOrange,
        surface: AppColors.scaffoldLight,
      );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DonorBadgeService _badgeService = DonorBadgeService();
  final DonorDonationHistoryService _historyService = DonorDonationHistoryService();
  late Future<_ProfileBundle> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<_ProfileBundle> _loadProfile() async {
    final summary = await _badgeService.getSummary();
    List<DonationHistoryEntry> history = [];
    int historyTotal = 0;
    String? historyError;
    try {
      final page = await _historyService.fetchHistoryPage(page: 1, limit: 3);
      history = page.items;
      historyTotal = page.total;
    } catch (e) {
      historyError = e.toString();
    }
    return _ProfileBundle(
      summary: summary,
      history: history,
      historyTotal: historyTotal,
      historyError: historyError,
    );
  }

  void _refresh() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  IconData _iconFromName(String icon) {
    switch (icon) {
      case 'redeem':
        return Icons.redeem;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'campaign':
        return Icons.campaign;
      case 'event_repeat':
        return Icons.event_repeat;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.verified;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/profile/settings');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<_ProfileBundle>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text(l10n.loading));
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final bundle = snapshot.data!;
            final summary = bundle.summary;
            final history = bundle.history;
            final historyTotal = bundle.historyTotal;
            final historyError = bundle.historyError;

            final unlocked = summary.badges.where((b) => b.unlocked).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primaryBlue,
                      child: Text(
                        (() {
                          final name = user?.displayName?.trim() ?? '';
                          if (name.isEmpty) return 'U';
                          return name[0].toUpperCase();
                        })(),
                        style: const TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      user?.displayName ?? l10n.user,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.activeDonorSince,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.orangeSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryOrange.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        l10n.verifiedHumanitarian,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.favorite,
                            value: 'LKR ${summary.totalDonated.toStringAsFixed(0)}',
                            label: l10n.totalDonated,
                            iconColor: AppColors.primaryOrange,
                            iconBg: AppColors.orangeSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.campaign,
                            value: '${summary.campaignsSupported}',
                            label: l10n.campaignsSupported,
                            iconColor: AppColors.primaryBlue,
                            iconBg: AppColors.blueSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Donation history',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (historyError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Could not load history: $historyError',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    if (history.isEmpty && historyError == null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No donations yet. Support a campaign to see your history here.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      )
                    else if (history.isNotEmpty) ...[
                      ...history.map(
                        (d) => DonationHistoryListTile(entry: d),
                      ),
                      if (historyError == null && historyTotal > 3)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => const DonationHistoryFullPage(),
                                ),
                              );
                            },
                            child: const Text('See more'),
                          ),
                        ),
                    ],
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.achievements,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (unlocked.isEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.noBadgesYet,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        alignment: WrapAlignment.start,
                        children: unlocked
                            .map(
                              (b) => _buildAchievementBadge(
                                badgeId: b.id,
                                icon: _iconFromName(b.icon),
                                title: b.name,
                                subtitle: b.description,
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge({
    required String badgeId,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final c = _badgePalette(badgeId);
    return Container(
      width: 168,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.surface,
            Colors.white,
          ],
        ),
        border: Border.all(color: c.accent.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: c.accent.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.accent, c.accent2],
              ),
              boxShadow: [
                BoxShadow(
                  color: c.accent.withOpacity(0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.2,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

import 'package:kindora/config/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindora/features/campaign/ui/start_campaign_page.dart';
import 'package:kindora/features/campaign/screens/campaign_details_screen.dart';
import 'package:kindora/features/wallet/ui/wallet_topup_page.dart';
import 'package:kindora/features/wallet/ui/wallet_transaction_history_page.dart';
import 'package:kindora/services/wallet_service.dart';
import 'package:kindora/repositories/supabase_repositories.dart';
import 'package:kindora/models/supabase_models.dart';
import 'package:kindora/l10n/app_localizations.dart';
import 'package:kindora/features/notifications/services/notification_service.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late WalletService _walletService;
  final NotificationService _notificationService = NotificationService();
  double _walletBalance = 0.0;
  bool _loadingWallet = true;
  bool _loadingUrgent = true;
  List<Campaign> _urgentCampaigns = [];

  int _unreadNotifications = 0;
  bool _loadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService();
    _fetchWalletBalance();
    _fetchUrgentCampaigns();
    _fetchUnreadNotifications();
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final balance = await _walletService.getWalletBalance();
      setState(() {
        _walletBalance = balance;
        _loadingWallet = false;
      });
    } catch (e) {
      setState(() => _loadingWallet = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load wallet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchUnreadNotifications() async {
    try {
      final unread = await _notificationService.getUnreadCount();
      if (!mounted) return;
      setState(() {
        _unreadNotifications = unread;
        _loadingNotifications = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingNotifications = false);
    }
  }

  Future<void> _fetchUrgentCampaigns() async {
    try {
      final repo = CampaignRepository();
      final campaigns = await repo.getUrgentCampaigns(limit: 10);
      if (!mounted) return;
      setState(() {
        _urgentCampaigns = campaigns;
        _loadingUrgent = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingUrgent = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load urgent campaigns: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _daysLeftLabel(DateTime? endDate, AppLocalizations l10n) {
    if (endDate == null) return l10n.noDeadline;
    final days = endDate.difference(DateTime.now()).inDays;
    if (days <= 0) return l10n.endingToday;
    return '$days ${l10n.daysLeft}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER BALANCE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with user icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.yourBalance,
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_outlined,
                                color: Colors.white, size: 32),
                            if (!_loadingNotifications &&
                                _unreadNotifications > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF751F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _unreadNotifications > 99
                                          ? '99+'
                                          : _unreadNotifications.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onPressed: () {
                          context.go('/notifications');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  _loadingWallet
                      ? const SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'LKR ${_walletBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                  const SizedBox(height: 20),

                  /// ACTIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _HeaderAction(
                        icon: Icons.add_circle_outline,
                        label: l10n.topUp,
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WalletTopUpPage(),
                            ),
                          );
                          // Refresh wallet balance if topup was successful
                          if (result == true) {
                            await _fetchWalletBalance();
                          }
                        },
                      ),
                      _HeaderAction(
                        icon: Icons.swap_horiz,
                        label: l10n.transfer,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transfer feature coming soon'),
                            ),
                          );
                        },
                      ),
                      _HeaderAction(
                        icon: Icons.favorite_border,
                        label: l10n.donate,
                        onTap: () {
                          context.push('/donor/beneficiary-campaigns');
                        },
                      ),
                      _HeaderAction(
                        icon: Icons.history,
                        label: l10n.history,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const WalletTransactionHistoryPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SHARE KINDNESS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.shareKindnessToday,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// START CAMPAIGN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(l10n.startCampaign),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF751F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StartCampaignPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// SUPPORT CAMPAIGN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.favorite_border),
                      label: Text(l10n.supportCampaign),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        context.push('/campaigns');
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// URGENT DONATION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.urgentDonations,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/campaigns'),
                        child: Text(
                          l10n.seeAll,
                          style: const TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (_loadingUrgent)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_urgentCampaigns.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text(l10n.noUrgentCampaigns)),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const gap = 12.0;
                        final cellW = (constraints.maxWidth - gap) / 2;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: _urgentCampaigns.map((campaign) {
                            return SizedBox(
                              width: cellW,
                              child: _UrgentDonationMiniCard(
                                campaign: campaign,
                                l10n: l10n,
                                daysLeftText:
                                    _daysLeftLabel(campaign.endDate, l10n),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// Intrinsic height — avoids blank space from GridView [childAspectRatio].
class _UrgentDonationMiniCard extends StatelessWidget {
  final Campaign campaign;
  final AppLocalizations l10n;
  final String daysLeftText;

  const _UrgentDonationMiniCard({
    required this.campaign,
    required this.l10n,
    required this.daysLeftText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      shadowColor: Colors.black26,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (campaign.image != null && campaign.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  campaign.image!,
                  height: 86,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 86,
                      width: double.infinity,
                      color: AppColors.blueSurface,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 86,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.blueSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.campaign,
                  color: AppColors.primaryBlue,
                  size: 32,
                ),
              ),
            const SizedBox(height: 5),
            Text(
              campaign.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.2,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              campaign.description?.isNotEmpty == true
                  ? campaign.description!
                  : l10n.supportCampaign,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                height: 1.15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              daysLeftText,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                color: campaign.endDate != null
                    ? AppColors.primaryOrange
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.2,
                  ),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CampaignDetailsScreen(
                        campaign: campaign,
                      ),
                    ),
                  );
                },
                child: Text(
                  l10n.details,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _HeaderAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

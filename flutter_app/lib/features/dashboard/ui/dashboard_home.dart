import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindora/features/campaign/ui/start_campaign_page.dart';
import 'package:kindora/features/wallet/ui/wallet_topup_page.dart';
import 'package:kindora/features/wallet/ui/wallet_transaction_history_page.dart';
import 'package:kindora/services/wallet_service.dart';
import 'package:kindora/repositories/supabase_repositories.dart';
import 'package:kindora/models/supabase_models.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late WalletService _walletService;
  double _walletBalance = 0.0;
  bool _loadingWallet = true;
  bool _loadingUrgent = true;
  List<Campaign> _urgentCampaigns = [];

  @override
  void initState() {
    super.initState();
    _walletService = WalletService();
    _fetchWalletBalance();
    _fetchUrgentCampaigns();
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

  String _daysLeftLabel(DateTime? endDate) {
    if (endDate == null) return 'No deadline';
    final days = endDate.difference(DateTime.now()).inDays;
    if (days <= 0) return 'Ending today';
    return '$days days left';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER BALANCE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0C0C79),
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
                      const Text(
                        "Your Balance",
                        style: TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person,
                            color: Colors.white, size: 32),
                        onPressed: () {
                          context.push('/profile');
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
                        label: "Top up",
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
                        label: "Transfer",
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
                        label: "Donate",
                        onTap: () {
                          context.push('/donor/beneficiary-campaigns');
                        },
                      ),
                      _HeaderAction(
                        icon: Icons.history,
                        label: "History",
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
                  const Text(
                    "Share Kindness Today",
                    style: TextStyle(
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
                      label: const Text("Start a Campaign"),
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
                      label: const Text("Support a Campaign"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C0C79),
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
                      const Text(
                        "Urgent Donations",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/campaigns'),
                        child: const Text("See all"),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('No urgent campaigns available')),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _urgentCampaigns.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final campaign = _urgentCampaigns[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/campaigns'),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (campaign.image != null && campaign.image!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        campaign.image!,
                                        height: 90,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) {
                                          return Container(
                                            height: 90,
                                            width: double.infinity,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image_not_supported),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Container(
                                      height: 90,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.campaign, color: Colors.grey),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    campaign.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    campaign.description?.isNotEmpty == true
                                        ? campaign.description!
                                        : 'Support this campaign',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _daysLeftLabel(campaign.endDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: campaign.endDate != null
                                          ? Colors.redAccent
                                          : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

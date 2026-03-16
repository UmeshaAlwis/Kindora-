import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindora/features/campaign/ui/start_campaign_page.dart';
import 'package:kindora/features/wallet/ui/wallet_topup_page.dart';
import 'package:kindora/features/wallet/ui/wallet_transaction_history_page.dart';
import 'package:kindora/services/wallet_service.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late WalletService _walletService;
  double _walletBalance = 0.0;
  bool _loadingWallet = true;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService();
    _fetchWalletBalance();
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
                        context.push('/donor/beneficiary-campaigns');
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Urgent Donations",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("See all"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text('Campaign ${index + 1}'),
                          subtitle: const Text('Support this campaign'),
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

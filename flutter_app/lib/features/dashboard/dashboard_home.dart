import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../campaign/widgets/campaign_card.dart';
import '../../models/campaign.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final campaigns = [
      const Campaign(
        id: "1",
        title: "Help children for orphanage scholarship",
        description: "Orphan Foundation",
        goalAmount: 3000,
        raisedAmount: 2400,
      ),
      const Campaign(
        id: "2",
        title: "Help and care for abandoned animals",
        description: "Animal Kaiser",
        goalAmount: 3000,
        raisedAmount: 2400,
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER BALANCE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A8F),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Balance",
                    style: TextStyle(color: Colors.white70),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "\$200",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 20),

                  /// ACTIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _HeaderAction(icon: Icons.add, label: "Top up"),
                      _HeaderAction(icon: Icons.send, label: "Transfer"),
                      _HeaderAction(icon: Icons.download, label: "Withdraw"),
                      _HeaderAction(icon: Icons.history, label: "History"),
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
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () {},
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// SUPPORT CAMPAIGN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.favorite),
                      label: const Text("Support a Campaign"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A8F),
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () {},
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
                        "Urgent donations",
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
                    itemCount: campaigns.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      return CampaignCard(
                        campaign: campaigns[index],
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

  const _HeaderAction({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

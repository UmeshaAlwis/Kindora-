import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindora/features/campaign/widgets/campaign_card.dart';
import 'package:kindora/models/campaign.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    /// Temporary campaigns for dashboard preview
    final List<Campaign> campaigns = [
      Campaign(
        id: "1",
        title: "Cancer Treatment Fund",
        description: "Help raise funds for urgent medical treatment.",
        goalAmount: 10000,
        raisedAmount: 4500,
      ),
      Campaign(
        id: "2",
        title: "Flood Victim Support",
        description: "Support families affected by floods.",
        goalAmount: 8000,
        raisedAmount: 3200,
      ),
      Campaign(
        id: "3",
        title: "School Supplies",
        description: "Provide books and school supplies.",
        goalAmount: 5000,
        raisedAmount: 2700,
      ),
      Campaign(
        id: "4",
        title: "Food for Homeless",
        description: "Help provide meals.",
        goalAmount: 7000,
        raisedAmount: 3900,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        const Text(
                          "Your Balance",
                          style: TextStyle(color: Colors.white),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "\$200",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _HeaderAction(icon: Icons.add_circle_outline, label: "Top up"),
                        _HeaderAction(icon: Icons.swap_horiz, label: "Transfer"),
                        _HeaderAction(icon: Icons.favorite_border, label: "Donate"),
                        _HeaderAction(icon: Icons.history, label: "History"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// START / SUPPORT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Start a Campaign"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF751F),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => context.push('/create-campaign'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.favorite_border),
                        label: const Text("Support a Campaign"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C0C79),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => context.push('/campaigns'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// URGENT DONATIONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: campaigns.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    return CampaignCard(
                      campaign: campaigns[index],
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
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
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
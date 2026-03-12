import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kindora/providers/supabase_providers.dart';
import 'package:kindora/features/payment/ui/payment_page.dart';
import 'package:kindora/features/payment/models/payment_model.dart'
    as payment_model;
import 'start_campaign_page.dart';

class CampaignHomePage extends ConsumerWidget {
  const CampaignHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Campaigns",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF751F),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            tabs: [
              Tab(text: "All"),
              Tab(text: "Ongoing"),
              Tab(text: "Success"),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  const CampaignList(),
                  const Center(child: Text("No ongoing campaigns")),
                  const Center(child: Text("No successful campaigns")),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Campaign"),
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
            ),
          ],
        ),
      ),
    );
  }
}

class CampaignList extends ConsumerWidget {
  const CampaignList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('[CampaignList] Building CampaignList widget');
    final campaignsAsync = ref.watch(allCampaignsProvider);
    print('[CampaignList] campaignsAsync state: ${campaignsAsync.runtimeType}');

    return campaignsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) {
        print('[CampaignList] ERROR: $err');
        print('[CampaignList] STACK: $stack');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading campaigns: $err'),
            ],
          ),
        );
      },
      data: (campaigns) {
        print('[CampaignList] DATA received: ${campaigns.length} campaigns');
        if (campaigns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.campaign, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No campaigns available yet'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StartCampaignPage(),
                      ),
                    );
                  },
                  child: const Text('Start a Campaign'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            print('[CampaignList] Refreshing campaigns...');
            ref.invalidate(allCampaignsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              final targetAmount = campaign.targetAmount ?? 0.0;
              final raisedAmount = campaign.raisedAmount ?? 0.0;
              final progress = targetAmount > 0
                  ? (raisedAmount / targetAmount).clamp(0.0, 1.0)
                  : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(26, 0, 0, 0),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: campaign.image != null &&
                                campaign.image!.isNotEmpty
                            ? Image.network(
                                campaign.image!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 80,
                                  width: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              )
                            : Container(
                                height: 80,
                                width: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.campaign),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Title
                            Text(
                              campaign.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0C0C79),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 6),

                            /// Raised Amount
                            Text(
                              'Raised LKR ${(campaign.raisedAmount ?? 0.0).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(255, 128, 128, 128),
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey[200],
                                color: const Color(0xFFFF751F),
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// Support Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0C0C79),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: () {
                                  // Convert Supabase campaign to payment model campaign
                                  final paymentCampaign =
                                      payment_model.Campaign(
                                    id: campaign.id,
                                    title: campaign.title,
                                    image: campaign.image ?? '',
                                    raisedAmount: campaign.raisedAmount ?? 0.0,
                                    targetAmount: campaign.targetAmount ?? 0.0,
                                    description: campaign.description ?? '',
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentPage(
                                          campaign: paymentCampaign),
                                    ),
                                  );
                                },
                                child: const Text("Support Campaign"),
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// Edit & Share Buttons
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Color(0xFF0C0C79),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const StartCampaignPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.share,
                                    size: 20,
                                    color: Color(0xFF0C0C79),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Share feature coming soon",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

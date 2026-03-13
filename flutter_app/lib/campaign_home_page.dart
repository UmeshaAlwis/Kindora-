import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'start_campaign_page.dart';
import 'donation_sheet.dart';
import 'progresstracker.dart';
import 'services/campaign_services.dart';

class CampaignHomePage extends StatelessWidget {
  const CampaignHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Campaigns",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFFFF751F),
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            tabs: const [
              Tab(text: "All"),
              Tab(text: "Ongoing"),
              Tab(text: "Success"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CampaignList(),
            Center(child: Text("No ongoing campaigns")),
            Center(child: Text("No successful campaigns")),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFFF751F),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StartCampaignPage()),
            );
          },
        ),
      ),
    );
  }
}

//  showDonationSheet
void showDonationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const DonationSheet(),
  );
}

class CampaignList extends StatefulWidget {
  const CampaignList({super.key});

  @override
  State<CampaignList> createState() => _CampaignListState();
}

class _CampaignListState extends State<CampaignList> {

  // stateful list instead of Future
  List<dynamic> campaigns = [];
  bool _isLoading = true;
  late final RealtimeChannel _subscription;

  //  initState calls both load and subscribe
  @override
  void initState() {
    super.initState();
    _loadCampaigns();
    _subscribeToRealtime();
  }

  Future<void> _loadCampaigns() async {
    try {
      final data = await CampaignService().getCampaigns();
      if (mounted) {
        setState(() {
          campaigns = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // real-time listener
  void _subscribeToRealtime() {
    final supabase = Supabase.instance.client;
    _subscription = supabase
        .channel('campaigns_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'campaigns',
          callback: (payload) {
            _loadCampaigns(); // auto refresh on any change
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _subscription.unsubscribe(); // ✅ clean up on exit
    super.dispose();
  }

  // FutureBuilder changed to direct ListView with loading state
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (campaigns.isEmpty) {
      return const Center(child: Text("No campaigns yet. Start one!"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        double raised = (campaign['raised_amount'] ?? 0).toDouble();
        double target = (campaign['target_amount'] ?? 1).toDouble();
        String priority = campaign['priority'] ?? 'Normal';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    campaign['image_url'] ??
                        "https://images.unsplash.com/photo-1593113630400-ea4288922497",
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Priority badge
                      if (priority == 'Urgent' || priority == 'High')
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: priority == 'Urgent'
                                ? Colors.red[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: priority == 'Urgent'
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                          child: Text(
                            priority == 'Urgent'
                                ? '🔴 Urgent'
                                : '🟠 High Priority',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: priority == 'Urgent'
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ),

                      Text(
                        campaign['title'] ?? "Campaign",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0C0C79),
                        ),
                      ),

                      const SizedBox(height: 6),

                      ProgressTracker(
                        raisedAmount: raised,
                        targetAmount: target,
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C0C79),
                          ),
                          onPressed: () => showDonationSheet(context),
                          child: Text(
                            "Donate",
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                size: 20, color: Color(0xFF0C0C79)),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StartCampaignPage(),
                                ),
                              );
                              _loadCampaigns();
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.share,
                                size: 20, color: Color(0xFF0C0C79)),
                            onPressed: () {
                              Share.share(
                                "Support my campaign: ${campaign['title']}",
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
    );
  }
}
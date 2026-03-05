import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'start_campaign_page.dart';
import 'donation_sheet.dart';

class CampaignHomePage extends StatelessWidget {
  const CampaignHomePage({super.key});
void showDonationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return const DonationSheet();
    },
  );
}
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
              color: const Color.fromARGB(255, 255, 255, 255),
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
              MaterialPageRoute(
                builder: (_) => const StartCampaignPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CampaignList extends StatelessWidget {
  const CampaignList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
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
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1593113630400-ea4288922497",
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Title
                      Text(
                        "Help Flood Victims",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0C0C79),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Raised Amount
                      Text(
                        "Raised LKR 240,000",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.6,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFFFF751F),
                        ),
                      ),
                      const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0C0C79),
    ),
    onPressed: () {
      showDonationSheet(context);
    },
    child: const Text("Donate"),
  ),
),

                      const SizedBox(height: 8),

                      /// Edit & Share Buttons (WORKING NOW)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Color(0xFF0C0C79),
                            ),
                              hoverColor: const Color(0xFFFF751F).withOpacity(0.15),
                                  splashColor: const Color(0xFFFF751F).withOpacity(0.25),
                                  highlightColor: const Color.fromARGB(0, 0, 0, 0),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StartCampaignPage(),
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
                                                hoverColor: const Color(0xFFFF751F).withOpacity(0.15),
                            splashColor: const Color(0xFFFF751F).withOpacity(0.25),
                            highlightColor: const Color.fromARGB(0, 0, 0, 0),
                            onPressed: () {
                              Share.share(
                                "Support my campaign: Help Flood Victims\nRaised LKR 240,000",
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
        ),
      ],
    );
  }
}
void showDonationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return const DonationSheet();
    },
  );
}

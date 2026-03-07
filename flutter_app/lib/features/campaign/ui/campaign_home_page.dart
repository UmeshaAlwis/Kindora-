import 'package:flutter/material.dart';
import 'start_campaign_page.dart';

class CampaignHomePage extends StatelessWidget {
  const CampaignHomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        "Help Flood Victims",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0C0C79),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Raised Amount
                      const Text(
                        "Raised LKR 240,000",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 128, 128, 128),
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

                      /// Support Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C0C79),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Support campaign feature coming soon",
                                ),
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
                            hoverColor:
                                const Color(0xFFFF751F).withValues(alpha: 0.15),
                            splashColor:
                                const Color(0xFFFF751F).withValues(alpha: 0.25),
                            highlightColor:
                                const Color.fromARGB(0, 0, 0, 0),
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
                            hoverColor:
                                const Color(0xFFFF751F).withValues(alpha: 0.15),
                            splashColor:
                                const Color(0xFFFF751F).withValues(alpha: 0.25),
                            highlightColor:
                                const Color.fromARGB(0, 0, 0, 0),
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
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
import 'news_detail_screen.dart';
=======
import 'news_detail_screen.dart'; // This import will now work!
>>>>>>> rewards

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // ✅ Fixed: Added static to allow const declaration in State class
  static const Color primaryBlue = Color(0xFF0C0C79);
  static const Color primaryOrange = Color(0xFFFF751F);

  final TextEditingController _searchController = TextEditingController();

  // Full list of news items
  final List<Map<String, dynamic>> _allNews = [
    {
      'title': 'Ongoing: Jaffna Water Project',
      'subtitle': 'Phase 2 is now 70% complete. Clean water for 50 more families.',
      'status': 'ONGOING',
      'color': primaryBlue,
      'icon': LucideIcons.loader,
    },
    {
      'title': 'Success: Kandy School Drive',
      'subtitle': 'Campaign completed! 200 kids received new school bags and books.',
      'status': 'COMPLETED',
      'color': Colors.green[700]!,
      'icon': LucideIcons.checkCircle,
    },
    {
      'title': 'Urgent: Flood Relief Galle',
      'subtitle': 'Emergency dry rations needed for 20 families affected by heavy rain.',
      'status': 'URGENT',
      'color': Colors.red[700]!,
      'icon': LucideIcons.alertTriangle,
    },
    {
      'title': 'Kindora Milestone: 1000 Donors',
      'subtitle': 'We just reached 1,000 active donors on the platform. Thank you!',
      'status': 'MILESTONE',
      'color': primaryOrange,
      'icon': LucideIcons.award,
    },
  ];

  List<Map<String, dynamic>> _filteredNews = [];

  @override
  void initState() {
    super.initState();
    _filteredNews = _allNews;
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allNews;
    } else {
      results = _allNews
          .where((item) =>
      item["title"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          item["subtitle"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredNews = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text('Kindora News Feed',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      // No bottomNavigationBar here - uses Dashboard's nav as requested
      body: Column(
        children: [
          // SEARCH BAR SECTION
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryBlue,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search campaigns, bro...",
                // ✅ Fixed: Removed const from Icon because it uses a variable (primaryBlue)
                prefixIcon: Icon(LucideIcons.search, color: primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // LIST SECTION
          Expanded(
            child: _filteredNews.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredNews.length,
              itemBuilder: (context, index) {
                final item = _filteredNews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildNewsCard(
                    context,
                    title: item['title'],
                    subtitle: item['subtitle'],
                    status: item['status'],
                    color: item['color'],
                    icon: item['icon'],
                  ),
                );
              },
            )
                : const Center(
              child: Text("No news found for your search."),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context,
      {required String title,
        required String subtitle,
        required String status,
        required Color color,
        required IconData icon}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
<<<<<<< HEAD
=======
          // NAVIGATE to the details page
>>>>>>> rewards
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(
                title: title,
                subtitle: subtitle,
                status: status,
                color: color,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(20)),
                    child: Text(status,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
<<<<<<< HEAD
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54, height: 1.4)),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Text("Read more",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight, size: 14),
=======
              Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4)
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Text(
                        "Read more",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)
                    ),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight, size: 14, color: color),
>>>>>>> rewards
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
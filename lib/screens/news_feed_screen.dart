import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'news_detail_screen.dart'; // Ensure this import is here

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0C0C79);
    const Color primaryOrange = Color(0xFFFF751F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text('Kindora News Feed',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNewsCard(
            context,
            title: 'Ongoing: Jaffna Water Project',
            subtitle: 'Phase 2 is now 70% complete. Clean water for 50 more families.',
            status: 'ONGOING',
            color: primaryBlue,
            icon: LucideIcons.loader,
          ),
          const SizedBox(height: 16),
          _buildNewsCard(
            context,
            title: 'Success: Kandy School Drive',
            subtitle: 'Campaign completed! 200 kids received new school bags and books.',
            status: 'COMPLETED',
            color: Colors.green[700]!,
            icon: LucideIcons.checkCircle,
          ),
          const SizedBox(height: 16),
          _buildNewsCard(
            context,
            title: 'Urgent: Flood Relief Galle',
            subtitle: 'Emergency dry rations needed for 20 families affected by heavy rain.',
            status: 'URGENT',
            color: Colors.red[700]!,
            icon: LucideIcons.alertTriangle,
          ),
          const SizedBox(height: 16),
          _buildNewsCard(
            context,
            title: 'Kindora Milestone: 1000 Donors',
            subtitle: 'We just reached 1,000 active donors on the platform. Thank you!',
            status: 'MILESTONE',
            color: primaryOrange,
            icon: LucideIcons.award,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, {
    required String title,
    required String subtitle,
    required String status,
    required Color color,
    required IconData icon
  }) {
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
          // Navigates to the details page
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
                        color: color,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                        status,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 4),
              Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4)
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Text(
                        "Read more",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                    SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight, size: 14),
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
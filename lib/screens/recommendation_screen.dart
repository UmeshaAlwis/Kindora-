import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'AI Recommendations',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A40),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A40), Color(0xFF2E2E6E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.sparkles, color: Colors.amber, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Based on your interests, we found 3 new causes you might like.',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Recommended for You',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A40),
              ),
            ),
            const SizedBox(height: 20),
            _buildRecommendationCard(
              context,
              "Clean Water Initiative",
              "Matches your interest in Sustainability",
              LucideIcons.droplets,
              Colors.blue,
            ),
            _buildRecommendationCard(
              context,
              "Emergency Food Aid",
              "Urgent need in your local area",
              LucideIcons.utensils,
              Colors.orange,
            ),
            _buildRecommendationCard(
              context,
              "Rural School Library",
              "80% funded - Help them reach the goal",
              LucideIcons.bookOpen,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, String title, String reason, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CauseDetailScreen(
                title: title,
                reason: reason,
                icon: icon,
                color: color,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A40),
            )
        ),
        subtitle: Text(
            reason,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}

class CauseDetailScreen extends StatelessWidget {
  final String title;
  final String reason;
  final IconData icon;
  final Color color;

  const CauseDetailScreen({
    super.key,
    required this.title,
    required this.reason,
    required this.icon,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A40),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(child: Icon(icon, size: 80, color: color)),
            const SizedBox(height: 20),
            Text(title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(reason, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // NAVIGATION: Go to Amount Selection
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonationAmountScreen(campaignTitle: title),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A40),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Donate Now", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

// NEW: Donation Amount Screen
class DonationAmountScreen extends StatelessWidget {
  final String campaignTitle;
  const DonationAmountScreen({super.key, required this.campaignTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Amount"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A40),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Donating to:", style: GoogleFonts.poppins(color: Colors.grey)),
            Text(campaignTitle, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Amount",
                prefixText: "\$ ",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Success message or payment logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thank you for your donation!")),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A40),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Confirm Donation", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
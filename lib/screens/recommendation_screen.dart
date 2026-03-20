import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF1A1A40);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'AI Recommendations',
          style: GoogleFonts.poppins(
            color: darkNavy,
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
            // AI Info Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [darkNavy, Color(0xFF2E2E6E)],
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
                color: darkNavy,
              ),
            ),
            const SizedBox(height: 20),

            // Recommendation Cards
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
        onTap: () {
          // Navigate to Details
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
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1A1A40))
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

// --- DETAIL SCREEN ---
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A40),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(icon, size: 100, color: color),
            const SizedBox(height: 30),
            Text(title, style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              "Every donation helps provide resources for this cause. $reason.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[600]),
            ),
            const Spacer(),
            // ✅ THE BUTTON IS NOW FULLY FUNCTIONAL
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonationAmountScreen(campaignTitle: title),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A40),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: Text(
                "Donate Now",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- AMOUNT SELECTION SCREEN ---
class DonationAmountScreen extends StatefulWidget {
  final String campaignTitle;
  const DonationAmountScreen({super.key, required this.campaignTitle});

  @override
  State<DonationAmountScreen> createState() => _DonationAmountScreenState();
}

class _DonationAmountScreenState extends State<DonationAmountScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Select Amount", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A40),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your contribution to:", style: GoogleFonts.poppins(color: Colors.grey)),
            Text(widget.campaignTitle, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Donation Amount",
                prefixText: "\$ ",
                hintText: "0.00",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF1A1A40), width: 2),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter an amount")),
                  );
                  return;
                }

                // Show Success Message
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 50),
                    content: Text(
                      "Thank you! Your donation of \$${_amountController.text} to ${widget.campaignTitle} was successful.",
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Go back to the very beginning (The Recommendation Feed)
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: const Text("Done"),
                      )
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF751F), // Brand Orange
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                "Confirm & Pay",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
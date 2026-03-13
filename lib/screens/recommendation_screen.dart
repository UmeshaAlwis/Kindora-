import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

// RENAMED TO RecommendationScreen to fix the conflict with RewardsScreen
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
            // AI Suggestion Banner
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

            // Placeholder for AI-generated cards
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
          ],
        ),
      ),
    );
  }

  // Helper widget for AI Cards
  Widget _buildRecommendationCard(BuildContext context, String title, String reason, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
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
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(reason, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const NewsDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Campaign Update',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moreHorizontal, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status & Title Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.info, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(
                          status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: const Color(0xFF1A1A40), // Kindora Navy
                    ),
                  ),
                ],
              ),
            ),

            // 2. Info Grid (Quick Metadata)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetaItem(LucideIcons.mapPin, "Location", "Sri Lanka"),
                  _buildMetaItem(LucideIcons.clock, "Posted", "Recently"),
                  _buildMetaItem(LucideIcons.users, "Impact", "High"),
                ],
              ),
            ),

            // 3. Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Project Overview",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A40),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "This project is part of Kindora's mission to drive social impact through community-led initiatives. Your support helps us reach milestones faster and ensure transparency in every donation.",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 4. Action Buttons
                  Row(
                    children: [
                      // Share Button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(LucideIcons.share2, color: color, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Campaign link copied!'),
                                backgroundColor: color,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          label: Text(
                            "Share",
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Support Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Link to donation or support logic
                          },
                          child: const Text(
                            "SUPPORT NOW",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A40),
          ),
        ),
      ],
    );
  }
}
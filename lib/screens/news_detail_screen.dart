import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
=======
import 'package:lucide_icons/lucide_icons.dart';
>>>>>>> rewards

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
<<<<<<< HEAD
    required this.color
=======
    required this.color,
>>>>>>> rewards
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
<<<<<<< HEAD
        title: const Text('Campaign Details', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
=======
        title: Text('Project Details', style: GoogleFonts.poppins(color: Colors.white)),
        foregroundColor: Colors.white,
>>>>>>> rewards
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
<<<<<<< HEAD
              padding: const EdgeInsets.all(24),
              color: color.withOpacity(0.1),
=======
              height: 200,
              color: color.withOpacity(0.1),
              child: Icon(LucideIcons.image, size: 100, color: color),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
>>>>>>> rewards
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
<<<<<<< HEAD
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                    child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Project Overview", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    "$subtitle\n\nThis project is part of Kindora's mission to drive social impact through community-led initiatives. Your support helps us reach milestones faster and ensure transparency in every donation.",
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {},
                      child: const Text("Share this Update", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
=======
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    "Impact Summary",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "This project is part of Kindora's initiative to support local communities. Your contributions go directly towards the resources needed for this specific cause.",
                    style: TextStyle(color: Colors.black54),
>>>>>>> rewards
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
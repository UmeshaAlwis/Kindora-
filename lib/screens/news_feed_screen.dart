import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const Color kindoraBlue = Color(0xFF0C0C79);

  // 1. Plus Button Logic: Show a Bottom Sheet to create a post
  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text("Create New Update", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: kindoraBlue)),
            const SizedBox(height: 15),
            TextField(decoration: InputDecoration(hintText: "Title", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(maxLines: 3, decoration: InputDecoration(hintText: "What's happening?", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kindoraBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Post Update", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Column(
        children: [
          // Blue Header with Search
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
            decoration: const BoxDecoration(
              color: kindoraBlue,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Community Feed', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                    const Icon(LucideIcons.bell, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search updates...",
                    prefixIcon: const Icon(LucideIcons.search, color: kindoraBlue),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          // Feed List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildFeedCard("Sarah Jenkins", "SJ", "SUCCESS", "Clean Water Success!", Colors.green),
                _buildFeedCard("Kindora Team", "KT", "ONGOING", "Kandy School Drive", kindoraBlue),
              ],
            ),
          ),
        ],
      ),

      // 2. The working Plus Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: kindoraBlue,
        elevation: 6,
        onPressed: _showCreatePostSheet,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildFeedCard(String name, String initials, String status, String title, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: kindoraBlue.withOpacity(0.1), child: Text(initials, style: const TextStyle(color: kindoraBlue, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 12),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(title, style: GoogleFonts.poppins(color: kindoraBlue, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text("Read more", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kindoraBlue)),
              SizedBox(width: 5),
              Icon(LucideIcons.arrowRight, size: 14, color: kindoraBlue),
            ],
          )
        ],
      ),
    );
  }
}
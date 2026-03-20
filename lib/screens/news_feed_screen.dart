import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

/// FeedScreen: The main community engagement hub for Kindora.
/// Updated with brand colors (#0C0C79 & #FF751F) and notification logic.

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Brand Colors
  static const Color kindoraBlue = Color(0xFF0C0C79);
  static const Color kindoraOrange = Color(0xFFFF751F);

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // For auto-scroll

  // Data List
  final List<Map<String, dynamic>> _feedItems = [
    {
      "name": "Sarah Jenkins",
      "initials": "SJ",
      "status": "SUCCESS",
      "title": "Clean Water Success!",
      "color": Colors.green
    },
    {
      "name": "Kindora Team",
      "initials": "KT",
      "status": "ONGOING",
      "title": "Kandy School Drive",
      "color": kindoraBlue
    },
  ];

  // Logic: Notification Button Action
  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No new notifications at the moment.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Logic: Add a new post
  void _addNewPost() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        _feedItems.insert(0, {
          "name": "You",
          "initials": "ME",
          "status": "NEW",
          "title": _titleController.text,
          "color": kindoraOrange,
        });
      });

      // Auto-scroll to top to see the new post
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );

      _titleController.clear();
      _descController.clear();
      Navigator.pop(context);

      // Success Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update posted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
            Text("Create New Update",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: kindoraBlue)),
            const SizedBox(height: 15),
            TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: "Title", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(hintText: "What's happening?", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kindoraOrange, // Updated to Orange
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: _addNewPost,
              child: const Text("Post Update",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    Text('Community Feed',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                    IconButton(
                      icon: const Icon(LucideIcons.bell, color: Colors.white),
                      onPressed: _showNotifications, // Notification logic
                    ),
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

          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Added Controller
              padding: const EdgeInsets.all(20),
              itemCount: _feedItems.length,
              itemBuilder: (context, index) {
                final item = _feedItems[index];
                return _buildFeedCard(
                    item["name"],
                    item["initials"],
                    item["status"],
                    item["title"],
                    item["color"]
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: kindoraOrange, // Updated to Orange
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
                  CircleAvatar(
                      backgroundColor: kindoraBlue.withOpacity(0.1),
                      child: Text(initials, style: const TextStyle(color: kindoraBlue, fontWeight: FontWeight.bold))),
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
          Text(title,
              style: GoogleFonts.poppins(color: kindoraBlue, fontWeight: FontWeight.bold, fontSize: 17)),
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
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Kindora Updates',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A40),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Color(0xFF1A1A40)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. WATER PROJECT NEWS
          _buildNewsCard(
            context,
            title: "Clean Water Project: Phase 1 Done!",
            description: "We successfully installed 5 filtration systems in rural villages. See the impact your donations made.",
            imageUrl: "https://images.unsplash.com/photo-1541544537156-7627a7a4aa1c?q=80&w=2070",
            tag: "Completed",
            tagColor: Colors.green,
            time: "2 hours ago",
          ),

          // 2. MEDICAL SUPPLIES NEWS
          _buildNewsCard(
            context,
            title: "Medical Supplies Delivered",
            description: "First-aid kits reached three clinics this morning. 50 more kits are currently being packed for transport.",
            imageUrl: "https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?q=80&w=2000",
            tag: "Ongoing",
            tagColor: Colors.orange,
            time: "5 hours ago",
          ),

          // 3. EDUCATION KITS NEWS (NEW)
          _buildNewsCard(
            context,
            title: "School Kits Distribution",
            description: "New stationery and bags delivered to 150 students in the mountain region. Education is the best gift!",
            imageUrl: "https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=2070",
            tag: "Success",
            tagColor: Colors.blue,
            time: "Yesterday",
          ),

          // 4. COMMUNITY SUPPORT NEWS (NEW)
          _buildNewsCard(
            context,
            title: "Community Kitchen Support",
            description: "Our volunteers served over 300 meals today. Thank you to everyone who supported this initiative.",
            imageUrl: "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=2070",
            tag: "Ongoing",
            tagColor: Colors.orange,
            time: "2 days ago",
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(
      BuildContext context, {
        required String title,
        required String description,
        required String imageUrl,
        required String tag,
        required Color tagColor,
        required String time,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A40),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.bookOpen, size: 18),
                      label: const Text(
                        "Read Full Update",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.share2, size: 20, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'news_detail_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  // Kindora Design System Colors
  static const Color primaryNavy = Color(0xFF1A1A40);
  static const Color kindoraGreen = Color(0xFF4CAF50);
  static const Color primaryOrange = Color(0xFFFF751F);

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  // ✅ REAL-TIME STREAM: Listens to 'news' table
  final Stream<List<Map<String, dynamic>>> _newsStream = Supabase.instance.client
      .from('news')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

  // ✅ UI THEME MAPPER: Matches status to Kindora colors
  Map<String, dynamic> _getStatusTheme(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return {'color': primaryNavy, 'icon': LucideIcons.loader};
      case 'success':
      case 'completed':
        return {'color': kindoraGreen, 'icon': LucideIcons.checkCircle};
      case 'urgent':
        return {'color': Colors.red[700]!, 'icon': LucideIcons.alertTriangle};
      default:
        return {'color': primaryOrange, 'icon': LucideIcons.award};
    }
  }

  // ✅ TIMESTAMP CALCULATOR: Shows "5m ago", "2h ago", etc.
  String _getTimeAgo(String? timestamp) {
    if (timestamp == null) return "Just now";
    final DateTime createdAt = DateTime.parse(timestamp).toLocal();
    final Duration diff = DateTime.now().difference(createdAt);

    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }

  // ✅ MODAL: Post Update Bottom Sheet
  void _showAddNewsSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedStatus = 'ongoing';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text("Post Project Update",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: primaryNavy)),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Project Title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              const Text("Project Status", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: ['ongoing', 'success', 'urgent'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase(), style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) => setModalState(() => selectedStatus = val!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    try {
                      await Supabase.instance.client.from('news').insert({
                        'title': titleController.text,
                        'description': descController.text,
                        'status': selectedStatus,
                      });
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      debugPrint("Error inserting: $e");
                    }
                  }
                },
                child: const Text("Post to Feed", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryNavy,
        title: Text('Kindora News Feed',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryNavy,
        onPressed: _showAddNewsSheet,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryNavy,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchTerm = value.toLowerCase()),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search campaigns...",
                prefixIcon: const Icon(LucideIcons.search, color: primaryNavy),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // LIVE LIST SECTION
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _newsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Connection Error: ${snapshot.error}"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: primaryNavy));

                final filteredNews = snapshot.data!.where((item) {
                  final title = (item['title'] ?? '').toString().toLowerCase();
                  final desc = (item['description'] ?? '').toString().toLowerCase();
                  return title.contains(_searchTerm) || desc.contains(_searchTerm);
                }).toList();

                // EMPTY STATE UI
                if (filteredNews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.searchX, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("No updates found.", style: GoogleFonts.poppins(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNews.length,
                    itemBuilder: (context, index) {
                      final item = filteredNews[index];
                      final theme = _getStatusTheme(item['status'] ?? '');
                      final timeAgo = _getTimeAgo(item['created_at']);

                      return _buildNewsCard(
                        context,
                        title: item['title'] ?? 'Untitled',
                        subtitle: item['description'] ?? '',
                        status: (item['status'] ?? 'INFO').toUpperCase(),
                        color: theme['color'],
                        icon: theme['icon'],
                        time: timeAgo,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context,
      {required String title, required String subtitle, required String status, required Color color, required IconData icon, required String time}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(title: title, subtitle: subtitle, status: status, color: color),
            ),
          ),
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
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
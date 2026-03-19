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
  static const Color primaryNavy = Color(0xFF1A1A40);
  static const Color kindoraGreen = Color(0xFF4CAF50);
  static const Color primaryOrange = Color(0xFFFF751F);

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  // ✅ REAL-TIME STREAM
  final Stream<List<Map<String, dynamic>>> _newsStream = Supabase.instance.client
      .from('news')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

  Map<String, dynamic> _getStatusTheme(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing': return {'color': primaryNavy, 'icon': LucideIcons.loader};
      case 'success':
      case 'completed': return {'color': kindoraGreen, 'icon': LucideIcons.checkCircle};
      case 'urgent': return {'color': Colors.red[700]!, 'icon': LucideIcons.alertTriangle};
      default: return {'color': primaryOrange, 'icon': LucideIcons.award};
    }
  }

  void _showAddNewsSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedStatus = 'ongoing';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Project Title")),
              const SizedBox(height: 15),
              TextField(controller: descController, maxLines: 2, decoration: const InputDecoration(labelText: "Description")),
              DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: ['ongoing', 'success', 'urgent'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                onChanged: (val) => setModalState(() => selectedStatus = val!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, minimumSize: const Size(double.infinity, 50)),
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    await Supabase.instance.client.from('news').insert({
                      'title': titleController.text,
                      'description': descController.text,
                      'status': selectedStatus,
                    });
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Post Update", style: TextStyle(color: Colors.white)),
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
        title: Text('Kindora Feed', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: primaryNavy,
          onPressed: _showAddNewsSheet,
          child: const Icon(LucideIcons.plus, color: Colors.white)
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryNavy,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchTerm = value.toLowerCase()),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                hintText: "Search campaigns...",
                prefixIcon: const Icon(LucideIcons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _newsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final filtered = snapshot.data!.where((item) {
                  return item['title'].toString().toLowerCase().contains(_searchTerm);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.searchX, size: 50, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("No matches found", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final theme = _getStatusTheme(item['status'] ?? '');
                      return _buildNewsCard(
                        context,
                        title: item['title'] ?? 'Untitled',
                        subtitle: item['description'] ?? '',
                        status: (item['status'] ?? 'INFO').toUpperCase(),
                        color: theme['color'],
                        icon: theme['icon'],
                        time: "Just now", // In a real app, parse item['created_at']
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

  Widget _buildNewsCard(BuildContext context, {required String title, required String subtitle, required String status, required Color color, required IconData icon, required String time}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailScreen(title: title, subtitle: subtitle, status: status, color: color))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: color),
                  Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
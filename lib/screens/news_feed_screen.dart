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
  // ✅ UPDATED BRAND COLORS
  static const Color primaryBlue = Color(0xFF0C0C79);   // Leader's Blue
  static const Color primaryOrange = Color(0xFFFF751F); // Leader's Orange
  static const Color kindoraGreen = Color(0xFF4CAF50);
  static const Color bgColor = Color(0xFFF8F9FE);

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  final Stream<List<Map<String, dynamic>>> _newsStream = Supabase.instance.client
      .from('kindora_news_updates')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

  Map<String, dynamic> _getStatusTheme(String status) {
    switch (status.toLowerCase()) {
      case 'urgent':
        return {'color': Colors.redAccent, 'icon': LucideIcons.alertCircle};
      case 'success':
      case 'completed':
        return {'color': kindoraGreen, 'icon': LucideIcons.checkCircle2};
      case 'ongoing':
      default:
        return {'color': primaryBlue, 'icon': LucideIcons.refreshCw};
    }
  }

  String _getTimeAgo(String? timestamp) {
    if (timestamp == null) return "Just now";
    try {
      final DateTime createdAt = DateTime.parse(timestamp).toLocal();
      final Duration diff = DateTime.now().difference(createdAt);
      if (diff.inDays > 0) return "${diff.inDays}d ago";
      if (diff.inHours > 0) return "${diff.inHours}h ago";
      if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
      return "Just now";
    } catch (e) { return "Just now"; }
  }

  Future<void> _deletePost(BuildContext context, String id) async {
    try {
      final int? numericId = int.tryParse(id);
      if (numericId == null) throw "Invalid ID";
      await Supabase.instance.client.from('kindora_news_updates').delete().eq('id', numericId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update deleted"), backgroundColor: primaryBlue, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      debugPrint("❌ Delete Error: $e");
    }
  }

  void _showAddNewsSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedStatus = 'ongoing';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Text("Post Official Update", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Project Title", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: InputDecoration(labelText: "Details", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 15),
              const Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: ['ongoing', 'success', 'urgent'].map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                      selected: selectedStatus == status,
                      selectedColor: primaryOrange.withOpacity(0.2),
                      onSelected: (val) => setModalState(() => selectedStatus = status),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isSaving ? null : () async {
                  if (titleController.text.isEmpty) return;
                  setModalState(() => isSaving = true);
                  try {
                    await Supabase.instance.client.from('kindora_news_updates').insert({
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                      'status': selectedStatus,
                    });
                    if (mounted) Navigator.pop(context);
                  } catch (e) { setModalState(() => isSaving = false); }
                },
                child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Post to Feed", style: TextStyle(color: Colors.white)),
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
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Kindora Feed', style: GoogleFonts.poppins(color: primaryBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.bell, color: primaryBlue)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryBlue,
        onPressed: _showAddNewsSheet,
        label: const Text("Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchTerm = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search news...",
                prefixIcon: const Icon(LucideIcons.search, color: primaryBlue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _newsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryBlue));
                final data = snapshot.data ?? [];

                final filtered = data.where((item) => (item['title'] ?? '').toString().toLowerCase().contains(_searchTerm)).toList();

                if (filtered.isEmpty) {
                  return Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.newspaper, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text("No updates found", style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ));
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  color: primaryOrange,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _buildNewsCard(context, filtered[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> item) {
    final theme = _getStatusTheme(item['status'] ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => NewsDetailScreen(title: item['title'], subtitle: item['description'], status: item['status'], color: theme['color']))),
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Delete this update?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                TextButton(onPressed: () { Navigator.pop(ctx); _deletePost(context, item['id'].toString()); }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
              ],
            ),
          );
        },
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
                    decoration: BoxDecoration(color: theme['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Icon(theme['icon'], size: 12, color: theme['color']),
                        const SizedBox(width: 4),
                        Text((item['status'] ?? 'ONGOING').toUpperCase(), style: TextStyle(color: theme['color'], fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text(_getTimeAgo(item['created_at']), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Text(item['title'] ?? 'Untitled', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 4),
              Text(item['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("See details", style: TextStyle(fontSize: 11, color: primaryBlue, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Icon(LucideIcons.chevronRight, size: 14, color: Colors.grey[400]),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
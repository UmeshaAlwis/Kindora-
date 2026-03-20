import 'package:flutter/material.dart';
import 'package:kindora/features/messages/ui/direct_chat_page.dart';
import 'package:kindora/services/volunteer_campaign_service.dart';
import 'package:kindora/l10n/app_localizations.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  final VolunteerCampaignService _service = VolunteerCampaignService();
  bool _loading = true;
  String? _error;
  List<VolunteerCampaign> _campaigns = [];

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _campaigns = await _service.getAvailableCampaigns(limit: 50);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        backgroundColor: const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _error != null
                  ? Center(child: Text(_error!))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _campaigns.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final c = _campaigns[index];
                        return Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (c.imageUrl != null && c.imageUrl!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      c.imageUrl!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 150,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  c.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Donor: ${c.donorFullName}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                if (c.endDate != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'End: ${c.endDate!.toLocal().toString().split(' ').first}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: c.isJoined
                                            ? null
                                            : () async {
                                                await _service
                                                    .joinCampaign(c.id);
                                                await _load();
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF0C0C79),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(c.isJoined
                                            ? 'Joined'
                                            : 'Join as Volunteer'),
                                      ),
                                    ),
                                    if (c.isJoined) ...[
                                      const SizedBox(width: 10),
                                      IconButton(
                                        tooltip: 'Chat with donor',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DirectChatPage(
                                                receiverId: c.donorId,
                                                receiverName:
                                                    c.donorFullName,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.chat_bubble),
                                      )
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:kindora/features/messages/ui/direct_chat_page.dart';
import 'package:kindora/l10n/app_localizations.dart';
import 'package:kindora/services/volunteer_campaign_service.dart';

class VolunteerJoinedCampaignsScreen extends StatefulWidget {
  const VolunteerJoinedCampaignsScreen({super.key});

  @override
  State<VolunteerJoinedCampaignsScreen> createState() =>
      _VolunteerJoinedCampaignsScreenState();
}

class _VolunteerJoinedCampaignsScreenState
    extends State<VolunteerJoinedCampaignsScreen> {
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
      _campaigns = await _service.getJoinedCampaigns();
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
        title: Text(l10n.joinedCampaigns),
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
                  : _campaigns.isEmpty
                      ? const Center(child: Text('No joined campaigns yet'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _campaigns.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final c = _campaigns[index];
                            return Card(
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (c.imageUrl != null &&
                                        c.imageUrl!.isNotEmpty)
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.network(
                                          c.imageUrl!,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            height: 150,
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                                Icons.image_not_supported),
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
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
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
                                            child: const Text(
                                                'Chat with donor'),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          tooltip: 'Leave campaign',
                                          onPressed: () async {
                                            await _service
                                                .leaveCampaign(c.id);
                                            await _load();
                                          },
                                          icon: const Icon(Icons.exit_to_app),
                                        ),
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


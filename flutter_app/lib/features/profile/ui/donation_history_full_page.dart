import 'package:kindora/config/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/donor_donation_history_service.dart';
import 'donation_history_list_tile.dart';

/// Full donation history list (donor profile → See more).
class DonationHistoryFullPage extends StatefulWidget {
  const DonationHistoryFullPage({super.key});

  @override
  State<DonationHistoryFullPage> createState() => _DonationHistoryFullPageState();
}

class _DonationHistoryFullPageState extends State<DonationHistoryFullPage> {
  final DonorDonationHistoryService _service = DonorDonationHistoryService();
  late Future<DonationHistoryPageResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchHistoryPage(page: 1, limit: 100);
  }

  void _startLoad() {
    setState(() {
      _future = _service.fetchHistoryPage(page: 1, limit: 100);
    });
  }

  Future<void> _refresh() async {
    final next = _service.fetchHistoryPage(page: 1, limit: 100);
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All donations'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<DonationHistoryPageResult>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _startLoad,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data!.items;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No donations yet.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: items.length,
              itemBuilder: (context, i) {
                return DonationHistoryListTile(entry: items[i]);
              },
            ),
          );
        },
      ),
    );
  }
}

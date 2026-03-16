import 'package:flutter/material.dart';
import '../../../models/supabase_models.dart';
import '../../campaign/ui/campaign_home_page.dart';

class CampaignDetailsScreen extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailsScreen({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final targetAmount = campaign.targetAmount ?? 1000.0;
    final raisedAmount = campaign.raisedAmount ?? 0.0;
    final progress = (raisedAmount / targetAmount).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campaign Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              campaign.description ?? 'No description',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 10),
            Text(
              "Raised LKR ${raisedAmount.toStringAsFixed(0)} of LKR ${targetAmount.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.favorite),
                label: const Text("Donate Now"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CampaignHomePage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../models/campaign.dart';
import '../../../campaign_home_page.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;

  const CampaignCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final progress = campaign.raisedAmount / campaign.goalAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "https://picsum.photos/400/200",
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),

            /// Title
            Text(
              campaign.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 6),

            /// Description
            Text(
              campaign.description,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 10),

            /// Progress
            LinearProgressIndicator(value: progress),

            const SizedBox(height: 6),

            Text(
              "Raised \$${campaign.raisedAmount}",
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 10),

            /// Donate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Donate"),
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
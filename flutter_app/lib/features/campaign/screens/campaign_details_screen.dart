import 'package:flutter/material.dart';
import '../../../models/campaign.dart';

class CampaignDetailsScreen extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailsScreen({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final progress = campaign.raisedAmount / campaign.goalAmount;

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
              campaign.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(value: progress),

            const SizedBox(height: 10),

            Text(
              "Raised \$${campaign.raisedAmount} of \$${campaign.goalAmount}",
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Donation feature coming soon ❤️"),
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
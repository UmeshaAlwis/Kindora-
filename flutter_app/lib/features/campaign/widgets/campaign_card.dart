import 'package:flutter/material.dart';
import '../../../models/supabase_models.dart';
import '../ui/campaign_home_page.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;

  const CampaignCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress with safety checks
    final targetAmount = campaign.targetAmount ?? 1000.0;
    final raisedAmount = campaign.raisedAmount ?? 0.0;
    final progress = (raisedAmount / targetAmount).clamp(0.0, 1.0);

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
              child: campaign.image != null && campaign.image!.isNotEmpty
                  ? Image.network(
                      campaign.image!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.image,
                              size: 48, color: Colors.grey[400]),
                        );
                      },
                    )
                  : Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child:
                          Icon(Icons.image, size: 48, color: Colors.grey[400]),
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
              campaign.description ?? 'No description',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            /// Progress Bar with Percentage
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${(progress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Raised vs Target Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Raised: LKR ${raisedAmount.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  "Target: LKR ${targetAmount.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Support Campaign button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CampaignHomePage(),
                    ),
                  );
                },
                child: const Text("Support Campaign"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

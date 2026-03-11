import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/campaign.dart';


class CampaignCard extends StatelessWidget {
  final Campaign campaign;

  const CampaignCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {

    /// Safe progress calculation
    final progress = campaign.goalAmount == 0
        ? 0.0
        : (campaign.raisedAmount / campaign.goalAmount).clamp(0.0, 1.0);

    final percent = (progress * 100).toInt();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Campaign Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "https://picsum.photos/400/200",
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 12),

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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),

            /// Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(
                  Color(0xFFFF751F),
                ),
              ),
            ),

            const SizedBox(height: 6),

            /// Raised info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Raised \$${campaign.raisedAmount}",
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  "$percent%",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Donate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C0C79),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  context.push('/campaigns');
                },
                child: const Text("Donate"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
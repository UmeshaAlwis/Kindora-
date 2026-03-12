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
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Campaign Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                "https://picsum.photos/400/200",
                height: 110,   // reduced from 140
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),

            /// Title
            Text(
              campaign.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 4),

            /// Description
            Text(
              campaign.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            /// Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "$percent%",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Donate Button
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C0C79),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  context.push('/campaigns');
                },
                child: const Text(
                  "Donate",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
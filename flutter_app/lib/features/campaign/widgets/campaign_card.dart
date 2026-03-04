import 'package:flutter/material.dart';
import '../../../models/campaign.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;

  const CampaignCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final progress = campaign.raisedAmount / campaign.goalAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campaign.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            campaign.description,
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
          ),

          const SizedBox(height: 8),

          Text(
            "Raised \$${campaign.raisedAmount} of \$${campaign.goalAmount}",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
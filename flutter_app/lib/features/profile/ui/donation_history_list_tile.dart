import 'package:flutter/material.dart';
import '../services/donor_donation_history_service.dart';

class DonationHistoryListTile extends StatelessWidget {
  final DonationHistoryEntry entry;

  const DonationHistoryListTile({super.key, required this.entry});

  static String formatDate(DateTime? d) {
    if (d == null) return '—';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'completed':
      case 'success':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade800;
      case 'failed':
      case 'refunded':
        return Colors.red.shade700;
      default:
        return Colors.blueGrey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final method = entry.paymentMethod?.replaceAll('_', ' ') ?? '—';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C79).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              entry.isBeneficiary ? Icons.volunteer_activism : Icons.campaign,
              color: const Color(0xFF0C0C79),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'LKR ${entry.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor(entry.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.status.isEmpty ? 'unknown' : entry.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor(entry.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.typeLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDate(entry.createdAt)} · $method',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

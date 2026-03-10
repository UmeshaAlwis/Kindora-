import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressTracker extends StatelessWidget {
  final double raisedAmount;
  final double targetAmount;

  const ProgressTracker({
    super.key,
    required this.raisedAmount,
    required this.targetAmount,
  });

  @override
  Widget build(BuildContext context) {
    double progress = raisedAmount / targetAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Amount Text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Raised LKR ${raisedAmount.toStringAsFixed(0)}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF0C0C79),
              ),
            ),

            Text(
              "Goal LKR ${targetAmount.toStringAsFixed(0)}",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFFFF751F),
          ),
        ),

        const SizedBox(height: 6),

        /// Percentage Text
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${(progress * 100).toStringAsFixed(1)}% funded",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
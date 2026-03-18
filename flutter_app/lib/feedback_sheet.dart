import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackSheet extends StatefulWidget {
  final String campaignTitle;

  const FeedbackSheet({
    super.key,
    required this.campaignTitle,
  });

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  int selectedRating = 0;

  String get ratingLabel {
    switch (selectedRating) {
      case 1:
        return "Poor 😞";
      case 2:
        return "Fair 😐";
      case 3:
        return "Good 🙂";
      case 4:
        return "Very Good 😊";
      case 5:
        return "Excellent! 🌟";
      default:
        return "Tap a star to rate";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              "Rate this Campaign",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0C0C79),
              ),
            ),

            const SizedBox(height: 4),

            // Campaign name
            Text(
              widget.campaignTitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            // Star rating label
            Text(
              "Your Rating",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // Stars
            Row(
              children: List.generate(5, (index) {
                final star = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => selectedRating = star),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      star <= selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: star <= selectedRating
                          ? const Color(0xFFFF751F)
                          : Colors.grey[400],
                      size: 38,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            // Rating label
            Text(
              ratingLabel,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selectedRating == 0
                    ? Colors.grey
                    : const Color(0xFFFF751F),
              ),
            ),

            const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }
}
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
  final TextEditingController commentController = TextEditingController(); // ✅ added

  @override
  void dispose() {
    commentController.dispose(); 
    super.dispose();
  }

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

            const SizedBox(height: 20),

            //  Comment label
            Text(
              "Comment (optional)",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Comment box
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Share your thoughts about this campaign...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF0C0C79),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C0C79),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: selectedRating == 0
                    ? null //  disabled if no star selected
                    : () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Thank you for your feedback! 🙏"),
                            backgroundColor: Color(0xFF0C0C79),
                          ),
                        );
                      },
                child: Text(
                  "Submit Feedback",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
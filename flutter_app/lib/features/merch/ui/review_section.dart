import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/supabase_models.dart';
import '../../../providers/supabase_providers.dart';

class ReviewSection extends ConsumerWidget {
  final String productId;

  const ReviewSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Reviews',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              InkWell(
                onTap: () {
                  _showWriteReviewDialog(context, ref, productId);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C79).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: Color(0xFF0C0C79),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Write',
                        style: TextStyle(
                          color: Color(0xFF0C0C79),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          reviewsAsync.when(
            data: (reviews) {
              if (reviews.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No reviews yet. Be the first to review!',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(context, reviews[index], isDarkMode);
                },
              );
            },
            loading: () => SizedBox(
              height: 200,
              child: Column(
                children: List.generate(
                  3,
                  (index) => Shimmer.fromColors(
                    baseColor:
                        isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    highlightColor:
                        isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Error loading reviews',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    ProductReview review,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review.reviewerName ?? 'Anonymous',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 16,
                    color: index < review.rating.toInt()
                        ? Colors.amber[700]
                        : isDarkMode
                            ? Colors.grey[600]
                            : Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Rating Text
          Text(
            '${review.rating.toStringAsFixed(1)} stars',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),

          // Review Text
          if (review.reviewText != null && review.reviewText!.isNotEmpty)
            Text(
              review.reviewText!,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontSize: 13,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 8),

          // Date
          Text(
            'Reviewed on ${_formatDate(review.createdAt)}',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showWriteReviewDialog(
    BuildContext context,
    WidgetRef ref,
    String productId,
  ) {
    double rating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            backgroundColor:
                isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            title: Text(
              'Write a Review',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rating',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                          (index) => InkWell(
                            onTap: () {
                              setState(() {
                                rating = (index + 1).toDouble();
                              });
                            },
                            child: Icon(
                              Icons.star,
                              size: 28,
                              color: index < rating
                                  ? Colors.amber[700]
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Review Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Review',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: reviewController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Share your experience...',
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey[50],
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Submit review
                  if (reviewController.text.isNotEmpty) {
                    // TODO: Add review to Supabase
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Review submitted!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C0C79),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

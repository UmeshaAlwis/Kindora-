import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/supabase_models.dart';
import '../../../providers/supabase_providers.dart';
import '../../../providers/cart_provider.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final productAsync = ref.watch(merchandiseByIdProvider(widget.productId));
    final reviewsAsync = ref.watch(productReviewsProvider(widget.productId));

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Product Details'),
        centerTitle: true,
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Product Image
                _buildProductImageSection(context, product, isDarkMode),

                // Product Info
                _buildProductInfoSection(context, product, isDarkMode),

                // Delivery Info
                _buildDeliverySection(context, isDarkMode),

                // Quantity Selector
                _buildQuantitySelector(context, isDarkMode),

                // Reviews Section
                _buildReviewsSection(context, reviewsAsync, isDarkMode),

                // Action Buttons
                _buildActionButtons(context, product, isDarkMode),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(isDarkMode),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text('Error loading product: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(merchandiseByIdProvider(widget.productId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImageSection(
    BuildContext context,
    Merchandise product,
    bool isDarkMode,
  ) {
    // Use a working placeholder if imageUrl is invalid or empty
    final validImageUrl = (product.imageUrl == null ||
            product.imageUrl!.isEmpty)
        ? 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=400&fit=crop'
        : product.imageUrl!;

    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      ),
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: CachedNetworkImage(
          imageUrl: validImageUrl,
          fit: BoxFit.cover,
          httpHeaders: const {
            'Content-Type': 'image/jpeg',
            'User-Agent': 'Mozilla/5.0'
          },
          placeholder: (context, url) => Container(
            color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[200],
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor:
                  isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfoSection(
    BuildContext context,
    Merchandise product,
    bool isDarkMode,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name ?? 'Unknown Product',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
            ),
            const SizedBox(height: 12),

            // Price and Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price?.toStringAsFixed(2) ?? 'N/A'}',
                      style: const TextStyle(
                        color: Color(0xFFFF751F),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                if ((product.averageRating ?? 0) > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rating',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.averageRating?.toStringAsFixed(1) ?? '0',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${product.reviewCount ?? 0})',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Stock Status
            if ((product.stock ?? 0) > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  'In Stock (${product.stock} available)',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: const Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Description
            if (product.description != null && product.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection(BuildContext context, bool isDarkMode) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.3, 1),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue[50],
          border: Border.all(
            color: isDarkMode ? Colors.blue[700]! : Colors.blue[200]!,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: isDarkMode ? Colors.blue[400] : Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Sat, Nov 23 - Mon, Nov 25',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Free Delivery',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context, bool isDarkMode) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.4, 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1
                        ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                        : null,
                    color: const Color(0xFF0C0C79),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Text(
                      _quantity.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                    color: const Color(0xFF0C0C79),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    AsyncValue<List<ProductReview>> reviewsAsync,
    bool isDarkMode,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.5, 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ratings & Reviews',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            reviewsAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No reviews yet',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length > 3 ? 3 : reviews.length,
                  itemBuilder: (context, index) {
                    return _buildReviewItem(
                        context, reviews[index], isDarkMode);
                  },
                );
              },
              loading: () => SizedBox(
                height: 100,
                child: Shimmer.fromColors(
                  baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor:
                      isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              error: (error, stack) => Text(
                'Error loading reviews: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.reviewerName ?? 'Anonymous',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 14,
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
          if (review.reviewText != null && review.reviewText!.isNotEmpty)
            Text(
              review.reviewText!,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontSize: 12,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Merchandise product,
    bool isDarkMode,
  ) {
    final isOutOfStock = (product.stock ?? 0) <= 0;

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.6, 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            // Add to Cart Button
            Expanded(
              child: OutlinedButton(
                onPressed: isOutOfStock
                    ? null
                    : () {
                        ref.read(cartProvider.notifier).addToCart(
                              product,
                              quantity: _quantity,
                            );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$_quantity item(s) added to cart',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0C0C79)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF0C0C79),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Buy Now Button
            Expanded(
              child: ElevatedButton(
                onPressed: isOutOfStock
                    ? null
                    : () {
                        // Navigate to payment with product details
                        context.push('/payment', extra: {
                          'productId': product.id,
                          'productName': product.name,
                          'price': product.price,
                          'quantity': _quantity,
                          'imageUrl': product.imageUrl,
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF751F),
                  disabledBackgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              height: 300,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor:
                      isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Container(
                    height: 24,
                    width: 200,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor:
                      isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    width: 150,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
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

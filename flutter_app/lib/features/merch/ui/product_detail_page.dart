import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/supabase_models.dart';
import '../../../providers/supabase_providers.dart';

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
    final productAsync = ref.watch(merchandiseByIdProvider(widget.productId));
    final reviewsAsync = ref.watch(productReviewsProvider(widget.productId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0C79),
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
                _buildProductImageSection(context, product),

                // Product Info
                _buildProductInfoSection(context, product),

                // Delivery Info
                _buildDeliverySection(context),

                // Quantity Selector
                _buildQuantitySelector(context),

                // Reviews Section
                _buildReviewsSection(context, reviewsAsync),

                // Action Buttons
                _buildActionButtons(context, product),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(),
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
  ) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      ),
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: product.imageUrl == null || product.imageUrl!.isEmpty
            ? Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
              )
            : CachedNetworkImage(
                imageUrl: product.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.grey[300]),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
      ),
    );
  }

  Widget _buildProductInfoSection(
    BuildContext context,
    Merchandise product,
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
                    const Text(
                      'Price',
                      style: TextStyle(
                        color: Colors.grey,
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
                      const Text(
                        'Rating',
                        style: TextStyle(
                          color: Colors.grey,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${product.reviewCount ?? 0})',
                            style: TextStyle(
                              color: Colors.grey[600],
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
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'In Stock (${product.stock} available)',
                  style: TextStyle(
                    color: Colors.green[700],
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
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.red[700],
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
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    style: TextStyle(
                      color: Colors.grey[700],
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

  Widget _buildDeliverySection(BuildContext context) {
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
          color: Colors.blue[50],
          border: Border.all(color: Colors.blue[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated Delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Sat, Nov 23 - Mon, Nov 25',
                      style: TextStyle(
                        color: Colors.grey[600],
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
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Free Delivery',
                    style: TextStyle(
                      color: Colors.green[700],
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

  Widget _buildQuantitySelector(BuildContext context) {
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
            const Text(
              'Quantity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
            const Text(
              'Ratings & Reviews',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
                        color: Colors.grey[600],
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
                    return _buildReviewItem(context, reviews[index]);
                  },
                );
              },
              loading: () => SizedBox(
                height: 100,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
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

  Widget _buildReviewItem(BuildContext context, ProductReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
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
                color: Colors.grey[700],
                fontSize: 12,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Merchandise product) {
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
                        // Add to cart logic
                        final cartItems = ref.read(cartItemsProvider);
                        final updatedCart = [...cartItems];

                        final existingIndex = updatedCart.indexWhere(
                          (item) => item['productId'] == product.id,
                        );

                        if (existingIndex >= 0) {
                          updatedCart[existingIndex]['quantity'] += _quantity;
                        } else {
                          updatedCart.add({
                            'productId': product.id,
                            'productName': product.name,
                            'price': product.price,
                            'quantity': _quantity,
                            'imageUrl': product.imageUrl,
                          });
                        }

                        ref.read(cartItemsProvider.notifier).state =
                            updatedCart;

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

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 300,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 24,
                    width: 200,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    width: 150,
                    color: Colors.grey[300],
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

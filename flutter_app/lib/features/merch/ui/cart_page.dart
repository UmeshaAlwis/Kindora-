import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cart = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalProvider);
    final itemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Cart ($itemCount)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(context, isDarkMode)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return _buildCartItem(context, item, ref, isDarkMode);
                    },
                  ),
                ),
                _buildCartSummary(
                  context,
                  totalPrice,
                  itemCount,
                  isDarkMode,
                  ref,
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some items to get started',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/merch'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C0C79),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            label: const Text(
              'Continue Shopping',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    WidgetRef ref,
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: (item.product.imageUrl == null ||
                      item.product.imageUrl!.isEmpty)
                  ? 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200&h=200&fit=crop'
                  : item.product.imageUrl!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              httpHeaders: const {
                'Content-Type': 'image/jpeg',
                'User-Agent': 'Mozilla/5.0'
              },
              placeholder: (context, url) => Container(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                child: Shimmer.fromColors(
                  baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  highlightColor:
                      isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
                  child: Container(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                child: Icon(
                  Icons.image_not_supported,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name ?? 'Product',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.product.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    color: Color(0xFFFF751F),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Quantity and Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        if (item.quantity > 1) {
                          ref.read(cartProvider.notifier).updateQuantity(
                              item.product.id, item.quantity - 1);
                        } else {
                          ref
                              .read(cartProvider.notifier)
                              .removeFromCart(item.product.id);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: const Color(0xFF0C0C79),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        item.quantity.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if ((item.product.stock ?? 0) > item.quantity) {
                          ref.read(cartProvider.notifier).updateQuantity(
                              item.product.id, item.quantity + 1);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: const Color(0xFF0C0C79),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    double totalPrice,
    int itemCount,
    bool isDarkMode,
    WidgetRef ref,
  ) {
    const taxRate = 0.1; // 10% tax
    final taxAmount = totalPrice * taxRate;
    final grandTotal = totalPrice + taxAmount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary Rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax (10%)',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                '\$${taxAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                'Free',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                '\$${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFFF751F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/merch'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0C0C79)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: TextStyle(
                      color: const Color(0xFF0C0C79),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to checkout
                    context.push('/checkout', extra: {
                      'cartItems': ref.watch(cartProvider),
                      'totalPrice': grandTotal,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C0C79),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

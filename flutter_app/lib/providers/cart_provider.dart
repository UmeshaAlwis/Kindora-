import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supabase_models.dart';

// Cart item model
class CartItem {
  final Merchandise product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => (product.price ?? 0) * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Cart state notifier
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Merchandise product, {int quantity = 1}) {
    final existingIndex =
        state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Product already in cart, increase quantity
      final updatedList = [...state];
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(
        quantity: updatedList[existingIndex].quantity + quantity,
      );
      state = updatedList;
    } else {
      // Add new product to cart
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final updatedList = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = updatedList;
  }

  void clearCart() {
    state = [];
  }

  double getTotalPrice() {
    return state.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int getTotalItems() {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Total price provider
final cartTotalProvider = Provider((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

// Total items provider
final cartItemCountProvider = Provider((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

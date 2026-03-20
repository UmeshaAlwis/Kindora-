import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/cart_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  late PageController _pageController;
  int _currentStep = 0;

  // Shipping Form
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  String _selectedShipping = 'standard';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cart = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalProvider);
    const taxRate = 0.1;
    final taxAmount = totalPrice * taxRate;
    final shippingCost = _selectedShipping == 'express' ? 15.0 : 0.0;
    final grandTotal = totalPrice + taxAmount + shippingCost;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(isDarkMode),

          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildShippingStep(isDarkMode),
                _buildReviewStep(isDarkMode, totalPrice, taxAmount,
                    shippingCost, grandTotal),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(isDarkMode, context, cart, grandTotal),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          _buildStepCircle(0, 'Shipping', isDarkMode),
          Expanded(
            child: Container(
              height: 2,
              color:
                  _currentStep > 0 ? const Color(0xFF0C0C79) : Colors.grey[300],
            ),
          ),
          _buildStepCircle(1, 'Review', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label, bool isDarkMode) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF0C0C79)
                : isDarkMode
                    ? Colors.grey[700]
                    : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              (step + 1).toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive
                ? const Color(0xFF0C0C79)
                : isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingStep(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Full Name
          _buildTextField(
            _fullNameController,
            'Full Name',
            isDarkMode,
          ),
          const SizedBox(height: 14),

          // Email
          _buildTextField(
            _emailController,
            'Email Address',
            isDarkMode,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          // Phone
          _buildTextField(
            _phoneController,
            'Phone Number',
            isDarkMode,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),

          // Address
          _buildTextField(
            _addressController,
            'Street Address',
            isDarkMode,
          ),
          const SizedBox(height: 14),

          // City, State, Zip (Row)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _cityController,
                  'City',
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _stateController,
                  'State',
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _zipController,
                  'Zip Code',
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Shipping Method
          Text(
            'Shipping Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Standard Shipping
          _buildShippingOption(
            'standard',
            'Standard Shipping',
            'Delivery in 5-7 business days',
            'Free',
            isDarkMode,
          ),
          const SizedBox(height: 12),

          // Express Shipping
          _buildShippingOption(
            'express',
            'Express Shipping',
            'Delivery in 2-3 business days',
            '\$15.00',
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption(
    String value,
    String title,
    String subtitle,
    String price,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _selectedShipping == value
              ? const Color(0xFF0C0C79)
              : isDarkMode
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
          width: _selectedShipping == value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
        color: _selectedShipping == value
            ? const Color(0xFF0C0C79).withOpacity(0.05)
            : isDarkMode
                ? const Color(0xFF1E1E1E)
                : Colors.white,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedShipping,
        onChanged: (val) {
          setState(() {
            _selectedShipping = val!;
          });
        },
        activeColor: const Color(0xFF0C0C79),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        secondary: Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFFFF751F),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStep(
    bool isDarkMode,
    double subtotal,
    double tax,
    double shipping,
    double total,
  ) {
    final cart = ref.watch(cartProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Cart Items
          ...cart.map((item) {
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name ?? 'Product',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${item.product.price?.toStringAsFixed(2) ?? '0.00'} x ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 20),
          Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[200]),
          const SizedBox(height: 12),

          // Shipping Address Review
          Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _fullNameController.text.isNotEmpty
                ? '${_fullNameController.text}\n${_addressController.text}\n${_cityController.text}, ${_stateController.text} ${_zipController.text}'
                : 'Please enter shipping address',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[200]),
          const SizedBox(height: 16),

          // Price Breakdown
          _buildPriceRow('Subtotal', subtotal, isDarkMode),
          const SizedBox(height: 8),
          _buildPriceRow('Tax (10%)', tax, isDarkMode),
          const SizedBox(height: 8),
          _buildPriceRow('Shipping', shipping, isDarkMode, isShipping: true),
          const SizedBox(height: 12),
          Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[200]),
          const SizedBox(height: 12),
          _buildPriceRow('Total', total, isDarkMode, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    bool isDarkMode, {
    bool isShipping = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          isShipping && amount == 0 ? 'Free' : '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal
                ? const Color(0xFFFF751F)
                : isDarkMode
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isDarkMode, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF0C0C79),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[50],
      ),
    );
  }

  Widget _buildNavigationButtons(
    bool isDarkMode,
    BuildContext context,
    List<CartItem> cart,
    double grandTotal,
  ) {
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
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep--);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0C0C79)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF0C0C79),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < 1) {
                  // Validate shipping form
                  if (_fullNameController.text.isEmpty ||
                      _emailController.text.isEmpty ||
                      _addressController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep++);
                } else {
                  // Place order
                  _placeOrder(context, cart, grandTotal);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C0C79),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _currentStep < 1 ? 'Continue' : 'Place Order',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder(
    BuildContext context,
    List<CartItem> cart,
    double total,
  ) {
    // TODO: Save order to Supabase database
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order has been confirmed.'),
            const SizedBox(height: 12),
            Text(
              'Order Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Items: ${cart.length}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              'Order confirmation has been sent to ${_emailController.text}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Clear cart
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
              context.go('/merch');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C0C79),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
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
}

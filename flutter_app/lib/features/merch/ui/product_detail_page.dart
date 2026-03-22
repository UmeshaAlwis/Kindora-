import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kindora/config/app_env.dart';
import 'package:kindora/config/themes/app_colors.dart';
import 'package:kindora/services/wallet_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  String _paymentMethod = 'wallet';
  bool _isBuying = false;
  double _walletBalance = 0;
  final WalletService _walletService = WalletService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final balance = await _walletService.getWalletBalance();
      if (!mounted) return;
      setState(() => _walletBalance = balance);
    } catch (_) {}
  }

  double get _unitPrice =>
      (num.tryParse((widget.product['price'] ?? '0').toString()) ?? 0).toDouble();
  double get _total => _unitPrice * _quantity;
  int get _stock =>
      (num.tryParse((widget.product['stock_quantity'] ?? '0').toString()) ?? 0)
          .toInt();

  Future<bool> _collectCardDetails() async {
    final cardNo = TextEditingController();
    final mmYY = TextEditingController();
    final cvv = TextEditingController();
    final holder = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Card Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: holder,
                  decoration: const InputDecoration(labelText: 'Card holder name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cardNo,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Card number'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: mmYY,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(labelText: 'MM/YY'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cvv,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'CVV'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final number = cardNo.text.replaceAll(RegExp(r'\s+'), '');
                final ok = holder.text.trim().isNotEmpty &&
                    RegExp(r'^\d{12,19}$').hasMatch(number) &&
                    RegExp(r'^\d{2}/\d{2}$').hasMatch(mmYY.text.trim()) &&
                    RegExp(r'^\d{3,4}$').hasMatch(cvv.text.trim());
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter valid card details'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Pay'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<void> _buyNow() async {
    final address = _addressController.text.trim();
    final receiverPhone = _receiverPhoneController.text.trim();
    if (address.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(receiverPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid receiver phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is out of stock')),
      );
      return;
    }
    if (_quantity > _stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only $_stock item(s) available')),
      );
      return;
    }
    if (_paymentMethod == 'wallet' && _walletBalance < _total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient wallet balance. Available: LKR ${_walletBalance.toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_paymentMethod == 'card') {
      final ok = await _collectCardDetails();
      if (!ok) return;
    }

    setState(() => _isBuying = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('${AppEnv.apiBaseUrl}/products/purchase'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': widget.product['id'],
          'quantity': _quantity,
          'payment_method': _paymentMethod,
          'shipping_address': address,
          'receiver_phone': receiverPhone,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body['success'] != true) {
        throw Exception(body['error'] ?? 'Purchase failed');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase successful!'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.product['name'] ?? 'Product').toString();
    final imageUrl = (widget.product['image_url'] ?? '').toString();
    final description = (widget.product['description'] ?? '').toString();

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldLight,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                            )
                          : Container(color: Colors.grey[300]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Text(
                        'Free Delivery',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'LKR ${_unitPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (description.isNotEmpty) ...[
                    Text(
                      description,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _quantity,
                        isExpanded: true,
                        items: List.generate(
                          _stock > 0 ? (_stock > 10 ? 10 : _stock) : 1,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('Quantity : ${i + 1}'),
                          ),
                        ),
                        onChanged: _stock > 0
                            ? (v) => setState(() => _quantity = v ?? 1)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Delivery Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Delivery address',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _receiverPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Receiver phone number',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text('Wallet (LKR ${_walletBalance.toStringAsFixed(0)})'),
                          selected: _paymentMethod == 'wallet',
                          onSelected: (_) => setState(() => _paymentMethod = 'wallet'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Card'),
                          selected: _paymentMethod == 'card',
                          onSelected: (_) => setState(() => _paymentMethod = 'card'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Ratings & Reviews (2)',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blueSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Good Quality & Good Packing\n★★★★★ D.E.Wijewardana'),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blueSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Good Material\n★★★★★ K.Shahan'),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            color: AppColors.scaffoldLight,
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isBuying ? null : _buyNow,
                child: _isBuying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Buy Now  LKR ${_total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _receiverPhoneController.dispose();
    super.dispose();
  }
}

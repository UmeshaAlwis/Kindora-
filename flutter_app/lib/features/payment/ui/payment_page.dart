import 'package:flutter/material.dart';
import 'dart:async';
import '../models/payment_model.dart';
import '../services/stripe_service.dart';
import 'package:kindora/services/wallet_service.dart';
import 'bank_transfer_page.dart';

class PaymentPage extends StatefulWidget {
  final Campaign campaign;
  final double? preSelectedAmount;
  final String? beneficiaryCampaignId;

  const PaymentPage({
    super.key,
    required this.campaign,
    this.preSelectedAmount,
    this.beneficiaryCampaignId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late TextEditingController _amountController;
  late TextEditingController _donorNameController;
  late TextEditingController _donorEmailController;
  late TextEditingController _donorPhoneController;
  late TextEditingController _wishController;
  String _selectedPaymentMethod = 'stripe';
  bool _isProcessing = false;
  bool _isAnonymous = false;
  double _walletBalance = 0.0;
  bool _loadingWallet = true;
  late StripeService _stripeService;
  late WalletService _walletService;

  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'wallet',
      name: 'Wallet',
      icon: '👛',
      description: 'Use your app wallet balance',
    ),
    PaymentMethod(
      id: 'stripe',
      name: 'Card Payments',
      icon: '💳',
      description: 'Credit/Debit Card',
    ),
    PaymentMethod(
      id: 'bank_transfer',
      name: 'Bank Transfer',
      icon: '🏦',
      description: 'Upload receipt for verification',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _donorNameController = TextEditingController();
    _donorEmailController = TextEditingController();
    _donorPhoneController = TextEditingController();
    _wishController = TextEditingController();
    _stripeService = StripeService();
    _walletService = WalletService();

    // Set pre-selected amount if provided
    if (widget.preSelectedAmount != null) {
      _amountController.text = widget.preSelectedAmount!.toStringAsFixed(0);
    }

    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    if (!mounted) return;

    setState(() => _loadingWallet = true);
    try {
      final balance = await _walletService.getWalletBalance();
      if (mounted) {
        setState(() {
          _walletBalance = balance;
          _loadingWallet = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingWallet = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load wallet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _donorNameController.dispose();
    _donorEmailController.dispose();
    _donorPhoneController.dispose();
    _wishController.dispose();
    super.dispose();
  }

  double get _donationAmount {
    return double.tryParse(_amountController.text) ?? 0.0;
  }

  void _processPayment() async {
    if (_amountController.text.isEmpty ||
        _donorNameController.text.isEmpty ||
        _donorEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Phone number is required for bank transfer only
    if (_selectedPaymentMethod == 'bank_transfer' &&
        _donorPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter phone number for bank transfer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate wallet balance for wallet payments
    if (_selectedPaymentMethod == 'wallet') {
      if (_walletBalance < _donationAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient wallet balance. Available: LKR ${_walletBalance.toStringAsFixed(2)}, Required: LKR ${_donationAmount.toStringAsFixed(2)}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final orderId =
          'kindora_${DateTime.now().millisecondsSinceEpoch.toString()}';

      final payment = Payment(
        id: orderId,
        campaignId: widget.campaign.id,
        campaignTitle: widget.campaign.title,
        amount: _donationAmount,
        paymentMethod: _selectedPaymentMethod,
        timestamp: DateTime.now(),
        status: 'Processing',
        donorName: _donorNameController.text,
        donorEmail: _donorEmailController.text,
      );

      if (_selectedPaymentMethod == 'wallet') {
        // Handle wallet payment
        await _processWalletPayment(
            payment, orderId, widget.beneficiaryCampaignId);
      } else if (_selectedPaymentMethod == 'stripe') {
        // Handle Stripe payment
        await _processStripePayment(payment, orderId);
      } else if (_selectedPaymentMethod == 'bank_transfer') {
        // Handle bank transfer
        await _processBankTransfer(payment);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processWalletPayment(
      Payment payment, String orderId, String? beneficiaryCampaignId) async {
    try {
      // Process wallet payment through the service
      await _walletService.processWalletPayment(
        amount: _donationAmount,
        campaignId: widget.campaign.id,
        beneficiaryCampaignId: beneficiaryCampaignId,
        donorName: _donorNameController.text,
        donorEmail: _donorEmailController.text,
      );

      if (!mounted) return;

      // Show success dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet donation successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Update wallet balance
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _walletBalance -= _donationAmount;
        });
      }

      // Navigate back after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallet payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processStripePayment(Payment payment, String orderId) async {
    try {
      // Step 1: Create payment intent on backend
      final intentData = await _stripeService.createPaymentIntent(
        amount: _donationAmount,
        donorName: _donorNameController.text,
        donorEmail: _donorEmailController.text,
        campaignId: widget.campaign.id,
        currency: 'USD', // Change to LKR if Stripe supports it
      );

      final clientSecret = intentData['client_secret'] ?? '';
      final customerId = intentData['customer_id'] ?? '';

      if (clientSecret.isEmpty) {
        throw Exception('Failed to get client secret from server');
      }

      // Step 2: Initialize payment sheet
      await _stripeService.initPaymentSheet(
        clientSecret: clientSecret,
        customerId: customerId,
      );

      // Step 3: Present payment sheet to user
      final success = await _stripeService.presentPaymentSheet();

      if (success) {
        if (!mounted) return;

        // Success - Payment completed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );

        if (mounted) {
          setState(() => _isProcessing = false);
        }

        // Navigate back after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      final errorMessage = e.toString();

      // Check if user cancelled
      if (errorMessage.contains('cancelled')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else if (errorMessage.contains('401') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('authentication')) {
        // Stripe authentication issue - suggest alternative payment method
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Card payment temporarily unavailable. Please use Bank Transfer or Wallet.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          // Reset to bank transfer but user should switch method
          setState(() => _selectedPaymentMethod = 'bank_transfer');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Payment failed: Unable to process. Try another method.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _processBankTransfer(Payment payment) async {
    setState(() => _isProcessing = false);

    if (mounted) {
      // Navigate to bank transfer page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BankTransferPage(
            campaign: widget.campaign,
            amount: _donationAmount,
            donorName: _donorNameController.text,
            donorEmail: _donorEmailController.text,
            donorPhone: _donorPhoneController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campaign.title),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information Banner
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transaction only via application!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Donation Amount Section (Simplified)
            const Text(
              'Donation Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: 'LKR',
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'LKR', child: Text(' LKR')),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Donor Information Section
            const Text(
              'Donor Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _donorNameController,
              decoration: InputDecoration(
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _donorEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedPaymentMethod == 'bank_transfer')
              TextField(
                controller: _donorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() => _isAnonymous = value ?? false);
                  },
                ),
                const Expanded(
                  child: Text(
                    'Hide your name as anonym',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Write your wish and encouragement',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _wishController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                counterText: '${_wishController.text.length}/200',
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),

            // Payment Method Section
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...paymentMethods.map((method) {
              final isWallet = method.id == 'wallet';
              final walletDisplay = isWallet
                  ? ' (Balance: LKR ${_walletBalance.toStringAsFixed(2)})'
                  : '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedPaymentMethod = method.id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPaymentMethod == method.id
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[300]!,
                        width: _selectedPaymentMethod == method.id ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Radio<String>(
                        value: method.id,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() => _selectedPaymentMethod = value!);
                        },
                      ),
                      title: Row(
                        children: [
                          Text(method.icon,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.name + walletDisplay,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  method.description ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Order Summary
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Donation Amount:'),
                      Text(
                        'LKR ${_donationAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (_selectedPaymentMethod != 'wallet' &&
                      _selectedPaymentMethod != 'stripe') ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Processing Fee:'),
                        Text(
                          'LKR ${(_donationAmount * 0.02).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'LKR ${(_selectedPaymentMethod == 'wallet' || _selectedPaymentMethod == 'stripe' ? _donationAmount : _donationAmount + (_donationAmount * 0.02)).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Donate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001A4D),
                  disabledBackgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.payment),
                label: Text(
                  _isProcessing ? 'Processing...' : 'Donate Now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Security Info
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment information is secured with SSL encryption',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

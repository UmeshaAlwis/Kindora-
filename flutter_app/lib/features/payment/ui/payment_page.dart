import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import 'payhere_payment_webview.dart';
import 'bank_transfer_page.dart';

class PaymentPage extends StatefulWidget {
  final Campaign campaign;

  const PaymentPage({
    super.key,
    required this.campaign,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late TextEditingController _amountController;
  late TextEditingController _donorNameController;
  late TextEditingController _donorEmailController;
  late TextEditingController _donorPhoneController;
  String _selectedPaymentMethod = 'card_payment';
  bool _isProcessing = false;

  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'card_payment',
      name: 'Card Payment',
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
  }

  @override
  void dispose() {
    _amountController.dispose();
    _donorNameController.dispose();
    _donorEmailController.dispose();
    _donorPhoneController.dispose();
    super.dispose();
  }

  double get _donationAmount {
    return double.tryParse(_amountController.text) ?? 0.0;
  }

  void _processPayment() async {
    if (_amountController.text.isEmpty ||
        _donorNameController.text.isEmpty ||
        _donorEmailController.text.isEmpty ||
        _donorPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
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

      if (_selectedPaymentMethod == 'card_payment') {
        // Handle card payment via PayHere gateway
        await _processPayHerePayment(payment, orderId);
      } else if (_selectedPaymentMethod == 'bank_transfer') {
        // Handle bank transfer
        await _processBankTransfer(payment);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

  Future<void> _processPayHerePayment(Payment payment, String orderId) async {
    try {
      if (mounted) {
        setState(() => _isProcessing = false);

        // Update payment object with phone number
        payment = Payment(
          id: payment.id,
          campaignId: payment.campaignId,
          campaignTitle: payment.campaignTitle,
          amount: payment.amount,
          paymentMethod: payment.paymentMethod,
          timestamp: payment.timestamp,
          status: payment.status,
          donorName: payment.donorName,
          donorEmail: payment.donorEmail,
          donorPhone: _donorPhoneController.text,
        );

        // Navigate to PayHere WebView checkout screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PayHerePaymentWebView(
                payment: payment,
                orderRef: orderId,
                campaignTitle: widget.campaign.title,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PayHere Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Campaign'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Summary Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.campaign.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.campaign.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Target: LKR ${widget.campaign.targetAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widget.campaign.raisedAmount /
                                widget.campaign.targetAmount,
                            minHeight: 4,
                            backgroundColor: Colors.grey[200],
                            color: const Color(0xFFFF751F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Donation Amount Section
            const Text(
              'Donation Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'LKR ',
                hintText: 'Enter amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickAmountButton(500),
                _quickAmountButton(1000),
                _quickAmountButton(5000),
                _quickAmountButton(10000),
              ],
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
            TextField(
              controller: _donorPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Phone Number (Required for PayHere)',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
                                  method.name,
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
                        'LKR ${(_donationAmount + (_donationAmount * 0.02)).toStringAsFixed(2)}',
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

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
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
                  _isProcessing ? 'Processing...' : 'Complete Payment',
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

  Widget _quickAmountButton(double amount) {
    return ElevatedButton(
      onPressed: () {
        _amountController.text = amount.toStringAsFixed(0);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _donationAmount == amount
            ? const Color(0xFFFF751F)
            : Colors.grey[200],
        foregroundColor:
            _donationAmount == amount ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        'LKR ${amount.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

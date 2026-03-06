import 'package:flutter/material.dart';
import '../pages/payment_method_page.dart';

class DonationBottomSheet extends StatefulWidget {
  final String charityId;
  final String charityName;

  const DonationBottomSheet({
    Key? key,
    required this.charityId,
    required this.charityName,
  }) : super(key: key);

  @override
  State<DonationBottomSheet> createState() => _DonationBottomSheetState();
}

class _DonationBottomSheetState extends State<DonationBottomSheet> {
  final List<double> suggestedAmounts = [15000, 25000, 50000, 100000];
  final TextEditingController _customAmountController = TextEditingController();
  double? selectedAmount;
  String selectedCurrency = 'LKR';
  final double minimumDonation = 15000;

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _handleAmountSelection(double amount) {
    setState(() {
      selectedAmount = amount;
      _customAmountController.clear();
    });
  }

  void _handleCustomAmount(String value) {
    if (value.isNotEmpty) {
      setState(() {
        selectedAmount = double.tryParse(value);
      });
    }
  }

  void _proceedToPayment() {
    if (selectedAmount == null || selectedAmount! < minimumDonation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum donation is $selectedCurrency${minimumDonation.toStringAsFixed(0)}',
          ),
        ),
      );
      return;
    }

    // Navigate to payment method selection page
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodPage(
          charityId: widget.charityId,
          charityName: widget.charityName,
          amount: selectedAmount!,
          currency: selectedCurrency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add your donation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Suggested amounts section
              Text(
                'Choose your nominal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // Suggested amount buttons
              ...suggestedAmounts.map((amount) {
                return GestureDetector(
                  onTap: () => _handleAmountSelection(amount),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedAmount == amount
                            ? Colors.blue
                            : Colors.grey[300]!,
                        width: selectedAmount == amount ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: selectedAmount == amount
                          ? Colors.blue.withValues(alpha: 0.05)
                          : Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.currency_exchange,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$selectedCurrency${amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              // Custom amount section
              Text(
                'Other nominal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // Custom amount input
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: DropdownButton<String>(
                      value: selectedCurrency,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'LKR', child: Text('LKR')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedCurrency = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _customAmountController,
                      keyboardType: TextInputType.number,
                      onChanged: _handleCustomAmount,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Minimum donation note
              Text(
                'The minimum donation is $selectedCurrency${minimumDonation.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              // Payment button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A), // Dark blue
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

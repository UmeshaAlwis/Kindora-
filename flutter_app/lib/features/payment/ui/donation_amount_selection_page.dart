import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import 'payment_page.dart';

class DonationAmountSelectionModal extends StatefulWidget {
  final Campaign campaign;

  const DonationAmountSelectionModal({
    super.key,
    required this.campaign,
  });

  @override
  State<DonationAmountSelectionModal> createState() =>
      _DonationAmountSelectionModalState();
}

class _DonationAmountSelectionModalState
    extends State<DonationAmountSelectionModal> {
  double? _selectedAmount;
  late TextEditingController _customAmountController;

  final List<double> predefinedAmounts = [15000, 25000, 50000, 100000];

  @override
  void initState() {
    super.initState();
    _customAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    final amount =
        _selectedAmount ?? double.tryParse(_customAmountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter a valid donation amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Close the modal and navigate to payment page
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          campaign: widget.campaign,
          preSelectedAmount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child:
                      const Icon(Icons.close, size: 24, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add your donation',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          // Main content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Choose your nominal section - collapsible
                  GestureDetector(
                    onTap: () {
                      // Add collapse/expand functionality if needed
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Choose your nominal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Icon(
                          Icons.expand_less,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Predefined Amount Buttons
                  ...predefinedAmounts.map((amount) {
                    final isSelected = _selectedAmount == amount;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAmount = amount;
                            _customAmountController.clear();
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF0F8FF)
                                : Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected
                                    ? const Color(0xFFFF751F)
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Orange rupee icon
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFF751F),
                                ),
                                child: const Center(
                                  child: Text(
                                    '₨',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'LKR ${amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFFFF751F)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFFF751F),
                                      size: 22,
                                    )
                                  : Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
                                      size: 22,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Other nominal (Custom Amount)
                  const Text(
                    'Other nominal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextField(
                            controller: _customAmountController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _selectedAmount = null;
                              });
                            },
                            decoration: const InputDecoration(
                              prefixText: 'LKR ',
                              prefixStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFC0C0C0),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Minimum donation note in teal/green
                  const Text(
                    'The minimum donation is LKR50,000',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A9B7F),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001A4D),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Payment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

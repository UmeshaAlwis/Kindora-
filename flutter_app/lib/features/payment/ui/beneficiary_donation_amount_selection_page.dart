import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import 'payment_page.dart';

class BeneficiaryDonationAmountSelectionModal extends StatefulWidget {
  final Campaign campaign;
  final String beneficiaryCampaignId;

  const BeneficiaryDonationAmountSelectionModal({
    super.key,
    required this.campaign,
    required this.beneficiaryCampaignId,
  });

  @override
  State<BeneficiaryDonationAmountSelectionModal> createState() =>
      _BeneficiaryDonationAmountSelectionModalState();
}

class _BeneficiaryDonationAmountSelectionModalState
    extends State<BeneficiaryDonationAmountSelectionModal> {
  double? _selectedAmount;
  late TextEditingController _customAmountController;

  String _donationType = 'one-time';
  String _recurringFrequency = 'monthly';
  DateTime? _recurringEndDate;

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

  Future<void> _selectRecurringEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 10, now.month, now.day),
    );
    if (picked == null) return;
    setState(() {
      _recurringEndDate = picked;
    });
  }

  Future<void> _proceedToPayment() async {
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

    if (_donationType == 'recurring') {
      if (_recurringEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a recurring end date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (!_recurringEndDate!.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date must be in the future'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Navigate to payment page; keep the bottom sheet open until payment completes.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          campaign: widget.campaign,
          preSelectedAmount: amount,
          beneficiaryCampaignId: widget.beneficiaryCampaignId,
          donationType: _donationType,
          recurringFrequency: _recurringFrequency,
          recurringEndDate: _recurringEndDate,
        ),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, result == true);
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
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF751F)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? const Color(0xFFFF751F)
                                    .withValues(alpha: 0.05)
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFF751F)
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFFF751F),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'LKR ${amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFFFF751F)
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Custom Amount Section
                  Text(
                    'Or enter your own amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _selectedAmount = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter amount (LKR)',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      prefixText: 'LKR ',
                      prefixStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
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
                        borderSide: const BorderSide(
                            color: Color(0xFFFF751F), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Donation Type
                  const Text(
                    'Donation Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('One-time'),
                          selected: _donationType == 'one-time',
                          onSelected: (selected) {
                            setState(() {
                              _donationType = 'one-time';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Recurring'),
                          selected: _donationType == 'recurring',
                          onSelected: (selected) {
                            setState(() {
                              _donationType = 'recurring';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_donationType == 'recurring') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Frequency',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _recurringFrequency,
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                        DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _recurringFrequency = v;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Recurring end date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _selectRecurringEndDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFFF751F)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _recurringEndDate == null
                            ? 'Select end date'
                            : _recurringEndDate!
                                .toIso8601String()
                                .substring(0, 10),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF751F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Recurring is processed using Wallet payments.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],

                  // Proceed Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF751F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _proceedToPayment,
                      child: const Text(
                        'Continue to Payment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

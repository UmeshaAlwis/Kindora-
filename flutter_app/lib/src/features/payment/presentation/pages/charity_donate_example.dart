import 'package:flutter/material.dart';
import '../widgets/payment_helper.dart';

// Example: How to use the donation modal in your charity list or detail page
class CharityDonateExample extends StatelessWidget {
  final String charityId;
  final String charityName;

  const CharityDonateExample({
    Key? key,
    required this.charityId,
    required this.charityName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showDonationModal(context),
      child: const Text('Donate Now'),
    );
  }

  void _showDonationModal(BuildContext context) {
    PaymentHelper.showDonationModal(
      context: context,
      charityId: charityId,
      charityName: charityName,
      onDonationSelected: (donationData) {
        // Handle donation data
        print('Donation Data: $donationData');

        // Donation data structure:
        // {
        //   'charityId': String,
        //   'amount': double,
        //   'currency': String,
        // }

        // You can:
        // 1. Navigate to payment processing page
        // 2. Call API to create donation record
        // 3. Process payment through payment gateway

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Processing donation of ${donationData['currency']}${donationData['amount']}',
            ),
          ),
        );
      },
    );
  }
}

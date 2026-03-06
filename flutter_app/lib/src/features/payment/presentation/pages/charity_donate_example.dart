import 'package:flutter/material.dart';
import '../widgets/payment_helper.dart';
import '../../../../core/services/donation_service.dart';

// Example: How to use the donation modal in your charity list or detail page
class CharityDonateExample extends StatefulWidget {
  final String charityId;
  final String charityName;

  const CharityDonateExample({
    Key? key,
    required this.charityId,
    required this.charityName,
  }) : super(key: key);

  @override
  State<CharityDonateExample> createState() => _CharityDonateExampleState();
}

class _CharityDonateExampleState extends State<CharityDonateExample> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _showDonationModal,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Donate Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
    );
  }

  void _showDonationModal() {
    PaymentHelper.showDonationModal(
      context: context,
      charityId: widget.charityId,
      charityName: widget.charityName,
      onDonationSelected: (donationData) async {
        // Handle donation data
        debugPrint('Donation Data: $donationData');

        // Donation data structure:
        // {
        //   'charityId': String,
        //   'amount': double,
        //   'currency': String,
        // }

        // Save donation to database
        setState(() => _isLoading = true);

        final result = await DonationService.createDonation(
          charityId: donationData['charityId'] as String,
          amount: donationData['amount'] as double,
          currency: donationData['currency'] as String,
          paymentMethod: 'mobile_payment',
        );

        if (!mounted) return;

        setState(() => _isLoading = false);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Donation of ${donationData['currency']}${donationData['amount']} saved successfully!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${result['message']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}

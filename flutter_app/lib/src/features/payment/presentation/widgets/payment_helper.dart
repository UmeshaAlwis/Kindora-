import 'package:flutter/material.dart';
import 'donation_bottom_sheet.dart';

class PaymentHelper {
  static void showDonationModal({
    required BuildContext context,
    required String charityId,
    required String charityName,
    required Function(Map<String, dynamic>) onDonationSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => DonationBottomSheet(
        charityId: charityId,
        charityName: charityName,
      ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        onDonationSelected(result);
      }
    });
  }
}

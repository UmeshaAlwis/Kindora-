import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'choose_payment_page.dart';

class DonationSheet extends StatefulWidget {
  const DonationSheet({super.key});

  @override
  State<DonationSheet> createState() => _DonationSheetState();
}

class _DonationSheetState extends State<DonationSheet> {

  String selectedAmount = "15000";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add your donation",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 16),

            /// Preset Amount Buttons
            _amountButton("LKR 15,000"),
            _amountButton("LKR 25,000"),
            _amountButton("LKR 50,000"),
            _amountButton("LKR 100,000"),

            const SizedBox(height: 12),

            /// Custom Amount
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Other amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C0C79),
                ),
                onPressed: () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ChoosePaymentPage(),
    ),
  );
},
                child: const Text("Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountButton(String amount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[100],
        title: Text(amount),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          setState(() {
            selectedAmount = amount;
          });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DonationAmountScreen extends StatelessWidget {
  final String campaignName;

  const DonationAmountScreen({super.key, required this.campaignName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donate to $campaignName')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Example of amount buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['\$10', '\$50', '\$100'].map((amount) {
                return ElevatedButton(
                  onPressed: () {},
                  child: Text(amount),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            const TextField(
              decoration: InputDecoration(
                labelText: "Enter Custom Amount",
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1F3D)),
                onPressed: () {
                  // Next step: Go to payment/wallet
                },
                child: const Text("Confirm Donation", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
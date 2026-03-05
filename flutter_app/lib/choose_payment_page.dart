import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChoosePaymentPage extends StatelessWidget {
  const ChoosePaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Choose Payment Method",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _paymentTile("Bank of Ceylon"),
            _paymentTile("Commercial Bank"),
            _paymentTile("Sampath Bank"),
            _paymentTile("People's Bank"),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile(String name) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(name),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}

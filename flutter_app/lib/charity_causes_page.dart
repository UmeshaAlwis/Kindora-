import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/campaign_services.dart';

class CharityCausesPage extends StatefulWidget {
  const CharityCausesPage({super.key});

  @override
  State<CharityCausesPage> createState() => _CharityCausesPageState();
}

class _CharityCausesPageState extends State<CharityCausesPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Charity Causes",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: const Center(
        child: Text("Loading causes..."),
      ),
    );
  }
}
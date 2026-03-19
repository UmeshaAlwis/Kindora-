import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/campaign_services.dart';

class CharityCausesPage extends StatefulWidget {
  const CharityCausesPage({super.key});

  @override
  State<CharityCausesPage> createState() => _CharityCausesPageState();
}

class _CharityCausesPageState extends State<CharityCausesPage> {
  
  // fetch causes from Supabase
  late Future<List<dynamic>> causes;

  @override
  void initState() {
    super.initState();
    causes = CampaignService().getCharityCauses();
  }

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
      body: FutureBuilder<List<dynamic>>(
        future: causes,
        builder: (context, snapshot) {

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text("Causes will appear here!"));
        },
      ),
    );
  }
}
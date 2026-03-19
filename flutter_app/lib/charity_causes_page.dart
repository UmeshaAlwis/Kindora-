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
          // Error state
    if (snapshot.hasError) {
      return Center(
        child: Text(
          "Something went wrong!\n${snapshot.error}",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.red,
          ),
        ),
      );
    }
     // Empty state
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism,
                size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No causes available yet.",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
        return const Center(child: Text("Causes will appear here!"));
      },
      ),
    );
  }
}
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
     
          final data = snapshot.data!;

return ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: data.length,
  itemBuilder: (context, index) {
    final cause = data[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Image 
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16)),
            child: Image.network(
              cause['image_url'] ??
                  "https://images.unsplash.com/photo-1593113630400-ea4288922497",
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 160,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported,
                    size: 40, color: Colors.grey),
              ),
            ),
          ),

        ],
      ),
    );
  },
);
        },
      ),
    );
  }
}
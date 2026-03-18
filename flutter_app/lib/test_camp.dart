import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'campaign_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CampaignHomePage(),
    ),
  );
}
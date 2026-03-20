import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// 1. Update the import to point to your recommendation screen file
import 'package:kindora/screens/recommendation_screen.dart';

void main() {
  runApp(const KindoraApp());
}

class KindoraApp extends StatelessWidget {
  const KindoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kindora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Brand Blue: #0C0C79
        primaryColor: const Color(0xFF0C0C79),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      // 2. Set the home to RecommendationScreen
      home: const RecommendationScreen(),
    );
  }
}
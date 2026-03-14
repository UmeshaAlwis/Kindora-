import 'package:flutter/material.dart';

class RecommendationDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  const RecommendationDetailScreen({
    super.key,
    required this.title,
    required this.description
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("Details for $title")),
    );
  }
}
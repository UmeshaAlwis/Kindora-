import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_controller.dart';
import 'core/auth_gate.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const KindoraApp(),
    ),
  );
}

class KindoraApp extends StatelessWidget {
  const KindoraApp({super.key});

  @override
  Widget build(BuildContext context) {

    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: "Kindora",
      debugShowCheckedModeBanner: false,

      themeMode: themeController.themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0C0C79),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),

      home: const AuthGate(),
    );
  }
}
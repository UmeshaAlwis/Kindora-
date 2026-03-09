import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/theme_controller.dart';
import 'core/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// SUPABASE INITIALIZATION
  await Supabase.initialize(
    url: 'https://ucxqakixdpqqmbbpeptm.supabase.co',
    anonKey: ' sb_publishable_frgCObr7FwO2W_Egb6EH-Q_slJAljVE',
  );

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

    const primaryColor = Color(0xFF0C0C79);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kindora",

      themeMode: themeController.themeMode,

      /// LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,

        scaffoldBackgroundColor: Colors.white,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(primaryColor),
          trackColor: MaterialStateProperty.all(
            primaryColor.withOpacity(0.4),
          ),
        ),

        listTileTheme: const ListTileThemeData(
          iconColor: primaryColor,
        ),
      ),

      /// DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF121212),

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        cardColor: const Color(0xFF1E1E1E),

        dividerColor: Colors.grey,

        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(primaryColor),
          trackColor: MaterialStateProperty.all(
            primaryColor.withOpacity(0.5),
          ),
        ),

        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white70,
        ),
      ),

      home: const AuthGate(),
    );
  }
}
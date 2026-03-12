import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/routes/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  /// FIREBASE (for login, signup, google auth)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// SUPABASE (for profile database)
  await Supabase.initialize(
    url: 'https://ucxqakixdpqqmbbpeptm.supabase.co',
    anonKey: ' sb_publishable_frgCObr7FwO2W_Egb6EH-Q_slJAljVEY',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final themeController = context.watch<ThemeController>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      /// Light Theme
      theme: ThemeData.light(),

      /// Dark Theme
      darkTheme: ThemeData.dark(),

      /// Controlled by Settings page toggle
      themeMode: themeController.themeMode,
    );
  }
}
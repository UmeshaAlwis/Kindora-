import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kindora/l10n/app_localizations.dart';

import 'config/routes/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'core/language/language_controller.dart';

import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  /// FIREBASE (login, signup, google auth)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// SUPABASE (profile database)
  await Supabase.initialize(
    url: 'https://ucxqakixdpqqmbbpeptm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjeHFha2l4ZHBxcW1iYnBlcHRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1MzY1NDcsImV4cCI6MjA4NjExMjU0N30.lqbexF_zdeKXtcwpG-Ou0rw1IaBhYsMIgWa2yHfxDBY',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LanguageController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final themeController = context.watch<ThemeController>();
    final languageController = context.watch<LanguageController>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      /// Light Theme
      theme: ThemeData.light(),

      /// Dark Theme
      darkTheme: ThemeData.dark(),

      /// Controlled by Settings page
      themeMode: themeController.themeMode,

      /// LANGUAGE SUPPORT
      locale: languageController.locale,

      supportedLocales: const [
        Locale('en'),
        Locale('si'),
        Locale('ta'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
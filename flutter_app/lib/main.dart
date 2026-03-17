import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'config/themes/app_theme.dart';
import 'config/routes/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load();
    print('✓ .env file loaded from filesystem');
  } catch (e) {
    print('ℹ Could not load .env from filesystem, trying assets...');
    try {
      // Try loading from assets as fallback
      final envString = await rootBundle.loadString('.env');
      // Parse the env string and set it manually
      final lines = envString.split('\n');
      for (var line in lines) {
        if (line.isNotEmpty && !line.startsWith('#')) {
          final parts = line.split('=');
          if (parts.length == 2) {
            dotenv.env[parts[0].trim()] = parts[1].trim();
          }
        }
      }
      print('✓ .env file loaded from assets');
    } catch (assetError) {
      print('⚠ Could not load .env file: $assetError');
      // Continue without .env - will use empty defaults
    }
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized');
  } catch (e) {
    print('⚠ Firebase initialization error: $e');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    print('✓ Supabase initialized');
  } catch (e) {
    print('⚠ Supabase initialization error: $e');
  }

  // Initialize Stripe
  try {
    final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    if (stripeKey.isNotEmpty) {
      Stripe.publishableKey = stripeKey;
      await Stripe.instance.applySettings();
      print('✓ Stripe initialized');
    }
  } catch (e) {
    print('⚠ Stripe initialization error: $e');
    // Continue anyway - Stripe not critical for app startup
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme provider to rebuild when it changes
    final isDarkMode = ref.watch(themeProvider);

    // Watch the language provider to rebuild when it changes
    final currentLocale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'Kindora - Charity Platform',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: currentLocale,
      supportedLocales: supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

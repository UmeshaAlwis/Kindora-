import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/chat_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚫 Removed: Firebase, Supabase, Stripe, dotenv
  // (You can re-add later safely)

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: ChatWindow(),
        ),
      ),
    );
  }
}
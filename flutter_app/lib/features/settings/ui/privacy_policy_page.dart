import 'package:flutter/material.dart';
import 'package:kindora/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {

    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.privacyPolicy),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            '''
Kindora Privacy Policy

We respect your privacy.

Information we collect:
• Name
• Email
• Donation history

How we use your data:
• Process donations
• Improve transparency
• Provide notifications

Your data is never sold.

Kindora © 2026
''',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
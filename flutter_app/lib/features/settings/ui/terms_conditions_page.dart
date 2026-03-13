import 'package:flutter/material.dart';
import 'package:kindora/l10n/app_localizations.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.termsConditions),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            '''
Kindora Terms & Conditions

By using Kindora you agree to the following terms:

• Donations are voluntary.
• Campaign creators are responsible for their content.
• Kindora ensures transparency but cannot guarantee campaign outcomes.

Users must not misuse the platform.

Kindora reserves the right to suspend accounts that violate policies.

Kindora Team © 2026
''',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
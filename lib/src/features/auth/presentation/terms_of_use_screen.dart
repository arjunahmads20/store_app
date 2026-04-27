import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Use')),
      body: SafeArea(
        bottom: true,
        top: false,
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Terms of Use\n\n'
            '1. Acceptance: By using this app ...\n\n'
            '2. Rules: You agree to ...\n\n'
            '3. Termination: We may terminate ...\n\n'
            '(This is a placeholder for the actual terms of use)',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

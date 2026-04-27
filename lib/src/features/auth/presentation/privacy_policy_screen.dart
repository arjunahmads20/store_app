import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SafeArea(
        bottom: true,
        top: false,
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Privacy Policy\n\n'
            '1. Data Collection: We collect ...\n\n'
            '2. Usage: Your data is used for ...\n\n'
            '3. Sharing: We do not share ...\n\n'
            '(This is a placeholder for the actual privacy policy)',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

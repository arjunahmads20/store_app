import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: true,
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Check Your Email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We have sent a password recover instructions to your email.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // In a real app, this might open the email app
                  // For this flow, we simulate the user clicking the link by navigating to ResetPassword
                  context.push('/reset-password');
                },
                child: const Text('Open Email App (Simulate Link Click)'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('Skip, I\'ll confirm later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

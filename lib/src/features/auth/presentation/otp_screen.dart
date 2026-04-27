import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/auth/presentation/auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? registrationData; // Passed from Register
  const OtpScreen({super.key, this.registrationData});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _start = 30;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _start = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _onVerify() async {
    if (_otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid 6-digit OTP')),
      );
      return;
    }

    // Check if this is Registration flow or Forgot Password flow
    // For now assuming registration flow if data is present
    if (widget.registrationData != null) {
      final controller = ref.read(authControllerProvider.notifier);
      await controller.verifyRegistration(
        registrationData: widget.registrationData!,
        otp: _otpController.text,
      );

      if (mounted) {
        final state = ref.read(authControllerProvider);
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${state.error}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification Successful!')),
          );
          context.go('/');
        }
      }
    } else {
      // TODO: Forgot password flow
    }
  }

  void _onResend() {
    // TODO: Implement Resend API call
    startTimer();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP Resent!')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.registrationData != null
                    ? 'We have sent a verification code to ${widget.registrationData!['phone_number']}.'
                    : 'We have sent a verification code to your phone number.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Simple OTP Input
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _onVerify,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive code? "),
                  _start > 0
                      ? Text(
                          'Resend in $_start s',
                          style: const TextStyle(color: Colors.grey),
                        )
                      : TextButton(
                          onPressed: _onResend,
                          child: const Text('Resend Again'),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

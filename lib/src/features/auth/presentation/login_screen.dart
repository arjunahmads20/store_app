import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/auth/presentation/auth_controller.dart';
import 'package:store_app/src/core/animations/shake_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(authControllerProvider.notifier);
      await controller.login(
        _phoneController.text,
        _passwordController.text,
      );

      if (mounted) {
        final state = ref.read(authControllerProvider);
        if (state.hasError) {
          // Trigger shake animation on error
          _shakeKey.currentState?.shake();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${state.error}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       // Logo Image
                       ConstrainedBox(
                         constraints: const BoxConstraints(maxHeight: 120, maxWidth: 200),
                         child: Image.asset(
                           'images/sayursa_logo_transparent.png',
                           fit: BoxFit.contain,
                           errorBuilder: (context, error, stackTrace) {
                             // Fallback if image is missing
                             return Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Icon(Icons.image_not_supported, size: 80, color: Colors.white.withOpacity(0.5)),
                                 const SizedBox(height: 8),
                                 Text(
                                   'Place logo.png in\nassets/images/',
                                   textAlign: TextAlign.center,
                                   style: TextStyle(color: Colors.white.withOpacity(0.8)),
                                 )
                               ],
                             );
                           },
                         ),
                       ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Login Card
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.0, 
                  right: 24.0, 
                  top: 220, 
                  bottom: MediaQuery.of(context).padding.bottom + 32,
                ),
                child: ShakeWidget(
                key: _shakeKey,
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please login to continue',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          Consumer(
                            builder: (context, ref, child) {
                              final state = ref.watch(authControllerProvider);
                              if (!state.hasError) return const SizedBox.shrink();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.error.toString(),
                                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          
                          // Phone Input
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_android_rounded),
                              hintText: 'e.g., 08123456789',
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Digits only';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_rounded),
                            ),
                            obscureText: true,
                            validator: (value) => value!.isEmpty ? 'Required' : null,
                          ),
                          
                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ref.read(authControllerProvider.notifier).clearError();
                                context.push('/forgot-password');
                              },
                              child: const Text('Forgot Password?', 
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Login Button
                          Consumer(
                            builder: (context, ref, child) {
                              final state = ref.watch(authControllerProvider);
                              return SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: state.isLoading ? null : _onLogin,
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 24, width: 24, 
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                        )
                                      : const Text('Login', style: TextStyle(fontSize: 16)),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("New here? ", style: TextStyle(color: AppColors.textSecondary)),
                              GestureDetector(
                                onTap: () {
                                  ref.read(authControllerProvider.notifier).clearError();
                                  context.go('/register');
                                },
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/src/features/auth/presentation/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';


class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedGender;
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_agreeToTerms) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please agree to the Terms and Privacy Policy')),
       );
       return;
    }
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(authControllerProvider.notifier);
      await controller.registerRequestOtp(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneController.text,
        gender: _selectedGender!,
        dateOfBirth: _dobController.text,
      );

      if (mounted) {
        final state = ref.read(authControllerProvider);
         if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${state.error}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent. Please verify your phone.')),
          );
          
          final registrationData = {
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'confirm_password': _confirmPasswordController.text,
            'phone_number': _phoneController.text,
            'gender': _selectedGender,
            'date_of_birth': _dobController.text,
          };
          
          context.go('/otp', extra: registrationData);
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
              height: 250, // slightly shorter to leave room
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          ref.read(authControllerProvider.notifier).clearError();
                          context.go('/login');
                        },
                      ),
                      const SizedBox(height: 0),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 70, maxWidth: 160),
                          child: Image.asset(
                            'images/sayursa_logo_transparent.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported, size: 60, color: Colors.white54);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Register Card
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.0, 
                  right: 24.0, 
                  top: 150, // Allows card to overlap the header and scroll up
                  bottom: MediaQuery.of(context).padding.bottom + 32, // Prevent nav bar overflow
                ),
                child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
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
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(labelText: 'First Name'),
                                validator: (v) => v?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(labelText: 'Last Name'),
                                validator: (v) => v?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Gender & DOB Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: const InputDecoration(labelText: 'Gender'),
                                items: const [
                                  DropdownMenuItem(value: 'male', child: Text('Male')),
                                  DropdownMenuItem(value: 'female', child: Text('Female')),
                                ],
                                onChanged: (val) => setState(() => _selectedGender = val),
                                validator: (v) => v == null ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _dobController,
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth',
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    // Format YYYY-MM-DD
                                    final formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                    _dobController.text = formatted;
                                  }
                                },
                                validator: (v) => v?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email (Optional)',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(v)) return 'Invalid email format';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: 'e.g. 08123456789',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                             if (v == null || v.isEmpty) return 'Required';
                             if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Digits only';
                             if (v.length < 10 || v.length > 15) return 'Invalid phone number length';
                             return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 8) return 'Min 8 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Required';
                            if (v != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms, 
                              onChanged: (v) {
                                setState(() {
                                  _agreeToTerms = v ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  const Text('I agree to the '),
                                  InkWell(
                                    onTap: () => context.push('/terms-of-use'),
                                    child: const Text('Terms of Use', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ),
                                  const Text(' and '),
                                  InkWell(
                                    onTap: () => context.push('/privacy-policy'),
                                    child: const Text('Privacy Policy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Consumer(
                          builder: (context, ref, child) {
                            final state = ref.watch(authControllerProvider);
                            return SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : _onRegister,
                                child: state.isLoading
                                    ? const SizedBox(
                                        height: 24, width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                      )
                                    : const Text('Register', style: TextStyle(fontSize: 16)),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                            GestureDetector(
                              onTap: () {
                                ref.read(authControllerProvider.notifier).clearError();
                                context.go('/login');
                              },
                              child: Text(
                                'Login',
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
        ],
      ),
    );
  }
}

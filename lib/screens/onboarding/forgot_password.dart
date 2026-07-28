import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/onboarding/reset_password.dart';
import 'package:quest/components/onboarding_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _contactController = TextEditingController();

  void _handleRequestOtp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isEmailMode = authProvider.otpMethod == 'smtp';
    final contact = _contactController.text.trim();

    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEmailMode
              ? 'Please enter your email address.'
              : 'Please enter your phone number or email.'),
        ),
      );
      return;
    }

    // Password reset always requires OTP regardless of signup OTP setting
    final result = await authProvider.sendOtp(contact, purpose: 'reset');

    if (mounted) {
      if (result.success) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to send OTP.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Standardized input decoration matching the LoginScreen
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(
          color: theme.primaryColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.grey.shade500,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Back Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 22,
                  color: Colors.black87,
                ),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 20),

              // Scrollable Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo & Header
                      Image.asset(
                        'assets/images/lock.png',
                        width: 90,
                        height: 90,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Forgot Password',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your registered contact to receive an OTP to reset your password.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Contact Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            authProvider.otpMethod == 'smtp'
                                ? 'Email Address'
                                : 'Phone Number or Email',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _contactController,
                        keyboardType: authProvider.otpMethod == 'smtp'
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleRequestOtp(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: inputDecoration.copyWith(
                          hintText: authProvider.otpMethod == 'smtp'
                              ? 'you@example.com'
                              : 'Enter contact info',
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OnboardingButton(
                    title: 'Send OTP',
                    isLoading: authProvider.isLoading,
                    ontap: _handleRequestOtp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/onboarding/login.dart';
import 'package:quest/components/onboarding_button.dart';
// fallback if we want to add an explicit register text button, but GetStarted is main entry.

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleResetPassword() async {
    final code = _codeController.text.trim();
    final newPassword = _passwordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please request OTP again.'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    final success = await authProvider.resetPassword(
      authProvider.contact!,
      code,
      newPassword,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully. Please log in.'),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Failed to reset password.',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/lock.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Reset Password',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Enter the OTP code sent to your contact and set a new password.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OTP Code',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText: "Enter 4-digit code",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Password',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter new password",
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OnboardingButton(
                    title: 'Reset Password',
                    isLoading: authProvider.isLoading,
                    ontap: _handleResetPassword,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/onboarding/create_account.dart';
import 'package:pinput/pinput.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final TextEditingController _pinController = TextEditingController();

  void _navigateToCreateAccountScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => const CreateAccount(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  void _handleOtpSubmit(String pin) {
    if (pin.length < 4) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.stashPasswordAndCode(code: pin, password: '');
    _navigateToCreateAccountScreen(context);
  }

  Future<void> _handleResend() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact info missing. Go back and request OTP again.'),
        ),
      );
      return;
    }
    final success = await authProvider.sendOtp(authProvider.contact!);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('OTP sent successfully.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to resend OTP.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
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
                child: const Icon(Icons.close, size: 20, color: Colors.black),
              ),
              const SizedBox(height: 50),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/lock.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'One Time Password',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enter the One-Time Password (OTP)\nwe just sent to your registered contact to verify your\naccount.',
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 40),

                      if (authProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Pinput(
                                length: 4,
                                controller: _pinController,
                                showCursor: true,
                                onCompleted: _handleOtpSubmit,

                                // 👇 Placeholder
                                preFilledWidget: Text(
                                  '0',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: Colors.grey.shade400,
                                  ),
                                ),

                                // 👇 Default (Empty State)
                                defaultPinTheme: PinTheme(
                                  width: 45,
                                  height: 55,
                                  textStyle: theme.textTheme.displaySmall
                                      ?.copyWith(color: Colors.black),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                // 👇 Focused State
                                focusedPinTheme: PinTheme(
                                  width: 45,
                                  height: 55,
                                  textStyle: theme.textTheme.displaySmall
                                      ?.copyWith(color: Colors.black),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                // 👇 Submitted State
                                submittedPinTheme: PinTheme(
                                  width: 45,
                                  height: 55,
                                  textStyle: theme.textTheme.displaySmall
                                      ?.copyWith(color: Colors.black),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F2F7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '00:59',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _handleResend,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 6,
                                              ),
                                              child: Icon(
                                                Icons.refresh,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Resend',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Disclaimer
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'By signing up, you agree that the information you provide is accurate and complete. You acknowledge that your account is personal to you and should not be shared with others. We are not responsible for any loss, damages, or misuse of your account resulting from failure to keep your login details secure.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
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

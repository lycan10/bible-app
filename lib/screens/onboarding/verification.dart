import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/onboarding/create_account.dart';
import 'dart:async';
import 'package:pinput/pinput.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final TextEditingController _pinController = TextEditingController();
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _remainingSeconds = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

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
    if (_remainingSeconds > 0) return; // Prevent early resend

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact info missing. Go back and request OTP again.'),
        ),
      );
      return;
    }
    final result = await authProvider.sendOtp(authProvider.contact!);
    if (mounted) {
      if (result.success) {
        _startTimer();
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
    _timer?.cancel();
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Pinput(
                                length: 4,
                                controller: _pinController,
                                showCursor: true,
                                onCompleted: _handleOtpSubmit,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                // 👇 Placeholder
                                preFilledWidget: Text(
                                  '0',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: Colors.grey.shade400,
                                  ),
                                ),

                                // 👇 Default (Empty State)
                                defaultPinTheme: PinTheme(
                                  width: 60,
                                  height: 70,
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
                                  width: 60,
                                  height: 70,
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
                                  width: 60,
                                  height: 70,
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
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive the code? ",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _remainingSeconds == 0 ? _handleResend : null,
                                  child: Text(
                                    _remainingSeconds == 0
                                        ? 'Resend Code'
                                        : 'Resend in 00:${_remainingSeconds.toString().padLeft(2, '0')}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: _remainingSeconds == 0
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                      fontWeight: FontWeight.bold,
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

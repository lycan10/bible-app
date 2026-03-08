import 'package:flutter/material.dart';
import 'package:quest/components/onboarding_button.dart';
import 'package:animations/animations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:quest/screens/onboarding/verification.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  void _navigateToVerificationScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => const Verification(),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    PhoneNumber number = PhoneNumber(isoCode: 'US'); // Default country
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.close, size: 20, color: Colors.black),
              SizedBox(height: 30),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/binoculars.png',
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Get Started',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 32,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Login or create account to enjoy \n better experience on Quid',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Expanded(
                              child: InternationalPhoneNumberInput(
                                onInputChanged: (PhoneNumber phoneNumber) {
                                  phoneNumber.phoneNumber;
                                },
                                onInputValidated: (bool isValid) {
                                  isValid;
                                },
                                selectorConfig: const SelectorConfig(
                                  selectorType: PhoneInputSelectorType.DROPDOWN,
                                  showFlags: true,
                                  setSelectorButtonAsPrefixIcon: true,
                                  trailingSpace: false,
                                ),
                                initialValue: number,
                                textFieldController: TextEditingController(),
                                formatInput: true,
                                keyboardType: TextInputType.number,
                                inputDecoration: InputDecoration(
                                  hintText: '000-000-0000',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      width: 0,
                                      color: Colors.transparent,
                                    ), // no border
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      width: 0,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      width: 0,
                                      color: Colors.transparent,
                                    ),
                                  ),

                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      OnboardingButton(
                        title: 'Continue',
                        ontap: () => _navigateToVerificationScreen(context),
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue with Google',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 15),
                          Image.asset('assets/images/google_o.png'),
                        ],
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/apple_o.png'),
                          SizedBox(width: 15),
                          Text(
                            'Continue with Apple',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontSize: 14,
                            ),
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

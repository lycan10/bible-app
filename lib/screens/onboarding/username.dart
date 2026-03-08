import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:quest/screens/onboarding/permission.dart';
import '../../components/onboarding_button.dart';

class Username extends StatefulWidget {
  const Username({super.key});

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  final TextEditingController usernameController = TextEditingController();

  List<String> suggestions = [];

  void _navigateToPermissionScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => const Permission(),
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

  // ✅ Generate 6 Alphanumeric Suggestions
  void generateSuggestions(String base) {
    if (base.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    final random = Random();
    final newSuggestions = <String>[];

    while (newSuggestions.length < 6) {
      String numbers = (random.nextInt(900) + 100).toString(); // 3 digits
      String letters = String.fromCharCodes(
        List.generate(2, (_) => random.nextInt(26) + 97),
      );

      newSuggestions.add("${base.toLowerCase()}$letters$numbers");
    }

    setState(() => suggestions = newSuggestions);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.close, size: 20, color: Colors.black),
              const SizedBox(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/star.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Create a Username',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 32,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        'Define your username to continue',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// USERNAME INPUT
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Username',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),

                          Input(
                            controller: usernameController,
                            hint: "Enter username",
                            onChanged: generateSuggestions,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// SUGGESTIONS
                      if (suggestions.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Suggestions',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),

                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  suggestions
                                      .map(
                                        (s) => SuggestionBox(
                                          text: s,
                                          onTap: () {
                                            usernameController.text = s;
                                            generateSuggestions(s);
                                          },
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              /// CONTINUE BUTTON
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: OnboardingButton(
                  title: 'Continue',
                  ontap: () => _navigateToPermissionScreen(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ INPUT FIELD
class Input extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final Function(String)? onChanged;

  const Input({super.key, this.controller, this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint ?? "Enter text",
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// ✅ SUGGESTION BOX WIDGET
class SuggestionBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SuggestionBox({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

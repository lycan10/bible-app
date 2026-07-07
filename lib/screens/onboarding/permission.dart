import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/navigation_screen.dart';
import '../../components/onboarding_button.dart';
import 'package:hugeicons/hugeicons.dart';

class Permission extends StatefulWidget {
  const Permission({super.key});

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  void _navigateToNavigationScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const NavigationScreen()),
      (route) => false,
    );
  }

  Future<void> _handleAllowAccess() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.grantPermissions();

    if (mounted) {
      if (success) {
        _navigateToNavigationScreen(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Failed to update permissions.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final firstName = authProvider.user?['firstName'] ?? 'User';

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
              const SizedBox(height: 30),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/bell.png',
                        width: 123,
                        height: 123,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hello, $firstName',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'We need your permission!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'To give you the best experience, our app\nrequires the following permissions:',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 25),

                      Column(
                        children: [
                          const PermissionItem(
                            iconColor: Color(0xFF0088FF),
                            icon: HugeIcons.strokeRoundedCamera01,
                            title: "Camera/Photos",
                            description:
                                "to let you upload or update your profile picture.",
                          ),
                          const SizedBox(height: 20),
                          const PermissionItem(
                            iconColor: Color(0xFF4A3AFF),
                            icon: HugeIcons.strokeRoundedLocation01,
                            title: "Location",
                            description:
                                "to provide location-based services and recommendations.",
                          ),
                          const SizedBox(height: 20),
                          const PermissionItem(
                            iconColor: Color(0xFFFF383C),
                            icon: HugeIcons.strokeRoundedNotification03,
                            title: "Notifications",
                            description: "so you don’t miss important updates.",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'We only use these permissions to improve your experience. You’re always in control — you can manage or revoke permissions at any time in your device settings.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Disclaimer
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: OnboardingButton(
                  title: 'Allow Access',
                  isLoading: authProvider.isLoading,
                  ontap: _handleAllowAccess,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionItem extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String description;
  final Color iconColor;

  const PermissionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7.5),
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: HugeIcon(
            icon: icon,
            size: 20,
            color: Colors.white,
            strokeWidth: 1,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
              children: [
                TextSpan(text: '$title\n'),
                TextSpan(
                  text: description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

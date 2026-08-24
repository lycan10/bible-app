import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/profileScreen/profile_screen.dart';
import 'package:quest/screens/profileScreen/public_profile_screen.dart';

class UserProfileCard {
  static void show(BuildContext context, [Map<String, dynamic>? user]) {
    final auth = context.read<AuthProvider>();
    final authId = auth.user?['id']?.toString() ?? auth.user?['_id']?.toString();
    final targetId = user?['id']?.toString() ?? user?['_id']?.toString();

    // No user passed, or the target is the current user → go to own profile
    if (user == null || (authId != null && authId == targetId)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PublicProfileScreen(user: user)),
      );
    }
  }
}

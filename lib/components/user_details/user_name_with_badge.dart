import 'package:flutter/material.dart';

class UserNameWithBadge extends StatelessWidget {
  final Map<String, dynamic> user;
  final TextStyle? style;
  final double iconSize;

  const UserNameWithBadge({
    super.key,
    required this.user,
    this.style,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final displayName = "$firstName $lastName".trim();
    final badge = user['verificationBadge'] ?? 'NONE';

    if (badge == 'NONE') {
      return Text(displayName, style: style, overflow: TextOverflow.ellipsis);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            displayName,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        if (badge == 'BLUE')
          Icon(Icons.verified, color: Colors.blue, size: iconSize)
        else if (badge == 'GOLD')
          Icon(Icons.verified, color: Colors.amber, size: iconSize),
      ],
    );
  }
}

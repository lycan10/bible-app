import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String image; // pass the image path to the widget

  const Avatar({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff00d4ff), Color(0xff4a3aff)],
        ),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          image,
          width: 18, // adjust size as needed
          height: 18,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

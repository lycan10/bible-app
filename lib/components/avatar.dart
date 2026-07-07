import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool hasBorder;
  final Widget? fallbackIcon;

  const CustomAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20.0,
    this.hasBorder = false,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final isNetworkImage = hasValidImage && imageUrl!.startsWith('http');

    ImageProvider? imageProvider;
    if (hasValidImage) {
      if (isNetworkImage) {
        imageProvider = NetworkImage(imageUrl!);
      } else {
        imageProvider = AssetImage(imageUrl!);
      }
    }

    Widget avatar = CircleAvatar(
      radius: hasBorder ? radius - 2 : radius,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: imageProvider,
      child: !hasValidImage
          ? fallbackIcon ??
              Icon(
                Icons.person,
                size: (hasBorder ? radius - 2 : radius),
                color: Colors.white,
              )
          : null,
    );

    if (hasBorder) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff00d4ff), Color(0xff4a3aff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: ClipOval(child: avatar),
      );
    }

    return avatar;
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const SearchBar({
    super.key,
    required this.onTap,
    this.hintText = "Search...",
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // ✅ prevents layout issues
      child: Row(
        children: [
          /// MENU BUTTON
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white, // safer than red for UI consistency
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedLeftToRightListBullet,
                size: 22,
                color: Colors.black,
                strokeWidth: 1,
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// SEARCH FIELD
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    size: 18,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      onChanged: onChanged,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

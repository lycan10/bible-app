import 'package:flutter/material.dart';

class ReactionPicker extends StatefulWidget {
  final Function(String) onReactionSelected;

  const ReactionPicker({super.key, required this.onReactionSelected});

  @override
  State<ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends State<ReactionPicker>
    with SingleTickerProviderStateMixin {
  final List<String> emojis = ['👍', '❤️', '😂', '😮', '😢', '😡'];
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: emojis.map((emoji) {
              return GestureDetector(
                onTap: () {
                  widget.onReactionSelected(emoji);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

void showReactionPicker(BuildContext context, Offset position, Function(String) onReactionSelected) {
  OverlayEntry? overlayEntry;

  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final double estimatedWidth = 280.0; // Estimated width of the picker
  
  // Center roughly over the touch position
  double left = position.dx - (estimatedWidth / 2);
  
  // Clamp to screen edges
  if (left + estimatedWidth > screenWidth - 16) {
    left = screenWidth - estimatedWidth - 16;
  }
  if (left < 16) {
    left = 16;
  }
  
  // Place above, or below if not enough space
  double top = position.dy - 70;
  if (top < 50) {
    top = position.dy + 50;
  }

  overlayEntry = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              overlayEntry?.remove();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: ReactionPicker(
              onReactionSelected: (emoji) {
                overlayEntry?.remove();
                onReactionSelected(emoji);
              },
            ),
          ),
        ],
      );
    },
  );

  Overlay.of(context).insert(overlayEntry);
}

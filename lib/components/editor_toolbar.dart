import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hugeicons/hugeicons.dart';

class EditorToolbar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback onInsertBible;
  final VoidCallback? onMicPressed;
  final VoidCallback? onAddPressed;
  final VoidCallback? onLogFeelings;
  final bool showMic;

  const EditorToolbar({
    super.key,
    required this.controller,
    required this.onInsertBible,
    this.onMicPressed,
    this.onAddPressed,
    this.onLogFeelings,
    this.showMic = false,
  });

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onLogFeelings != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedChart01,
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    title: Text(
                      'Log Feelings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onLogFeelings?.call();
                    },
                  ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedBookOpen01,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  title: Text(
                    'Add Bible verse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onInsertBible();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedImage01,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  title: Text(
                    'Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onAddPressed?.call();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.ul,
            options: const QuillToolbarToggleStyleButtonOptions(
              iconData: Icons.format_list_bulleted,
              iconSize: 20,
            ),
          ),
          if (!showMic)
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.ol,
              options: const QuillToolbarToggleStyleButtonOptions(
                iconData: Icons.format_list_numbered,
                iconSize: 20,
              ),
            ),
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.leftAlignment,
            options: const QuillToolbarToggleStyleButtonOptions(
              iconData: Icons.format_align_left,
              iconSize: 20,
            ),
          ),
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.italic,
            options: const QuillToolbarToggleStyleButtonOptions(
              iconData: Icons.format_italic,
              iconSize: 20,
            ),
          ),
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.bold,
            options: const QuillToolbarToggleStyleButtonOptions(
              iconData: Icons.format_bold,
              iconSize: 20,
            ),
          ),
          if (showMic)
            IconButton(
              icon: Icon(
                Icons.mic,
                size: 24,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.54),
              ),
              onPressed: onMicPressed,
              tooltip: 'Voice Input',
            ),
          IconButton(
            icon: Icon(
              Icons.add,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => _showAddMenu(context),
          ),
        ],
      ),
    );
  }
}

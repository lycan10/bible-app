import 'package:flutter/material.dart';
import 'package:quest/theme/theme.dart';

class TagTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];
    final regex = RegExp(r'\[Verse:(.*?)\]');
    final matches = regex.allMatches(text);

    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        children.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }

      children.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: style?.copyWith(
            backgroundColor: AppTheme.textColor2.withValues(alpha: 0.1),
            color: AppTheme.textColor2,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      children.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return TextSpan(style: style, children: children);
  }
}

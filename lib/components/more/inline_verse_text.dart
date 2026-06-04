import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quest/theme/theme.dart';

class InlineVerseText extends StatelessWidget {
  final String text;
  final Function(String) onVerseTap;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const InlineVerseText({
    super.key,
    required this.text,
    required this.onVerseTap,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? const TextStyle(color: Colors.black, fontSize: 14);
    final linkStyle = defaultStyle.copyWith(
      color: AppTheme.textColor2,
      decoration: TextDecoration.underline,
      decorationColor: AppTheme.textColor2,
    );

    // Regex to match [Verse:John 3:16]
    final regex = RegExp(r'\[Verse:(.*?)\]');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: defaultStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      // Add the matched verse as an interactive link
      final verseRef = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: verseRef,
          style: linkStyle,
          recognizer: TapGestureRecognizer()..onTap = () => onVerseTap(verseRef),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add any remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(style: defaultStyle, children: spans),
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip),
    );
  }
}

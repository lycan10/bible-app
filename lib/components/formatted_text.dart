import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const FormattedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // MarkdownBody does not support exact maxLines/ellipsis easily. 
    // To support maxLines on simple texts, we could use regex to build a TextSpan, 
    // but flutter_markdown's MarkdownBuilder allows us to at least render markdown.
    // However, if maxLines is strictly needed for previews, we will wrap in a 
    // LayoutBuilder to clip or let the parent constrain it. 
    
    Widget markdown = MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: style ?? theme.textTheme.bodyMedium,
        a: style?.copyWith(color: theme.colorScheme.primary) ?? theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
        strong: style?.copyWith(fontWeight: FontWeight.bold) ?? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        em: style?.copyWith(fontStyle: FontStyle.italic) ?? theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        del: style?.copyWith(decoration: TextDecoration.lineThrough) ?? theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.lineThrough),
      ),
      onTapLink: (text, href, title) async {
        if (href != null) {
          final uri = Uri.parse(href);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        }
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight) {
          return ClipRect(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: markdown,
            ),
          );
        }
        return markdown;
      },
    );
  }
}

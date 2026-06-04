import 'dart:convert';

class TextParser {
  /// Extracts actual text from a Quill Delta JSON string.
  /// If the input is not valid JSON, it returns the input string as-is.
  /// This ignores objects like images, voice notes, etc.
  static String extractTextFromDelta(String? input) {
    if (input == null || input.isEmpty) return "";

    // If it doesn't look like a JSON array, return as is.
    if (!input.trim().startsWith('[')) {
      return input.trim();
    }

    try {
      final List<dynamic> delta = jsonDecode(input);
      final StringBuffer buffer = StringBuffer();
      for (final op in delta) {
        if (op is Map<String, dynamic> && op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is String) {
            buffer.write(insert);
          }
          // Ignore if insert is an object (image, voice note)
        }
      }
      return buffer.toString().trim().replaceAll('\n', ' ');
    } catch (e) {
      // Fallback if parsing fails
      return input.trim();
    }
  }
}

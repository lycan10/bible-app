import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quest/components/embeds/voice_note_embed.dart';
import 'package:quest/components/modals/voice_recorder_modal.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:provider/provider.dart';

/// Mixin that provides optimistic (instant preview) media insertion for
/// QuillEditor. It inserts a local file path immediately, then uploads the
/// file in the background and swaps the placeholder for the remote URL.
mixin MediaUploadMixin<T extends StatefulWidget> on State<T> {
  QuillController get quillController;

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns the current cursor position, defaulting to end of document.
  int get _insertIndex {
    final offset = quillController.selection.baseOffset;
    return offset < 0 ? quillController.document.length - 1 : offset;
  }

  /// Finds the document offset of an embed whose data matches [placeholder].
  /// Returns -1 if not found.
  int _findEmbedOffset(String embedKey, String placeholder) {
    final delta = quillController.document.toDelta();
    int offset = 0;
    for (final op in delta.toList()) {
      if (op.isInsert) {
        final data = op.data;
        if (data is Map && data[embedKey] == placeholder) {
          return offset;
        }
        offset += (data is String) ? data.length : 1;
      }
    }
    return -1;
  }

  /// Replaces an embed at [offset] (1 char) with [newEmbed].
  void _replaceEmbed(int offset, Embeddable newEmbed) {
    if (offset < 0) return;
    quillController.replaceText(offset, 1, newEmbed, null);
  }

  // ── Image ─────────────────────────────────────────────────────────────────

  Future<void> pickAndInsertImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null || !mounted) return;

    final localPath = picked.path;
    final insertAt = _insertIndex;

    // 1. Instant preview — insert local path immediately
    quillController.document.insert(insertAt, BlockEmbed.image(localPath));

    // 2. Upload in background
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      final res = await ApiService.uploadMedia(token, localPath);
      final remoteUrl = res['fileUrl'] as String?;
      if (remoteUrl != null && mounted) {
        // 3. Swap placeholder with remote URL
        final offset = _findEmbedOffset('image', localPath);
        _replaceEmbed(offset, BlockEmbed.image(remoteUrl));
      }
    } catch (e) {
      if (mounted) {
        // Remove the broken placeholder embed
        final offset = _findEmbedOffset('image', localPath);
        if (offset >= 0) quillController.replaceText(offset, 1, '', null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      }
    }
  }

  // ── Voice Note ────────────────────────────────────────────────────────────

  Future<void> recordAndInsertVoiceNote() async {
    final localPath = await VoiceRecorderModal.show(context);
    if (localPath == null || !mounted) return;

    final insertAt = _insertIndex;

    // 1. Instant preview — insert local file path immediately
    quillController.document.insert(insertAt, VoiceNoteBlockEmbed(localPath));

    // 2. Upload in background
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      final res = await ApiService.uploadMedia(token, localPath);
      final remoteUrl = res['fileUrl'] as String?;
      if (remoteUrl != null && mounted) {
        // 3. Swap placeholder with remote URL
        final offset = _findEmbedOffset('voiceNote', localPath);
        _replaceEmbed(offset, VoiceNoteBlockEmbed(remoteUrl));
      }
    } catch (e) {
      if (mounted) {
        final offset = _findEmbedOffset('voiceNote', localPath);
        if (offset >= 0) quillController.replaceText(offset, 1, '', null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Voice note upload failed: $e')));
      }
    }
  }
}

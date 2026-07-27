import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../components/editor_toolbar.dart';
import '../../components/embeds/media_upload_manager.dart';
import '../../components/embeds/smart_image_embed.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../components/bible_reference_picker.dart';
import '../../components/embeds/voice_note_embed.dart';
import '../../components/coin_purchase_dialog.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({super.key});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen>
    with MediaUploadMixin<NewNoteScreen> {
  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  bool _isSaving = false;

  @override
  QuillController get quillController => _controller;

  void _saveNote() async {
    if (_isSaving) return;

    final title = _titleController.text.trim();
    final bodyText = _controller.document.toPlainText();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warning: Title is missing! Please enter a title.'),
        ),
      );
      return;
    }
    if (bodyText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warning: Content is missing! Please enter some text.'),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    setState(() => _isSaving = true);

    try {
      final costCheck = await ApiService.checkActionCost(token, 'create_note');
      if (costCheck['error'] != null) {
        throw Exception(costCheck['error']);
      }

      if (costCheck['isFree'] == false && (costCheck['cost'] ?? 0) > 0) {
        setState(() => _isSaving = false);
        final bool proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Action Costs Coins"),
            content: Text("Creating a note will cost ${costCheck['cost']} coins.\n\nReason: ${costCheck['reason']}\n\nDo you want to proceed?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Proceed"),
              ),
            ],
          ),
        ) ?? false;
        
        if (!proceed) return;
        setState(() => _isSaving = true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cost check failed: $e')));
      }
      return;
    }

    try {
      if (token != null) {
        final extractedVerses =
            RegExp(
              r'\[Verse:(.*?)\]',
            ).allMatches(bodyText).map((m) => m.group(1)!).toList();

        final bodyJson = jsonEncode(_controller.document.toDelta().toJson());

        final res = await ApiService.createPersonalNote(
          token,
          title,
          bodyJson,
          verses: extractedVerses,
        );
        if (mounted) {
          if (res['error'] != null) {
            if (res['error'].toString().contains('Insufficient coins') || res['error'].toString().contains('limit')) {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: "Purchase Coins",
                pageBuilder: (_, __, ___) => const CoinPurchaseDialog(),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${res['error']}')),
              );
            }
          } else {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _insertBibleVerse() {
    showBibleReferencePicker(context, (reference) {
      if (reference != null) {
        final index = _controller.selection.baseOffset;
        final length =
            _controller.selection.extentOffset -
            _controller.selection.baseOffset;
        _controller.replaceText(index, length, '[Verse:$reference] ', null);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Note',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(
                0xFF4C4DFF,
              ), // Blue color from screenshot
              radius: 18,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const HugeIcon(
                          icon: HugeIcons.strokeRoundedSent,
                          color: Colors.white,
                          size: 20,
                        ),
                onPressed: _saveNote,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Note Title',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.26),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: QuillEditor.basic(
                        controller: _controller,
                        config: QuillEditorConfig(
                          placeholder: 'Write here',
                          embedBuilders: [
                            SmartImageEmbedBuilder(),
                            VoiceNoteEmbedBuilder(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: EditorToolbar(
                controller: _controller,
                onInsertBible: _insertBibleVerse,
                onAddPressed: () => pickAndInsertImage(),
                showMic: true,
                onMicPressed: () => recordAndInsertVoiceNote(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

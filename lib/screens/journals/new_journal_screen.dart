import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/feeling_selector.dart';
import '../../components/editor_toolbar.dart';
import '../../components/embeds/media_upload_manager.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../services/api_service.dart';
import '../../components/bible_reference_picker.dart';
import '../../components/embeds/smart_image_embed.dart';
import '../../components/embeds/voice_note_embed.dart';

class NewJournalScreen extends StatefulWidget {
  const NewJournalScreen({super.key});

  @override
  State<NewJournalScreen> createState() => _NewJournalScreenState();
}

class _NewJournalScreenState extends State<NewJournalScreen> with MediaUploadMixin<NewJournalScreen> {
  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  List<String> _selectedFeelings = [];
  bool _isSaving = false;

  @override
  QuillController get quillController => _controller;

  void _showFeelingSelector() {
    FeelingSelector.show(
      context,
      onSelected: (feeling, emoji) {
        setState(() {
          _selectedFeelings = ['$emoji $feeling'];
        });
      },
    );
  }

  void _saveJournal() async {
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
    if (_selectedFeelings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warning: Feeling is mandatory for a journal!'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        final extractedVerses =
            RegExp(
              r'\[Verse:(.*?)\]',
            ).allMatches(bodyText).map((m) => m.group(1)!).toList();

        final bodyJson = jsonEncode(_controller.document.toDelta().toJson());

        await ApiService.createJournal(
          token,
          title,
          bodyJson,
          verses: extractedVerses,
          feelings: _selectedFeelings,
        );

        final parts = _selectedFeelings.first.split(' ');
        if (parts.length >= 2) {
          final emoji = parts.first;
          final feelingText = parts.sublist(1).join(' ');
          if (mounted) {
            Provider.of<FeedProvider>(
              context,
              listen: false,
            ).changeFeeling(token, feelingText, emoji);
          }
        }

        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving journal: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _insertBibleVerse() {
    showBibleReferencePicker(context, (reference) {
      if (reference != null) {
        final index = _controller.selection.baseOffset;
        final length = _controller.selection.extentOffset - _controller.selection.baseOffset;
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
          'New Journal',
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
              backgroundColor: const Color(0xFF4C4DFF),
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
                          icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                          color: Colors.white,
                          size: 20,
                        ),
                onPressed: _saveJournal,
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
                        hintText: 'Journal Title',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.26),
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

            // Feeling Widget
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: GestureDetector(
                onTap: _showFeelingSelector,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C4DFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF4C4DFF).withOpacity(0.2),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedLeaf01,
                          color: const Color(0xFF4C4DFF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFeelings.isEmpty
                                  ? 'How are you feeling now?'
                                  : _selectedFeelings.join(', '),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Today ${DateFormat('h:mma').format(DateTime.now()).toLowerCase()}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF4C4DFF),
                        radius: 16,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedPencilEdit01,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: EditorToolbar(
                controller: _controller,
                onInsertBible: _insertBibleVerse,
                onMicPressed: () => recordAndInsertVoiceNote(),
                onAddPressed: () => pickAndInsertImage(),
                onLogFeelings: _showFeelingSelector,
                showMic: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

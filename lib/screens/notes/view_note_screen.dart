import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/bible_service.dart';
import '../../components/more/inline_verse_text.dart';
import '../../providers/bible_provider.dart';
import '../../screens/bible/bible_home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../components/editor_toolbar.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/bible_reference_picker.dart';
import '../../components/modals/voice_recorder_modal.dart';
import '../../components/embeds/smart_image_embed.dart';
import '../../components/embeds/voice_note_embed.dart';
import '../../components/daily_feeling_popup.dart';

class ViewNoteScreen extends StatefulWidget {
  final String id;
  final String title;
  final String bodyText;
  final String time;
  final List<String> verses;
  final List<String> feelings;
  final String type; // "Note" or "Journal"

  const ViewNoteScreen({
    super.key,
    required this.id,
    required this.title,
    required this.bodyText,
    required this.time,
    this.verses = const [],
    this.feelings = const [],
    required this.type,
  });

  @override
  State<ViewNoteScreen> createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends State<ViewNoteScreen> {
  late QuillController _controller;

  late String _title;
  late String _date;
  bool _isFavorite = false;
  bool _isSaving = false;
  bool _isEditMode = false;
  late List<String> _selectedFeelings;

  void _showFeelingSelector() {
    DailyFeelingPopup.show(
      context,
      onSelected: (feeling, emoji) {
        setState(() {
          _selectedFeelings = ['$emoji $feeling'];
        });
      },
    );
  }

  void _updateNote() async {
    if (_isSaving) return;
    final bodyText = _controller.document.toPlainText();

    setState(() => _isSaving = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        final extractedVerses =
            RegExp(
              r'\[Verse:(.*?)\]',
            ).allMatches(bodyText).map((m) => m.group(1)!).toList();

        final bodyJson = jsonEncode(_controller.document.toDelta().toJson());

        if (widget.type == "Note") {
          await ApiService.updatePersonalNote(
            token,
            widget.id,
            widget.title,
            bodyJson,
            verses: extractedVerses,
            isFavorite: _isFavorite,
          );
        } else {
          await ApiService.updateJournal(
            token,
            widget.id,
            widget.title,
            bodyJson,
            verses: extractedVerses,
            feelings: _selectedFeelings,
          );
        }
        if (mounted) {
          setState(() => _isEditMode = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note updated!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _date = widget.time;
    _selectedFeelings = List.from(widget.feelings);

    Document document;
    try {
      final deltaJson = jsonDecode(widget.bodyText);
      document = Document.fromJson(deltaJson);
    } catch (e) {
      document = Document()..insert(0, widget.bodyText);
    }

    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        try {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Uploading image...')));
          final res = await ApiService.uploadMedia(token, pickedFile.path);
          final url = res['fileUrl'];
          if (url != null) {
            final index = _controller.selection.baseOffset;
            _controller.document.insert(index, BlockEmbed.image(url));
          }
        } catch (e) {
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      }
    }
  }

  void _recordVoiceNote() async {
    final path = await VoiceRecorderModal.show(context);
    if (path != null && mounted) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading voice note...')),
          );
          final res = await ApiService.uploadMedia(token, path);
          final url = res['fileUrl'];
          if (url != null) {
            final index = _controller.selection.baseOffset;
            _controller.document.insert(index, VoiceNoteBlockEmbed(url));
          }
        } catch (e) {
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      }
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

  void _showVerseBottomSheet(String reference) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FutureBuilder<String?>(
          future: BibleService.getVerseText(reference),
          builder: (context, snapshot) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reference,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4C4DFF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == null)
                      Text(
                        'Could not load verse text.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      )
                    else
                      Text(
                        snapshot.data!,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C4DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // close sheet
                          final parsed = BibleService.parseReference(reference);
                          if (parsed != null) {
                            final bibleProvider = Provider.of<BibleProvider>(
                              context,
                              listen: false,
                            );
                            bibleProvider.loadVerses(
                              parsed['book']!,
                              parsed['chapter']!,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BibleHomeScreen(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          "Open in Bible",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReadOnlyContent() {
    final operations = _controller.document.toDelta().toList();
    List<Widget> contentWidgets = [];
    List<String> imageUrls = [];

    StringBuffer currentText = StringBuffer();

    void flushText() {
      if (currentText.isNotEmpty) {
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InlineVerseText(
              text: currentText.toString(),
              onVerseTap: _showVerseBottomSheet,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        );
        currentText.clear();
      }
    }

    for (final op in operations) {
      if (op.isInsert) {
        if (op.data is String) {
          currentText.write(op.data as String);
        } else if (op.data is Map) {
          final map = op.data as Map;
          if (map.containsKey('image')) {
            imageUrls.add(map['image'] as String);
          } else if (map.containsKey('voiceNote')) {
            flushText();
            contentWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: VoiceNotePlayerWidget(
                  audioUrl: map['voiceNote'] as String,
                ),
              ),
            );
          }
        }
      }
    }
    flushText();

    if (imageUrls.length == 1) {
      contentWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ApiService.getFullImageUrl(imageUrls.first),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (imageUrls.length > 1) {
      contentWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ApiService.getFullImageUrl(imageUrls[index]),
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
          widget.type,
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
                    _isEditMode
                        ? (_isSaving
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
                            ))
                        : const HugeIcon(
                          icon: HugeIcons.strokeRoundedPencilEdit01,
                          color: Colors.white,
                          size: 20,
                        ),
                onPressed: () {
                  if (_isEditMode) {
                    _updateNote();
                  } else {
                    setState(() => _isEditMode = true);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _title,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: HugeIcon(
                          icon:
                              _isFavorite
                                  ? HugeIcons.strokeRoundedFavourite
                                  : HugeIcons.strokeRoundedFavourite,
                          color:
                              _isFavorite
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.26),
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                        },
                      ),
                    ],
                  ),

                  // Date
                  Text(
                    _date,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feelings Widget (Journals only)
                  if (widget.type == 'Journal') ...[
                    GestureDetector(
                      onTap: _showFeelingSelector,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C4DFF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(
                                0xFF4C4DFF,
                              ).withValues(alpha: 0.2),
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
                                        : 'Feelings: ${_selectedFeelings.join(', ')}',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Today $_date', // Using the passed _date for simplicity
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.54),
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
                    const SizedBox(height: 24),
                  ],

                  // Rich Text Editor (View/Edit)
                  if (_isEditMode)
                    QuillEditor.basic(
                      controller: _controller,
                      config: QuillEditorConfig(
                        placeholder: 'Write here...',
                        embedBuilders: [
                          SmartImageEmbedBuilder(),
                          VoiceNoteEmbedBuilder(),
                        ],
                      ),
                    )
                  else
                    _buildReadOnlyContent(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (_isEditMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: EditorToolbar(
                  controller: _controller,
                  onAddPressed: _pickImage,
                  onInsertBible: _insertBibleVerse,
                  onLogFeelings:
                      widget.type == 'Journal' ? _showFeelingSelector : null,
                  showMic: true,
                  onMicPressed: _recordVoiceNote,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

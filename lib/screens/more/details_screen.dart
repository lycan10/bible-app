import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/daily_feeling_popup.dart';
import 'package:quest/components/more/inline_verse_text.dart';
import 'package:quest/components/more/tag_text_editing_controller.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/services/bible_service.dart';

class EntryDetailsScreen extends StatefulWidget {
  final String id;
  final String title;
  final String bodyText;
  final String time;
  final List<String> verses;
  final List<String> feelings;
  final String type; // "Note" or "Journal"
  final Function(String) onVerseTap;
  final VoidCallback? onEditCompleted;

  const EntryDetailsScreen({
    super.key,
    required this.id,
    required this.title,
    required this.bodyText,
    required this.time,
    this.verses = const [],
    this.feelings = const [],
    required this.type,
    required this.onVerseTap,
    this.onEditCompleted,
  });

  @override
  State<EntryDetailsScreen> createState() => _EntryDetailsScreenState();
}

class _EntryDetailsScreenState extends State<EntryDetailsScreen> {
  late String _currentTitle;
  late String _currentBodyText;
  late List<String> _currentVerses;
  late List<String> _currentFeelings;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _currentBodyText = widget.bodyText;
    _currentVerses = List<String>.from(widget.verses);
    _currentFeelings = List<String>.from(widget.feelings);
  }

  void _showEditModal() {
    final titleController = TextEditingController(text: _currentTitle);
    final bodyController = TagTextEditingController();
    bodyController.text = _currentBodyText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText:
                          widget.type == "Journal"
                              ? "Journal Title"
                              : "Note Title",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.book, size: 20, color: Colors.grey),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          _showBibleReferencePicker((newRef) {
                            if (newRef != null) {
                              setModalState(() {
                                final text = bodyController.text;
                                final selection = bodyController.selection;
                                final int insertPos =
                                    selection.start > -1
                                        ? selection.start
                                        : text.length;
                                final int endPos =
                                    selection.end > -1
                                        ? selection.end
                                        : text.length;

                                final String tag = '[Verse:$newRef]';
                                final newText = text.replaceRange(
                                  insertPos,
                                  endPos,
                                  tag,
                                );

                                bodyController.value = bodyController.value
                                    .copyWith(
                                      text: newText,
                                      selection: TextSelection.collapsed(
                                        offset: insertPos + tag.length,
                                      ),
                                    );
                              });
                            }
                          });
                        },
                        child: const Text("Insert Bible"),
                      ),
                      if (widget.type == "Journal") ...[
                        const SizedBox(width: 20),
                        const Icon(Icons.mood, size: 20, color: Colors.grey),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            DailyFeelingPopup.show(
                              context,
                              onSelected: (feeling, emoji) {
                                setModalState(() {
                                  _currentFeelings.clear();
                                  _currentFeelings.add("$emoji $feeling");
                                });
                              },
                            );
                          },
                          child: const Text("Feelings"),
                        ),
                      ],
                    ],
                  ),
                  if (widget.type == "Journal" && _currentFeelings.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Wrap(
                        spacing: 8,
                        children:
                            _currentFeelings
                                .map(
                                  (f) => Chip(
                                    label: Text(
                                      f,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onDeleted: () {
                                      setModalState(() {
                                        _currentFeelings.remove(f);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  const Divider(),
                  TextField(
                    controller: bodyController,
                    decoration: InputDecoration(
                      hintText:
                          widget.type == "Journal"
                              ? "Write your journal..."
                              : "Note details...",
                      border: InputBorder.none,
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B4BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Warning: Title is missing! Please enter a title.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final token =
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).token;
                        if (token != null) {
                          final extractedVerses =
                              RegExp(r'\[Verse:(.*?)\]')
                                  .allMatches(bodyController.text)
                                  .map((m) => m.group(1)!)
                                  .toList();

                          if (widget.type == "Journal") {
                            if (_currentFeelings.isEmpty) {
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Warning: Feeling is mandatory for a journal!',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            await ApiService.updateJournal(
                              token,
                              widget.id,
                              titleController.text,
                              bodyController.text,
                              verses: extractedVerses,
                              feelings: _currentFeelings,
                            );
                          } else {
                            await ApiService.updatePersonalNote(
                              token,
                              widget.id,
                              titleController.text,
                              bodyController.text,
                              verses: extractedVerses,
                            );
                          }

                          setState(() {
                            _currentTitle = titleController.text;
                            _currentBodyText = bodyController.text;
                            _currentVerses = extractedVerses;
                          });

                          if (modalContext.mounted) Navigator.pop(modalContext);
                          if (widget.onEditCompleted != null) {
                            widget.onEditCompleted!();
                          }
                        }
                      },
                      child: Text(
                        widget.type == "Journal"
                            ? "Save Journal Changes"
                            : "Save Note Changes",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBibleReferencePicker(Function(String?) onSelected) async {
    int? selectedBook;
    int? selectedChapter;
    List<int> selectedVerses = [];
    int? totalVersesInChapter;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (pickerContext) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            Widget content;
            if (selectedBook == null) {
              content = ListView.builder(
                shrinkWrap: true,
                itemCount: BibleService.bookNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(BibleService.bookNames[index]),
                    onTap: () {
                      setPickerState(() => selectedBook = index);
                    },
                  );
                },
              );
            } else if (selectedChapter == null) {
              content = FutureBuilder<int>(
                future: BibleService.getChaptersCount(selectedBook!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final count = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                    itemCount: count,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setPickerState(() => selectedChapter = index + 1);
                        },
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              content = FutureBuilder<List<Map<String, dynamic>>>(
                future: BibleService.getVerses(selectedBook!, selectedChapter!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final verses = snapshot.data!;
                  totalVersesInChapter = verses.length;
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                    itemCount: verses.length,
                    itemBuilder: (context, index) {
                      final v = verses[index];
                      final vNum = v['Versecount'] as int;
                      final isSelected = selectedVerses.contains(vNum);
                      return InkWell(
                        onTap: () {
                          setPickerState(() {
                            if (selectedVerses.isEmpty) {
                              selectedVerses.add(vNum);
                            } else if (selectedVerses.length == 1) {
                              final start =
                                  selectedVerses.first < vNum
                                      ? selectedVerses.first
                                      : vNum;
                              final end =
                                  selectedVerses.first > vNum
                                      ? selectedVerses.first
                                      : vNum;
                              selectedVerses = List.generate(
                                end - start + 1,
                                (i) => start + i,
                              );
                            } else {
                              selectedVerses = [vNum];
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blue.withValues(alpha: 0.2)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "$vNum",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selectedBook != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setPickerState(() {
                              if (selectedChapter != null) {
                                selectedChapter = null;
                                selectedVerses.clear();
                              } else {
                                selectedBook = null;
                              }
                            });
                          },
                        )
                      else
                        const SizedBox(width: 48),
                      Text(
                        selectedBook == null
                            ? "Select Book"
                            : selectedChapter == null
                            ? "Select Chapter"
                            : "Select Verse(s)",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(pickerContext),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(child: content),
                  if (selectedChapter != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B4BFF),
                        ),
                        onPressed: () {
                          String ref;
                          final bookName =
                              BibleService.bookNames[selectedBook!];
                          if (selectedVerses.isEmpty ||
                              (totalVersesInChapter != null &&
                                  selectedVerses.length ==
                                      totalVersesInChapter)) {
                            ref = "$bookName $selectedChapter";
                          } else if (selectedVerses.length == 1) {
                            ref =
                                "$bookName $selectedChapter:${selectedVerses.first}";
                          } else {
                            selectedVerses.sort();
                            ref =
                                "$bookName $selectedChapter:${selectedVerses.first}-${selectedVerses.last}";
                          }
                          Navigator.pop(pickerContext);
                          onSelected(ref);
                        },
                        child: Text(
                          selectedVerses.isEmpty
                              ? "Insert Entire Chapter"
                              : "Insert Reference",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "${widget.type} Details",
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            tooltip: "Edit ${widget.type.toLowerCase()}",
            onPressed: _showEditModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.time,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              InlineVerseText(
                text: _currentBodyText,
                onVerseTap: widget.onVerseTap,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  height: 1.6,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

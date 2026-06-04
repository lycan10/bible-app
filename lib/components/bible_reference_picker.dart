import 'package:flutter/material.dart';
import 'package:quest/services/bible_service.dart';

void showBibleReferencePicker(BuildContext context, Function(String?) onSelected) async {
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
    builder: (context) {
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            final start = selectedVerses.first < vNum
                                ? selectedVerses.first
                                : vNum;
                            final end = selectedVerses.first > vNum
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
                          color: isSelected
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
                      onPressed: () => Navigator.pop(context),
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
                        final bookName = BibleService.bookNames[selectedBook!];
                        if (selectedVerses.isEmpty ||
                            (totalVersesInChapter != null &&
                                selectedVerses.length == totalVersesInChapter)) {
                          ref = "$bookName $selectedChapter";
                        } else if (selectedVerses.length == 1) {
                          ref = "$bookName $selectedChapter:${selectedVerses.first}";
                        } else {
                          selectedVerses.sort();
                          ref = "$bookName $selectedChapter:${selectedVerses.first}-${selectedVerses.last}";
                        }
                        Navigator.pop(context);
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

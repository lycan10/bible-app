import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/services/bible_service.dart';

class BibleSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  @override
  String get searchFieldLabel => "Search the Bible...";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text("Enter a keyword to search"));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: BibleService.searchVerses(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No results found."));
        }

        var results = snapshot.data!;
        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            var result = results[index];
            int bookIndex = result['Book'];
            int chapter = result['Chapter'];
            int verse = result['Versecount'];
            String text = result['verse'];
            String reference = BibleService.formatReference(
              bookIndex,
              chapter,
              verse,
            );

            return ListTile(
              title: Text(
                reference,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                close(context, result);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // You can implement recent searches here if desired,
    // for now we just show a prompt.
    return const Center(
      child: Text("Search for keywords in the Bible (e.g. 'Jesus wept')"),
    );
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/books/book_screen.dart';
import 'package:quest/screens/explore/explore_screen.dart'; // For BooksReelCard
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';

final List<Map<String, String>> posts = [
  {
    "userName": "Lenny Olabisi",
    "userImage": "assets/images/boy.png",
    "postText":
        "Christian fellowship is a beautiful expression of faith and unity.",
    "groupName": "Lekki Christian Youths",
    "postImage": "assets/images/test.jpg",
    "likes": "370k",
    "comments": "29",
    "time": "Today 3:25pm",
  },
  {
    "userName": "Sarah Johnson",
    "userImage": "assets/images/boy.png",
    "postText": "Sunday service was powerful today. Feeling blessed!",
    "groupName": "Faith Builders",
    "postImage": "assets/images/test.jpg",
    "likes": "120k",
    "comments": "15",
    "time": "Today 1:10pm",
  },
  {
    "userName": "Michael Ade",
    "userImage": "assets/images/boy.png",
    "postText": "Prayer changes everything. Never stop believing.",
    "groupName": "Prayer Warriors",
    "postImage": "assets/images/test.jpg",
    "likes": "92k",
    "comments": "8",
    "time": "Today 12:05pm",
  },
  {
    "userName": "David Smith",
    "userImage": "assets/images/boy.png",
    "postText": "Grateful for another day to serve God.",
    "groupName": "Global Fellowship",
    "postImage": "assets/images/test.jpg",
    "likes": "54k",
    "comments": "4",
    "time": "Today 10:40am",
  },
];

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  List<dynamic> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token != null) {
      try {
        final data = await ApiService.fetchBooks(auth.token!);
        if (mounted) {
          setState(() {
            _books = data;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToBookScreen(BuildContext context, Map<String, dynamic> book) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => BookScreen(book: book),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Center(child: _PostListMenuDialogBox());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          children: [
            /// TITLE BAR
            TitleOne(
              leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
              title: 'Books',
              trailingIcon: HugeIcons.strokeRoundedMoreVertical,
              leadingIconTap: () => Navigator.pop(context),
              trailingIconTap: () => _openMenu(context),
            ),

            const SizedBox(height: 25),

            // SearchBar(
            //   hintText: "Search communities",
            //   onTap: () {
            //     showModalBottomSheet(
            //       context: context,
            //       isScrollControlled: true,
            //       backgroundColor: Colors.transparent,
            //       builder: (context) {
            //         return DiscoverMore();
            //       },
            //     );
            //   },
            //   onChanged: (value) {
            //     print("Searching: $value");
            //   },
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Menu / List Icon Button
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return DiscoverMore();
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedLeftToRightListBullet,
                      size: 22,
                      color: theme.colorScheme.onSurface,
                      strokeWidth: 1,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// Search Bar
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),

                        const SizedBox(width: 8),

                        /// Search Input
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: "Search for books",
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_books.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "No books found",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else ...[
              SectionHeader(title: "All Books", seeAllText: ""),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _books.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return BooksReelCard(
                    title: book['title'] ?? '',
                    author: book['author'] ?? '',
                    likes: book['_count']?['reactions']?.toString() ?? '0',
                    backgroundImage:
                        book['imageUrl'] ?? 'assets/images/book.jpeg',
                    onTap: () {
                      _navigateToBookScreen(context, book);
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PostListMenuDialogBox extends StatelessWidget {
  const _PostListMenuDialogBox();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 15),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedAiVideo,
              title: 'Auto Scroll',
              subtitle: 'Turn on video autoplay',
              switchValue: false,
            ),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedNotification01,
              title: 'Allow notifications',
              subtitle: 'Turn on or off',
              switchValue: false,
            ),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedSmartPhone03,
              title: 'Haptic Feedback',
              subtitle: 'Turn on haptic feedback',
              switchValue: false,
            ),
          ],
        ),
      ),
    );
  }
}

class MediaCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String author;
  final String likes;
  final VoidCallback? onTap;

  const MediaCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.author,
    required this.likes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 215,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// 🔹 Background Image
              Image.asset(imagePath, fit: BoxFit.cover),

              /// 🔹 Gradient Overlay (better UI)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),

              /// 🔹 Bottom Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// LEFT CONTENT
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'From: ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  TextSpan(
                                    text: author,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.favorite_border,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  likes,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// PLAY BUTTON
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

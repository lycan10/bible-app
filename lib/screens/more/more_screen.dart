import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button_2.dart';
import 'package:quest/components/more/journal_card.dart';
import 'package:quest/components/more/notes_card.dart';
import 'package:quest/components/more/saved_books_card.dart';
import 'package:quest/components/more/saved_card.dart';
import 'package:quest/components/more/saved_messages_card.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/screens/post/post_screen.dart';
import 'package:quest/theme/theme.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String selectedTab = "Notes";

  void _navigateToPostScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => const PostScreen(),
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
      barrierColor: Colors.black.withOpacity(0.4),
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        size: 18,
                        color: AppTheme.textColor2,
                      ),

                      const SizedBox(width: 8),

                      // Expanded around TextField so it stretches
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Search notes, journal, saved...",
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionPillButton2(
                      icon: HugeIcons.strokeRoundedGlobe02,
                      iconColor:
                          selectedTab == "Notes" ? Colors.white : Colors.black,
                      label: "Notes",
                      backgroundColor:
                          selectedTab == "Notes"
                              ? Colors.black
                              : Colors.transparent,
                      textColor:
                          selectedTab == "Notes"
                              ? Colors.white
                              : AppTheme.textColor2,
                      onTap: () => setState(() => selectedTab = "Notes"),
                    ),
                    const SizedBox(width: 10),
                    ActionPillButton2(
                      icon: HugeIcons.strokeRoundedUserGroup,
                      iconColor:
                          selectedTab == "Journal"
                              ? Colors.white
                              : Colors.black,
                      label: "Journal",
                      backgroundColor:
                          selectedTab == "Journal"
                              ? Colors.black
                              : Colors.transparent,
                      textColor:
                          selectedTab == "Journal"
                              ? Colors.white
                              : AppTheme.textColor2,
                      onTap: () => setState(() => selectedTab = "Journal"),
                    ),
                    const SizedBox(width: 10),
                    ActionPillButton2(
                      icon: HugeIcons.strokeRoundedMessage02,
                      iconColor:
                          selectedTab == "Saved" ? Colors.white : Colors.black,
                      label: "Saved",
                      backgroundColor:
                          selectedTab == "Saved"
                              ? Colors.black
                              : Colors.transparent,
                      textColor:
                          selectedTab == "Saved"
                              ? Colors.white
                              : AppTheme.textColor2,
                      onTap: () => setState(() => selectedTab = "Saved"),
                    ),
                  ],
                ),

                if (selectedTab == "Notes")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 7),
                      SectionTitle(title: "Recent"),

                      NotesCard(),
                      NotesCard(),
                      SectionTitle(title: "2 days ago"),
                      NotesCard(),
                      NotesCard(),
                      NotesCard(),
                      NotesCard(),

                      /// POSTS LIST
                    ],
                  ),

                if (selectedTab == "Journal")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 7),
                      SectionTitle(title: "Today's Journal"),

                      JournalCard(),
                      JournalCard(),
                      SectionTitle(title: "Yesterday"),
                      JournalCard(),
                      JournalCard(),
                      SectionTitle(title: "Feb 2, 2026"),
                      JournalCard(),
                      JournalCard(),
                    ],
                  ),

                if (selectedTab == "Saved")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 7),
                      SectionHeader(
                        title: "Verses (234)",
                        seeAllText: "See all",
                      ),

                      SavedCard(),
                      SavedCard(),
                      SectionHeader(
                        title: "Messages (34)",
                        seeAllText: "See all",
                      ),
                      SavedMessagesCard(),
                      SavedMessagesCard(),
                      SavedMessagesCard(),
                      SectionHeader(title: "Books (34)", seeAllText: "See all"),
                      SavedBooksCard(),
                      SavedBooksCard(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final double topSpacing;
  final double bottomSpacing;

  const SectionTitle({
    super.key,
    required this.title,
    this.topSpacing = 15,
    this.bottomSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topSpacing),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}

class _PostListMenuDialogBox extends StatelessWidget {
  const _PostListMenuDialogBox();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 15),
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

class _EventFilterOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.textColor2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          SizedBox(height: 25),
          SettingsRowItem(
            iconBackgroundColor: Colors.transparent,
            title: 'Attending',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            iconBackgroundColor: Colors.transparent,
            title: 'Not attending',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            iconBackgroundColor: Colors.transparent,
            title: 'Upcoming',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            iconBackgroundColor: Colors.transparent,
            title: 'Not interested',
            iconColor: AppTheme.textColor2,
          ),
        ],
      ),
    );
  }
}

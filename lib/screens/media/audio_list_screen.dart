import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/media/audio/audio_reel_card.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/media/audio_reel_screen.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/media_provider.dart';
import 'package:quest/providers/auth_provider.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<MediaProvider>().loadAudioData(auth.token!);
      }
    });
  }

  void _navigateToAudio(BuildContext context, List<dynamic> audios, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                AudioReelScreen(audios: audios, initialIndex: index),
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
    final mediaProvider = Provider.of<MediaProvider>(context);
    final audios = mediaProvider.audio;
    final isLoading = mediaProvider.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  children: [
                    /// TITLE BAR
                    TitleOne(
                      leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                      title: 'Audio Messages',
                      trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                      leadingIconTap: () => Navigator.pop(context),
                      trailingIconTap: () => _openMenu(context),
                    ),

                    const SizedBox(height: 25),

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
                                return const DiscoverMore();
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
                              icon:
                                  HugeIcons.strokeRoundedLeftToRightListBullet,
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
                                const Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Search audio",
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

                    const SizedBox(height: 25),

                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Title
                        Text(
                          "Continue listening",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (audios.isNotEmpty)
                      MediaCard(
                        imagePath:
                            audios.first['imageUrl'] ?? 'assets/images/boy.png',
                        title: audios.first['title'] ?? 'The good stuff',
                        author: audios.first['author'] ?? 'Good kids',
                        likes: '${audios.first['likes'] ?? 0}',
                        onTap: () {
                          _navigateToAudio(context, audios, 0);
                        },
                      ),

                    const SizedBox(height: 15),

                    const SectionHeader(title: "All Audio", seeAllText: ""),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 200,
                      child:
                          audios.isEmpty
                              ? const Center(child: Text("No audio found"))
                              : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: audios.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(width: 15),
                                itemBuilder: (context, index) {
                                  final audio = audios[index];
                                  final image =
                                      audio['imageUrl'] ??
                                      'assets/images/boy.png';
                                  return AudioReelCard(
                                    title: audio['title'] ?? 'Audio',
                                    author: audio['author'] ?? 'Shalom',
                                    likes: '${audio['likes'] ?? 0}',
                                    backgroundImage: image,
                                    duration: audio['duration'] ?? "2:30",
                                    onTap: () {
                                      _navigateToAudio(context, audios, index);
                                    },
                                  );
                                },
                              ),
                    ),
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

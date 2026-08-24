import 'package:quest/components/page_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animations/animations.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/devotion/ongoing_devotion_card.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/components/titles/title_two.dart';
import 'package:quest/screens/devotion/devotion_article_card.dart';
import 'package:quest/screens/devotion/devotion_screen.dart';
import 'package:quest/screens/devotion/submit_devotion_screen.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/devotion_provider.dart';
import '../../components/global_more_menu.dart';
import 'package:quest/main.dart';

class DevotionListScreen extends StatefulWidget {
  const DevotionListScreen({super.key});

  @override
  State<DevotionListScreen> createState() => _DevotionListScreenState();
}

class _DevotionListScreenState extends State<DevotionListScreen>
    with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      context.read<DevotionProvider>().loadPlans(auth.token!);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<DevotionProvider>().loadPlans(auth.token!);
      }
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<DevotionProvider>().searchPlans(auth.token!, query);
      }
    });
  }

  void _navigateToDevotionScreen(
    BuildContext context,
    String planId,
    int dayNum,
  ) {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    DevotionScreen(planId: planId, dayNum: dayNum),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.scaled,
                child: child,
              );
            },
          ),
        )
        .then((_) {
          final auth = context.read<AuthProvider>();
          if (auth.token != null) {
            context.read<DevotionProvider>().loadPlans(auth.token!);
          }
        });
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const GlobalMoreMenu();
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, dynamic plan) {
    final devProvider = Provider.of<DevotionProvider>(context, listen: false);
    final myPlans = devProvider.myPlans;
    final int existingIndex = myPlans.indexWhere(
      (p) => p['plan']['id'] == plan['id'],
    );

    final image = plan['image'] ?? 'assets/images/boy.png';
    int totalLikes = 0;
    if (plan['days'] != null) {
      for (var day in plan['days']) {
        totalLikes += (day['likesCount'] as int? ?? 0);
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DevotionArticleCard(
        title: plan['title'] ?? '',
        description: plan['description'] ?? '',
        author: plan['authorName'] ?? 'Shalom',
        imagePath: image,
        likes: totalLikes > 0 ? totalLikes.toString() : "",
        tag: '${plan['durationDays'] ?? 0} Days Plan',
        status: plan['status'],
        onTap: () {
          if (existingIndex != -1) {
            final myPlan = myPlans[existingIndex];
            final int currentDay = myPlan['currentDay'] ?? 1;
            final int durationDays = myPlan['plan']['durationDays'] ?? 1;
            final int displayDay =
                (currentDay > durationDays) ? durationDays : currentDay;
            _navigateToDevotionScreen(context, plan['id'], displayDay);
          } else {
            showStartPlanModal(
              context: context,
              planTitle: plan['title'] ?? '',
              planImagePath: image,
              authorName: plan['authorName'] ?? 'Shalom',
              authorHandle: plan['authorHandle'] ?? '',
              planDurationText: '${plan['durationDays'] ?? 0} days',
              reminderText: "Set daily reminder",
              reminderTime: "08:00 AM",
              onStart: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final devProvider = Provider.of<DevotionProvider>(
                  context,
                  listen: false,
                );
                if (authProvider.token != null) {
                  try {
                    await devProvider.subscribeToPlan(
                      authProvider.token!,
                      plan['id'],
                    );
                  } catch (e) {
                    // Handle err
                  }
                }
                Navigator.pop(context); // Close modal
                _navigateToDevotionScreen(context, plan['id'], 1);
              },
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final devotionProvider = context.watch<DevotionProvider>();
    final isLoading = devotionProvider.isLoading;
    final myPlans = devotionProvider.myPlans;
    final allPlans = devotionProvider.allPlans;

    final auth = context.watch<AuthProvider>();
    final canCreate =
        auth.user?['verificationBadge'] == 'GOLD' ||
        auth.user?['isAdmin'] == true;

    return Scaffold(
      floatingActionButton:
          canCreate
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubmitDevotionScreen(),
                    ),
                  );
                },
                backgroundColor: AppTheme.buttonColor,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Create Devotion',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageLoader(
        isLoading: isLoading,
        hasData: allPlans.isNotEmpty,
        child: SafeArea(
          child: RefreshIndicator(
                  color: AppTheme.purpleColor,
                  backgroundColor: theme.colorScheme.surface,
                  onRefresh: () async {
                    final auth = context.read<AuthProvider>();
                    if (auth.token != null) {
                      await context.read<DevotionProvider>().loadPlans(
                        auth.token!,
                      );
                    }
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    children: [
                      /// TITLE BAR
                      TitleOne(
                        leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                        title: 'Devotions',
                        trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                        leadingIconTap: () => Navigator.pop(context),
                        //trailingIconTap: () => _openMenu(context),
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
                                icon:
                                    HugeIcons
                                        .strokeRoundedLeftToRightListBullet,
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
                                      controller: _searchController,
                                      onChanged: _onSearchChanged,
                                      decoration: InputDecoration(
                                        hintText: "Search for plans",
                                        border: InputBorder.none,
                                        isDense: true,
                                        hintStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                        suffixIcon:
                                            _searchController.text.isNotEmpty
                                                ? GestureDetector(
                                                  onTap: () {
                                                    _searchController.clear();
                                                    _onSearchChanged('');
                                                    FocusScope.of(
                                                      context,
                                                    ).unfocus();
                                                  },
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                )
                                                : null,
                                        suffixIconConstraints:
                                            const BoxConstraints(
                                              minWidth: 30,
                                              minHeight: 16,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// HEADER
                      const SizedBox(height: 25),

                      if (devotionProvider.isSearching ||
                          _searchController.text.isNotEmpty) ...[
                        const SectionHeader(
                          title: "Search Results",
                          seeAllText: "",
                        ),
                        if (devotionProvider.searchResults.isEmpty &&
                            !devotionProvider.isLoading)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text("No plans found")),
                          )
                        else
                          ...devotionProvider.searchResults.map(
                            (plan) => _buildPlanCard(context, plan),
                          ),
                      ] else ...[
                        if (myPlans.isNotEmpty) ...[
                          Builder(builder: (context) {
                            final ongoingPlans = myPlans.where((myPlan) {
                              final int currentDay = myPlan['currentDay'] ?? 1;
                              final int durationDays = myPlan['plan']['durationDays'] ?? 1;
                              return currentDay <= durationDays;
                            }).toList();
                            
                            final completedPlans = myPlans.where((myPlan) {
                              final int currentDay = myPlan['currentDay'] ?? 1;
                              final int durationDays = myPlan['plan']['durationDays'] ?? 1;
                              return currentDay > durationDays;
                            }).toList();
                            
                            Widget buildPlanCard(Map<String, dynamic> myPlan, bool isCompleted) {
                              int myTotalLikes = 0;
                              if (myPlan['plan']['days'] != null) {
                                for (var day in myPlan['plan']['days']) {
                                  myTotalLikes += (day['likesCount'] as int? ?? 0);
                                }
                              }
                              final int currentDay = myPlan['currentDay'] ?? 1;
                              final int durationDays = myPlan['plan']['durationDays'] ?? 1;
                              final int displayDay = isCompleted ? durationDays : currentDay;
  
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: OngoingDevotionCard(
                                  title: myPlan['plan']['title'] ?? '',
                                  author: myPlan['plan']['authorName'] ?? '',
                                  imagePath: myPlan['plan']['image'] ?? 'assets/images/boy.png',
                                  likes: myTotalLikes > 0 ? myTotalLikes.toString() : "",
                                  planText: "- ${myPlan['plan']['durationDays']} Days Plan",
                                  day: displayDay,
                                  isCompleted: isCompleted,
                                  onContinue: () => _navigateToDevotionScreen(
                                    context,
                                    myPlan['plan']['id'],
                                    displayDay,
                                  ),
                                ),
                              );
                            }
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (ongoingPlans.isNotEmpty) ...[
                                  const SectionHeader(title: "Ongoing devotion", seeAllText: ""),
                                  ...ongoingPlans.map((p) => buildPlanCard(p, false)),
                                ],
                                if (completedPlans.isNotEmpty) ...[
                                  const SectionHeader(title: "Completed devotion", seeAllText: ""),
                                  ...completedPlans.map((p) => buildPlanCard(p, true)),
                                ],
                              ],
                            );
                          }),
                        ],

                        const SectionHeader(
                          title: "Trending now",
                          seeAllText: "See more",
                        ),
                        if (allPlans.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text("No plans available")),
                          )
                        else
                          ...allPlans.map(
                            (plan) => _buildPlanCard(context, plan),
                          ),
                      ],
                    ],
                  ),
                ),
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
              Image.asset(imagePath, fit: BoxFit.cover),
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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

void showStartPlanModal({
  required BuildContext context,
  required String planTitle,
  required String planImagePath,
  required String authorName,
  required String authorHandle,
  required String planDurationText,
  String reminderText = "Set daily reminder",
  String reminderTime = "9:41 AM",
  required VoidCallback onStart,
}) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleTwo(
              leadingIcon: HugeIcons.strokeRoundedCancel01,
              title: 'Start Plan',
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child:
                  planImagePath.trim().replaceAll('"', '').startsWith('http')
                      ? CachedNetworkImage(imageUrl: planImagePath.trim().replaceAll('"', ''),
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Container(
                            width: 62,
                            height: 62,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 20,
                            ),
                          );
                        },
                      )
                      : Image.asset(
                        planImagePath.trim().replaceAll('"', ''),
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 62,
                            height: 62,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 20,
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 300,
              child: Text(
                planTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 19,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              planDurationText,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/boy.png',
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      authorHandle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textColor2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff673aff).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      reminderText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xff673aff),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    reminderTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: onStart,
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      "Start",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: theme.colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}

import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/circle_stuff.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/community_image_tile.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/community/community_individual_screen.dart';
import 'package:quest/theme/theme.dart';

import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/screens/create_community_screen.dart';
import '../../components/global_more_menu.dart';
import 'package:quest/main.dart';

class CommunityListScreen extends StatefulWidget {
  const CommunityListScreen({super.key});

  @override
  State<CommunityListScreen> createState() => _CommunityListScreenState();
}

class _CommunityListScreenState extends State<CommunityListScreen>
    with RouteAware {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadData();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      context.read<CommunityProvider>().loadCommunities(authProvider.token!);
    }
  }

  void _navigateToCommunityScreen(
    BuildContext context,
    Map<String, dynamic> community,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                CommunityIndividualScreen(
                  communityId: community['id'],
                  initialData: community,
                ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const GlobalMoreMenu();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final communityProvider = context.watch<CommunityProvider>();
    final myCommunities = communityProvider.communities;
    final recommended = communityProvider.recommendedCommunities;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCommunityScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.buttonColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final authProvider = context.read<AuthProvider>();
            if (authProvider.token != null) {
              await context.read<CommunityProvider>().loadCommunities(
                authProvider.token!,
              );
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            children: [
              /// TITLE BAR
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Communities',
                trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                leadingIconTap: () => Navigator.pop(context),
                //trailingIconTap: () => _openMenu(context),
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
                            color: AppTheme.textColor2,
                          ),

                          const SizedBox(width: 8),

                          /// Search Input
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                                if (_debounce?.isActive ?? false)
                                  _debounce!.cancel();
                                _debounce = Timer(
                                  const Duration(milliseconds: 500),
                                  () {
                                    final authProvider =
                                        context.read<AuthProvider>();
                                    if (authProvider.token != null) {
                                      if (value.isNotEmpty) {
                                        context
                                            .read<CommunityProvider>()
                                            .searchCommunities(
                                              authProvider.token!,
                                              value,
                                            );
                                      } else {
                                        context
                                            .read<CommunityProvider>()
                                            .loadCommunities(
                                              authProvider.token!,
                                            );
                                      }
                                    }
                                  },
                                );
                              },
                              decoration: const InputDecoration(
                                hintText: "Search communities",
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

              if (_searchQuery.isNotEmpty) ...[
                const SectionHeader(title: "Search Results", seeAllText: ''),
                const SizedBox(height: 15),
                communityProvider.isLoading
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    )
                    : communityProvider.searchResults.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("No communities found."),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: communityProvider.searchResults.length,
                      itemBuilder: (context, index) {
                        final com = communityProvider.searchResults[index];
                        return CommunityImageTile(
                          name: com['name'] ?? 'Community',
                          message: com['description'] ?? '',
                          imagePath: com['image'] ?? "assets/images/boy.png",
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onTap: () => _navigateToCommunityScreen(context, com),
                        );
                      },
                    ),
              ] else ...[
                /// HEADER
                const SectionHeader(
                  title: "Your communities",
                  seeAllText: 'see more',
                ),

                const SizedBox(height: 15),

                /// COMMUNITY LIST
                if (communityProvider.isLoading && myCommunities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  )
                else if (myCommunities.isNotEmpty)
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: myCommunities.length,
                      itemBuilder: (context, index) {
                        final com = myCommunities[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: CircleStuff(
                            onTap:
                                () => _navigateToCommunityScreen(context, com),
                            width: 100,
                            height: 100,
                            title: com['name'] ?? 'Community',
                            description:
                                '${com['_count']?['members'] ?? 0} members',
                            image: com['image'],
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("You haven't joined any communities yet."),
                  ),

                /// POSTS (Mocked or empty for local area)
                // Removed static area communities list to focus on user's recommendations
                const SectionHeader(
                  title: "Suggested communities",
                  seeAllText: 'see more',
                ),

                /// SUGGESTED COMMUNITIES
                if (communityProvider.isLoading && recommended.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: recommended.length,
                    itemBuilder: (context, index) {
                      final com = recommended[index];
                      return CommunityImageTile(
                        name: com['name'] ?? 'Community',
                        message: com['description'] ?? '',
                        imagePath: com['image'] ?? "assets/images/boy.png",
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onTap: () => _navigateToCommunityScreen(context, com),
                      );
                    },
                  ),
              ],
            ],
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

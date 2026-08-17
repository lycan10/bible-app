import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/screens/bible/bible_home_screen.dart';
import 'package:quest/screens/explore/explore_screen.dart';
import 'package:quest/screens/games/games_screen.dart';
import 'package:quest/screens/home/home_screen.dart';
import 'package:quest/screens/more/more_screen.dart';
import 'package:quest/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quest/components/daily_feeling_popup.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/feed_provider.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    GamesScreen(),
    MoreScreen(),
    BibleHomeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAndShowFeelingPopup();
  }

  Future<void> _checkAndShowFeelingPopup() async {
    final prefs = await SharedPreferences.getInstance();
    final String todayDate = DateTime.now().toIso8601String().split('T').first;
    final String? lastPopupDate = prefs.getString('last_feeling_popup_date');

    if (lastPopupDate != todayDate) {
      await prefs.setString('last_feeling_popup_date', todayDate);
      if (mounted) {
        await DailyFeelingPopup.show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT navigation container
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _navItem(HugeIcons.strokeRoundedHome01, "Home", 0),
                      _navItem(HugeIcons.strokeRounded0Circle, "Explore", 1),
                      _navItem(HugeIcons.strokeRoundedCube, "Cubes", 2),
                      _navItem(
                        HugeIcons.strokeRoundedMoreHorizontalCircle01,
                        "More",
                        3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // RIGHT floating button
              GestureDetector(
                onTap: () {
                  if (_currentIndex != 4) {
                    setState(() {
                      _currentIndex = 4; // 👈 BibleHomeScreen index
                    });
                  }
                  _refreshTab(4);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    "assets/images/bible-2.png",
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshTab(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final token = authProvider.token;
    final userId = authProvider.user?['id'];
    
    if (token == null) return;
    
    if (index == 0 && userId != null) {
      feedProvider.loadHomeData(token, userId);
    } else if (index == 1) {
      feedProvider.loadExploreData(token);
    } else if (index == 3) {
      feedProvider.loadProfileDetails(token);
    }
  }

  Widget _navItem(dynamic icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
        _refreshTab(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.transparent,
            width: isSelected ? 1 : 0,
          ),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              size: 18,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Colors.grey,
            ),

            const SizedBox(width: 4),
            Text(
              isSelected ? label : '',
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

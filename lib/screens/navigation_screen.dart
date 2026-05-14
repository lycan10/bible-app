import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/screens/bible/bible_home_screen.dart';
import 'package:quest/screens/explore/explore_screen.dart';
import 'package:quest/screens/home/home_screen.dart';
import 'package:quest/screens/more/more_screen.dart';
import 'package:quest/screens/notification/Notification_screen.dart';
import 'package:quest/theme/theme.dart';

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
    NotificationScreen(),
    MoreScreen(),
    BibleHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _navItem(HugeIcons.strokeRoundedHome01, "Home", 0),
                      _navItem(HugeIcons.strokeRounded0Circle, "Explore", 1),
                      _navItem(HugeIcons.strokeRoundedCube, "Cube", 2),
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
                  setState(() {
                    _currentIndex = 4; // 👈 BibleHomeScreen index
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppTheme.purpleColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    "assets/images/cross.png",
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

  /// ✅ MOVE THIS INSIDE THE CLASS
  Widget _navItem(dynamic icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: isSelected ? 1 : 0,
          ),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              size: 18,
              color: isSelected ? Colors.black : Colors.grey,
            ),

            const SizedBox(width: 4),
            Text(
              isSelected ? label : '',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/stats/stats.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/theme/theme.dart';

class DevotionScreen extends StatelessWidget {
  const DevotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: '',
                trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
                trailingIconTap: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "Filter",
                    barrierColor: Colors.black.withValues(alpha: 0.4),
                    transitionDuration: const Duration(milliseconds: 250),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return Center(child: _PostMenuDialogBox());
                    },
                  );
                },
              ),
              SizedBox(height: 25),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                  "Understanding Grace and Forgiveness",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "365 Days Plan",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.textColor2,
                                ),
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // half of image width/height
                            child: Image.asset(
                              'assets/images/user_test.jpg',
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final day = index + 1;

                            return DayPill(
                              day: day,
                              isSkipped: day == 2,
                              isFuture: day > 3,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Points earned ",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "+20",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.greenColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Image.asset(
                              'assets/images/bronze.png',
                              height: 38,
                              width: 38,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/user_test.jpg',
                            height: 230,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Text Body
                      Text(
                        "Building something from scratch is never just about the final product — it’s about the quiet hours, the tiny improvements, and the lessons learned along the way. Every bug fixed, every design tweak, and every line of code written adds up to something bigger than you first imagined. Growth doesn’t happen in giant leaps; it happens in consistent, intentional steps taken daily. No matter where you are in your journey, remember that progress is progress — even when it feels slow. Stay patient with yourself, celebrate small wins, and keep pushing forward. The version of you that once struggled with what you now find easy is proof that you’re evolving. Keep going — you’re building more than a project, you’re building yourself.",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          height: 1.6,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 25),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              50,
                            ), // half of image width/height
                            child: Image.asset(
                              'assets/images/user_test.jpg',
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lola Able',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                "@lola.a",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.textColor2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Stat(
                                icon: HugeIcons.strokeRoundedThumbsUp,
                                text: "20",
                                iconSize: 18,
                                textColor: AppTheme.textColor2,
                                textSize: 12,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ActionPillButton(
                                icon: HugeIcons.strokeRoundedShare08,
                                label: "Share",
                                onTap: () {},
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      0xff673aff,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "React (384)",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff673aff),
                                              fontSize: 12,
                                            ),
                                      ),
                                      const SizedBox(width: 5),
                                      const VerticalDivider(
                                        width: 4,
                                        thickness: 1.5,

                                        color: Color(0xff673aff),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "🤩",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff673aff),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Done",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedTick02,
                              size: 22,
                              color: AppTheme.greenColor,
                            ),
                          ],
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

class _PostMenuDialogBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),

            SettingsRowItem(
              icon: HugeIcons.strokeRoundedAlarmClock,
              iconBackgroundColor: Colors.transparent,
              title: 'Set a reminder',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedCancel01,
              iconBackgroundColor: Colors.transparent,
              title: 'Cancel Plan',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedFavourite,
              iconBackgroundColor: Colors.transparent,
              title: 'I\'ll like to see more of this',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedInformationDiamond,
              iconBackgroundColor: Colors.transparent,
              title: 'Report this devotion',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class DayPill extends StatelessWidget {
  final String label;
  final int day;
  final bool isSkipped;
  final bool isFuture;

  const DayPill({
    super.key,
    this.label = "Day",
    required this.day,
    this.isSkipped = false,
    this.isFuture = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;
    Color numberColor;

    if (isFuture) {
      /// 🔹 Future days (greyed out)
      bgColor = Colors.grey.withValues(alpha: 0.1);
      textColor = Colors.grey;
      numberColor = Colors.grey;
    } else if (isSkipped) {
      /// 🔹 Skipped day
      bgColor = Colors.amber.withValues(alpha: 0.15);
      textColor = Colors.grey;
      numberColor = Colors.amber;
    } else {
      /// 🔹 Active / completed day
      bgColor = AppTheme.greenColor.withValues(alpha: 0.1);
      textColor = Colors.black;
      numberColor = AppTheme.greenColor;
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 12,
            ),
          ),

          const SizedBox(width: 10),

          /// Dot
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),

          const SizedBox(width: 10),

          Text(
            "$day",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: numberColor,
              fontSize: 12,
            ),
          ),

          /// Skipped label
          if (isSkipped) ...[
            const SizedBox(width: 8),
            Text(
              "Skipped",
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/title_two.dart';
import 'package:quest/screens/notification/notification_option_sheet.dart';
import 'package:quest/theme/theme.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            children: [
              TitleTwo(
                leadingIcon: HugeIcons.strokeRoundedCancel01,
                title: 'Settings',
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xff00d4ff), Color(0xff4a3aff)],
                      ),

                      borderRadius: BorderRadius.circular(
                        50,
                      ), // matches image roundness
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        50,
                      ), // half of image width/height
                      child: Image.asset(
                        'assets/images/boy.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 2,
                            ),
                            children: [
                              TextSpan(text: 'Lenny Daniels\n'),

                              TextSpan(
                                text: '@lenny123',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColor2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedLocation01,
                    iconBackgroundColor: AppTheme.greenColor,
                    title: "Location Settings",
                    onTap: () {},
                    iconColor: Colors.white,
                  ),
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedNotification01,
                    iconBackgroundColor: AppTheme.redColor,
                    title: "Notofications & Sounds",
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return NotificationOptionsSheet();
                        },
                      );
                    },
                    iconColor: Colors.white,
                  ),
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedArtboard,
                    iconBackgroundColor: AppTheme.purpleColor,
                    title: "App Appearance",
                    subtitle: "System Default",
                    onTap: () {},
                    iconColor: Colors.white,
                  ),
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedAlarmClock,
                    iconBackgroundColor: Colors.blue,
                    title: "Reminder",
                    subtitle: "Set reminder to study",
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return _ReminderOptionsSheet();
                        },
                      );
                    },
                    iconColor: Colors.white,
                  ),
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedSecurityCheck,
                    iconBackgroundColor: AppTheme.greenColor,
                    title: "Privacy Policy",
                    onTap: () {},
                    iconColor: Colors.white,
                  ),
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedFile01,
                    iconBackgroundColor: AppTheme.greenColor,
                    title: "Terms of Service",
                    onTap: () {},
                    iconColor: Colors.white,
                  ),
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedGiveBlood,
                    iconGradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xffffe364), Color(0xffff00b7)],
                    ),
                    title: "Donate",
                    subtitle: 'Give to support Shalom App',
                    onTap: () {},
                    iconColor: Colors.white,
                    iconBackgroundColor: null,
                  ),
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedArrowRight03,
                    iconBackgroundColor: AppTheme.yellowColor,
                    title: "Sign Out",
                    onTap: () {},
                    iconColor: Colors.white,
                  ),
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedDelete01,
                    iconBackgroundColor: AppTheme.redColor,
                    title: "Delete Account",
                    onTap: () {},
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderOptionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleTwo(
              leadingIcon: HugeIcons.strokeRoundedCancel01,
              title: 'Set Reminder',
            ),
            SizedBox(height: 20),
            Column(
              children: [
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedAlarmClock,
                  title: "Morning",
                  subtitle: "8am",
                  switchValue: true,
                  onSwitchChanged: (val) {},
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedAlarmClock,
                  title: "Afternoon",
                  subtitle: "1pm",
                  switchValue: true,
                  onSwitchChanged: (val) {},
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedAlarmClock,
                  title: "Evening",
                  subtitle: "6pm",
                  switchValue: true,
                  onSwitchChanged: (val) {},
                ),
                SettingsRowItem(
                  icon: HugeIcons.strokeRoundedAlarmClock,
                  iconBackgroundColor: AppTheme.textColor2.withValues(
                    alpha: 0.1,
                  ),
                  title: "Custom Time",
                  subtitle: 'Set custom reminder',
                  onTap: () {},
                  iconColor: AppTheme.textColor2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/title_two.dart';

class NotificationOptionsSheet extends StatelessWidget {
  const NotificationOptionsSheet({super.key});

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
              title: 'Notification & Sounds',
            ),
            SizedBox(height: 20),
            Column(
              children: [
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedNotification01,
                  title: "Sound Alerts",
                  subtitle: "Turn sounds on or off",
                  switchValue: true,
                  onSwitchChanged: (val) {},
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedSmartPhone03,
                  title: "Haptic Feedback",
                  subtitle: "Turn on haptic feedback",
                  switchValue: true,
                  onSwitchChanged: (val) {},
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedMusicNote04,
                  title: "Music",
                  subtitle: "Play or pause music playback",
                  switchValue: true,
                  onSwitchChanged: (val) {},
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedNotification03,
                  title: "All Notification",
                  subtitle: "Turn on or off all notification",
                  switchValue: true,
                  onSwitchChanged: (val) {},
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedNotification03,
                  title: "In-App Notification",
                  subtitle:
                      "Enable in-app notifications taht appear while using the app",
                  switchValue: true,
                  onSwitchChanged: (val) {},
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedNotificationOff01,
                  title: "Do Not Disturb",
                  subtitle:
                      "Activate Do Not Disturb mode to silence notifications temporarily",
                  switchValue: true,
                  onSwitchChanged: (val) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/title_two.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';

class NotificationOptionsSheet extends StatefulWidget {
  const NotificationOptionsSheet({super.key});

  @override
  State<NotificationOptionsSheet> createState() => _NotificationOptionsSheetState();
}

class _NotificationOptionsSheetState extends State<NotificationOptionsSheet> {
  bool _soundAlerts = true;
  bool _hapticFeedback = true;
  bool _music = true;
  bool _allNotifications = true;
  bool _inAppNotifications = true;
  bool _doNotDisturb = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _soundAlerts = user['soundAlerts'] ?? true;
      _hapticFeedback = user['hapticFeedback'] ?? true;
      _music = user['music'] ?? true;
      _allNotifications = user['allNotifications'] ?? true;
      _inAppNotifications = user['inAppNotifications'] ?? true;
      _doNotDisturb = user['doNotDisturb'] ?? false;
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() {
      if (key == 'soundAlerts') _soundAlerts = value;
      if (key == 'hapticFeedback') _hapticFeedback = value;
      if (key == 'music') _music = value;
      if (key == 'allNotifications') _allNotifications = value;
      if (key == 'inAppNotifications') _inAppNotifications = value;
      if (key == 'doNotDisturb') _doNotDisturb = value;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      // Update local state right away for responsiveness
      authProvider.updateUserLocally({key: value});
      // Send to server
      try {
        await ApiService.updateSettings(token, {key: value});
      } catch (e) {
        // Handle error gracefully
        debugPrint('Failed to update setting: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleTwo(
              leadingIcon: HugeIcons.strokeRoundedCancel01,
              title: 'Notification & Sounds',
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedNotification01,
                  title: "Sound Alerts",
                  subtitle: "Turn sounds on or off",
                  switchValue: _soundAlerts,
                  onSwitchChanged: (val) => _updateSetting('soundAlerts', val),
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedSmartPhone03,
                  title: "Haptic Feedback",
                  subtitle: "Turn on haptic feedback",
                  switchValue: _hapticFeedback,
                  onSwitchChanged: (val) => _updateSetting('hapticFeedback', val),
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedMusicNote04,
                  title: "Music",
                  subtitle: "Play or pause music playback",
                  switchValue: _music,
                  onSwitchChanged: (val) => _updateSetting('music', val),
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedNotification03,
                  title: "All Notification",
                  subtitle: "Turn on or off all notification",
                  switchValue: _allNotifications,
                  onSwitchChanged: (val) => _updateSetting('allNotifications', val),
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedNotification03,
                  title: "In-App Notification",
                  subtitle: "Enable in-app notifications that appear while using the app",
                  switchValue: _inAppNotifications,
                  onSwitchChanged: (val) => _updateSetting('inAppNotifications', val),
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedNotificationOff01,
                  title: "Do Not Disturb",
                  subtitle: "Activate Do Not Disturb mode to silence notifications temporarily",
                  switchValue: _doNotDisturb,
                  onSwitchChanged: (val) => _updateSetting('doNotDisturb', val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

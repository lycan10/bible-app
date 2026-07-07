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
  State<NotificationOptionsSheet> createState() =>
      _NotificationOptionsSheetState();
}

class _NotificationOptionsSheetState extends State<NotificationOptionsSheet> {
  bool _soundAlerts = true;
  bool _hapticFeedback = true;
  bool _music = true;
  bool _allNotifications = true;
  bool _inAppNotifications = true;
  bool _doNotDisturb = false;

  bool _pushDirectMessages = true;
  bool _pushCommunityPosts = true;
  bool _pushCommunityForum = true;
  bool _pushConnectionRequests = true;
  bool _pushConnectionAccepted = true;

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
      _pushDirectMessages = user['pushDirectMessages'] ?? true;
      _pushCommunityPosts = user['pushCommunityPosts'] ?? true;
      _pushCommunityForum = user['pushCommunityForum'] ?? true;
      _pushConnectionRequests = user['pushConnectionRequests'] ?? true;
      _pushConnectionAccepted = user['pushConnectionAccepted'] ?? true;
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
      if (key == 'pushDirectMessages') _pushDirectMessages = value;
      if (key == 'pushCommunityPosts') _pushCommunityPosts = value;
      if (key == 'pushCommunityForum') _pushCommunityForum = value;
      if (key == 'pushConnectionRequests') _pushConnectionRequests = value;
      if (key == 'pushConnectionAccepted') _pushConnectionAccepted = value;
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedNotification01,
                      title: "Sound Alerts",
                      subtitle: "Turn sounds on or off",
                      switchValue: _soundAlerts,
                      onSwitchChanged:
                          (val) => _updateSetting('soundAlerts', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedSmartPhone03,
                      title: "Haptic Feedback",
                      subtitle: "Turn on haptic feedback",
                      switchValue: _hapticFeedback,
                      onSwitchChanged:
                          (val) => _updateSetting('hapticFeedback', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedMusicNote04,
                      title: "Music",
                      subtitle: "Play or pause music playback",
                      switchValue: _music,
                      onSwitchChanged: (val) => _updateSetting('music', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedNotification01,
                      title: "All Notifications",
                      subtitle: "Turn all push notifications on or off",
                      switchValue: _allNotifications,
                      onSwitchChanged:
                          (val) => _updateSetting('allNotifications', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedMessage01,
                      title: "Direct Messages",
                      subtitle: "Push notifications for chat messages",
                      switchValue: _pushDirectMessages,
                      onSwitchChanged:
                          (val) => _updateSetting('pushDirectMessages', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedUserGroup,
                      title: "Community Posts",
                      subtitle: "Push notifications for new community posts",
                      switchValue: _pushCommunityPosts,
                      onSwitchChanged:
                          (val) => _updateSetting('pushCommunityPosts', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedMessage02,
                      title: "Community Forum",
                      subtitle: "Push notifications for forum messages",
                      switchValue: _pushCommunityForum,
                      onSwitchChanged:
                          (val) => _updateSetting('pushCommunityForum', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedUserAdd01,
                      title: "Connection Requests",
                      subtitle: "Push notifications for new requests",
                      switchValue: _pushConnectionRequests,
                      onSwitchChanged:
                          (val) =>
                              _updateSetting('pushConnectionRequests', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedUserCheck01,
                      title: "Connections Accepted",
                      subtitle: "Push notifications when requests are accepted",
                      switchValue: _pushConnectionAccepted,
                      onSwitchChanged:
                          (val) =>
                              _updateSetting('pushConnectionAccepted', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedNotification02,
                      title: "In-App Notifications",
                      subtitle: "Turn on/off notifications in app",
                      switchValue: _inAppNotifications,
                      onSwitchChanged:
                          (val) => _updateSetting('inAppNotifications', val),
                    ),
                    SettingsSwitchRow(
                      icon: HugeIcons.strokeRoundedMoon02,
                      title: "Do Not Disturb",
                      subtitle: "Silent all notifications",
                      switchValue: _doNotDisturb,
                      onSwitchChanged:
                          (val) => _updateSetting('doNotDisturb', val),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

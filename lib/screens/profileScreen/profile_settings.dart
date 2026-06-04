import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/title_two.dart';
import 'package:quest/screens/notification/notification_option_sheet.dart';
import 'package:quest/theme/theme.dart';

import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/onboarding/flash_screen.dart';
import 'package:quest/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:quest/services/notification_service.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  Future<void> _signOut(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FlashScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token != null) {
        await ApiService.deleteAccount(auth.token!);
        await auth.logout();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const FlashScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _updateLocation(BuildContext context, String newLocation) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token != null) {
      try {
        await ApiService.updateProfile(auth.token!, {'location': newLocation});
        auth.updateUserLocally({'location': newLocation});
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update location')));
        }
      }
    }
  }

  Future<void> _showLocationDialog(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentLocation = auth.user?['location'] ?? '';
    final controller = TextEditingController(text: currentLocation);

    final newLocation = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g. New York, USA',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newLocation != null && newLocation != currentLocation && context.mounted) {
      await _updateLocation(context, newLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).user;
    final avatarUrl = user?['avatarUrl'] ?? 'assets/images/boy.png';
    final formattedAvatarUrl = ApiService.getFullImageUrl(avatarUrl);
    final firstName = user?['firstName'] ?? 'User';
    final lastName = user?['lastName'] ?? '';
    final username = user?['username'] ?? '';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      child: formattedAvatarUrl.startsWith('http')
                          ? Image.network(
                              formattedAvatarUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              formattedAvatarUrl,
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
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 2,
                            ),
                            children: [
                              TextSpan(text: '$firstName $lastName\n'),

                              TextSpan(
                                text: '@$username',
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
                    onTap: () => _showLocationDialog(context),
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
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return _AppearanceOptionsSheet();
                        },
                      );
                    },
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
                    onTap: () => _signOut(context),
                    iconColor: Colors.white,
                  ),
                  SettingsRowItem(
                    icon: HugeIcons.strokeRoundedDelete01,
                    iconBackgroundColor: AppTheme.redColor,
                    title: "Delete Account",
                    onTap: () => _deleteAccount(context),
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

class _ReminderOptionsSheet extends StatefulWidget {
  @override
  State<_ReminderOptionsSheet> createState() => _ReminderOptionsSheetState();
}

class _ReminderOptionsSheetState extends State<_ReminderOptionsSheet> {
  bool _morning = false;
  bool _afternoon = false;
  bool _evening = false;
  String? _customTime;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _morning = auth.user?['reminderMorning'] ?? false;
    _afternoon = auth.user?['reminderAfternoon'] ?? false;
    _evening = auth.user?['reminderEvening'] ?? false;
    _customTime = auth.user?['reminderCustomTime'];
  }

  Future<void> _updateSettings(String key, dynamic value) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Manage local scheduled notifications
    if (key == 'reminderMorning') {
      if (value) {
        NotificationService().scheduleDailyReminder(1, 'Good Morning! ☀️', 'Time for your morning devotion.', const TimeOfDay(hour: 8, minute: 0));
      } else {
        NotificationService().cancelReminder(1);
      }
    } else if (key == 'reminderAfternoon') {
      if (value) {
        NotificationService().scheduleDailyReminder(2, 'Good Afternoon! 📖', 'Take a break and read the word.', const TimeOfDay(hour: 13, minute: 0));
      } else {
        NotificationService().cancelReminder(2);
      }
    } else if (key == 'reminderEvening') {
      if (value) {
        NotificationService().scheduleDailyReminder(3, 'Good Evening! 🌙', 'Reflect on your day with the scripture.', const TimeOfDay(hour: 18, minute: 0));
      } else {
        NotificationService().cancelReminder(3);
      }
    } else if (key == 'reminderCustomTime' && value != null) {
      final parts = (value as String).split(':');
      final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      NotificationService().scheduleDailyReminder(4, 'Time to Study! 📚', 'Your custom reminder to read the word.', time);
    }

    if (auth.token != null) {
      try {
        await ApiService.updateSettings(auth.token!, {key: value});
        auth.updateUserLocally({key: value});
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> _selectCustomTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _customTime = formattedTime;
      });
      _updateSettings('reminderCustomTime', formattedTime);
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
              title: 'Set Reminder',
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedAlarmClock,
                  title: "Morning",
                  subtitle: "8am",
                  switchValue: _morning,
                  onSwitchChanged: (val) {
                    setState(() => _morning = val);
                    _updateSettings('reminderMorning', val);
                  },
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedAlarmClock,
                  title: "Afternoon",
                  subtitle: "1pm",
                  switchValue: _afternoon,
                  onSwitchChanged: (val) {
                    setState(() => _afternoon = val);
                    _updateSettings('reminderAfternoon', val);
                  },
                ),
                SettingsSwitchRow(
                  icon: HugeIcons.strokeRoundedAlarmClock,
                  title: "Evening",
                  subtitle: "6pm",
                  switchValue: _evening,
                  onSwitchChanged: (val) {
                    setState(() => _evening = val);
                    _updateSettings('reminderEvening', val);
                  },
                ),
                SettingsRowItem(
                  icon: HugeIcons.strokeRoundedAlarmClock,
                  iconBackgroundColor: AppTheme.textColor2.withValues(
                    alpha: 0.1,
                  ),
                  title: "Custom Time",
                  subtitle: _customTime != null ? 'Remind at $_customTime' : 'Set custom reminder',
                  onTap: () => _selectCustomTime(context),
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

class _AppearanceOptionsSheet extends StatefulWidget {
  @override
  State<_AppearanceOptionsSheet> createState() => _AppearanceOptionsSheetState();
}

class _AppearanceOptionsSheetState extends State<_AppearanceOptionsSheet> {
  String _appearance = 'system';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _appearance = auth.user?['appearance'] ?? 'system';
  }

  Future<void> _updateAppearance(String value) async {
    setState(() {
      _appearance = value;
    });
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token != null) {
      try {
        await ApiService.updateProfile(auth.token!, {'appearance': value});
        auth.updateUserLocally({'appearance': value});
      } catch (e) {
        // Handle error silently or show a toast
      }
    }
    
    if (mounted) {
      Navigator.pop(context);
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
              title: 'App Appearance',
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildAppearanceOption('Light Mode', 'light'),
                _buildAppearanceOption('Dark Mode', 'dark'),
                _buildAppearanceOption('System Default', 'system'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceOption(String label, String value) {
    final isSelected = _appearance == value;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.purpleColor) : null,
      onTap: () => _updateAppearance(value),
    );
  }
}
